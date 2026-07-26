//
//  SearchResultsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import Combine
#if !targetEnvironment(macCatalyst)
import IQKeyboardManagerSwift
#endif
import KurozoraKit
import Tabman
import UIKit

/// The list of available search view types.
enum SearchViewKind {
	case single(_ type: SearchType)
	case multiple
	case library
}

/// The collection view controller in charge of providing the necessary functionalities for searching shows, threads and users.
class SearchResultsCollectionViewController: KCollectionViewController, SectionFetchable, TypedSegueHandling {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case scheduleSegue
		case searchSegue
		case characterDetailsSegue
		case episodeDetailsSegue
		case literatureDetailsSegue
		case gameDetailsSegue
		case personDetailsSegue
		case showDetailsSegue
		case songDetailsSegue
		case studioDetailsSegue
		case userDetailsSegue
		case charactersListSegue
		case episodesListSegue
		case literaturesListSegue
		case gamesListSegue
		case peopleListSegue
		case songsListSegue
		case showsListSegue
		case studiosListSegue
		case usersListSegue
	}

	// MARK: - Properties
	var filterBarButtonItem: UIBarButtonItem!
	let toolbar = UIToolbar()
	let tabBarView = TMBar.KBar()
	var currentTopContentInset: CGFloat = 0
	var currentIndex: Int = 0

	/// The search view to be
	var searchViewKind: SearchViewKind = .multiple

	/// The collection of results fetched by the search request.
	var searchResults: Search?

	/// The current scope of the search.
	var currentScope: SearchScope = .kurozora

	/// Debounced work item that fires a local-library search after the user pauses typing.
	private var libraryAsYouTypeWorkItem: DispatchWorkItem?

	/// The current types of the search.
	var currentTypes: [SearchType] = []

	/// The search query that is performed.
	var searchQuery: String = ""

	/// The collection of discover suggestions.
	var discoverSuggestions: [QuickLink] = []

	/// The collection of browse categories.
	let browseCategories: [BrowseCategory] = [
		BrowseCategory(title: L10n.schedule, image: .Browse.schedule, segueIdentifier: SegueIdentifiers.scheduleSegue),
		BrowseCategory(title: L10n.shows, image: .Browse.shows, searchType: .shows),
		BrowseCategory(title: L10n.literatures, image: .Browse.literatures, searchType: .literatures),
		BrowseCategory(title: L10n.games, image: .Browse.games, searchType: .games),
		BrowseCategory(title: L10n.songs, image: .Browse.songs, searchType: .songs),
		BrowseCategory(title: L10n.episodes, image: .Browse.episodes, searchType: .episodes),
		BrowseCategory(title: L10n.characters, image: .Browse.characters, searchType: .characters),
		BrowseCategory(title: L10n.people, image: .Browse.people, searchType: .people),
		BrowseCategory(title: L10n.studio, image: .Browse.studios, searchType: .studios),
	]

	/// The collection of search types in the current search request
	var searchTypes: [SearchType] = [] {
		didSet {
			self.reloadView()
		}
	}

	/// The search filters applied to the respective search type
	var searchFilters: [SearchType: SearchFilter?] = [:]

	/// Per-search-type model caches.
	private var cachesByType: [SearchType: [IndexPath: KurozoraItem]] = [:]

	/// The resolved Apple Music songs keyed by Apple Music identifier.
	var resolvedSongs: [Int: MKSong] = [:]

	/// The hydrated models keyed by index path.
	var cache: [IndexPath: KurozoraItem] {
		get {
			guard let type = self.searchTypes[safe: self.currentIndex] else { return [:] }
			return self.cachesByType[type] ?? [:]
		}
		set {
			guard let type = self.searchTypes[safe: self.currentIndex] else { return }
			self.cachesByType[type] = newValue
		}
	}

	/// The sections with an in-flight details request.
	var isFetchingSection: Set<SearchResults.Section> = []

	var characterIdentities: [CharacterIdentity] = []
	var episodeIdentities: [EpisodeIdentity] = []
	var personIdentities: [PersonIdentity] = []
	var showIdentities: [ShowIdentity] = []
	var literatureIdentities: [LiteratureIdentity] = []
	var gameIdentities: [GameIdentity] = []
	var songIdentities: [SongIdentity] = []
	var studioIdentities: [StudioIdentity] = []
	var userIdentities: [UserIdentity] = []

	var characterNextPageCursor: PageCursor?
	var episodeNextPageCursor: PageCursor?
	var personNextPageCursor: PageCursor?
	var showNextPageCursor: PageCursor?
	var literatureNextPageCursor: PageCursor?
	var gameNextPageCursor: PageCursor?
	var songNextPageCursor: PageCursor?
	var studioNextPageCursor: PageCursor?
	var userNextPageCursor: PageCursor?

	var dataSource: UICollectionViewDiffableDataSource<SearchResults.Section, SearchResults.Item>!
	var snapshot: NSDiffableDataSourceSnapshot<SearchResults.Section, SearchResults.Item>!

	/// Observes local library mutations to refresh visible cells.
	private var libraryObserver: LocalLibraryEntryObserver?

	/// Observes playback changes so visible song cells reflect the currently-playing song.
	private var playbackObserver: AnyCancellable?

	/// Whether a fetch request is currently in progress.
	var isRequestInProgress: Bool = false

	/// The object containing the search controller.
	lazy var kSearchController: KSearchController = {
		if #available(iOS 16.0, *) {
			let suggestionsViewController = SearchTokenSuggestionsTableViewController()
			suggestionsViewController.onSelect = { [weak self] type in
				self?.handleTokenSuggestionSelected(type)
			}
			return KSearchController(searchResultsController: suggestionsViewController)
		}

		return KSearchController(searchResultsController: nil)
	}()

	/// The token suggestions controller hosted by ``kSearchController`` on iOS 16+.
	@available(iOS 16.0, *)
	private var tokenSuggestionsViewController: SearchTokenSuggestionsTableViewController? {
		return self.kSearchController.searchResultsController as? SearchTokenSuggestionsTableViewController
	}

	/// Whether to include a search controller in the navigation bar
	var includesSearchBar = true

	/// Whether the user was deep linked to this view
	var isDeepLinked = false

	// Refresh control
	var _prefersRefreshControlDisabled = false {
		didSet {
			self.setNeedsRefreshControlAppearanceUpdate()
		}
	}

	override var prefersRefreshControlDisabled: Bool {
		return self._prefersRefreshControlDisabled
	}

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}

	override var prefersActivityIndicatorHidden: Bool {
		return self._prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func themeWillReload() {
		super.themeWillReload()

		self.styleTabBarView()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = L10n.search

		// Disable Refresh Control & hide Activity Indicator
		self._prefersRefreshControlDisabled = true
		self._prefersActivityIndicatorHidden = true

		// Determine if search bar is included
		if self.includesSearchBar {
			self.setupSearchController()
		}

		// Configurations
		switch self.searchViewKind {
		case .single(let searchType):
			self.kSearchController.hidesNavigationBarDuringPresentation = false

			self.configureFilterBarButtonItem()

			if searchType != .songs {
				self.navigationItem.rightBarButtonItems = [self.filterBarButtonItem]
			}
		case .multiple:
			#if targetEnvironment(macCatalyst)
			self.configureFilterBarButtonItem()
			#endif
		case .library:
			self.kSearchController.hidesNavigationBarDuringPresentation = false
			self.currentScope = .library
			#if targetEnvironment(macCatalyst)
			self.configureFilterBarButtonItem()
			#endif
			self.title = L10n.searchLibrary

			if self.presentingViewController != nil || self.navigationController?.presentingViewController != nil {
				self.navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .close, primaryAction: UIAction { [weak self] _ in
					self?.dismiss(animated: true)
				})
			}
		}
		self.configureView()
		self.configureDataSource()
		self.observeLibraryChanges()
		self.observePlaybackChanges()

		switch self.searchViewKind {
		case .single(let type):
			// Fetch index
			self.performSearch(with: "", in: .kurozora, for: [type], with: self.searchFilters[type] as? SearchFilter, next: nil)
		case .multiple:
			// Fetch discover elements
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchSearchSuggestions()
				self.updateDataSource()
			}

			// Update data source
			self.updateDataSource()
		case .library:
			self.updateDataSource()
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		#if !targetEnvironment(macCatalyst)
		IQKeyboardManager.shared.isEnabled = false
		#endif

		if self.isDeepLinked {
			self.isDeepLinked = false
			self.performSearch(with: self.searchQuery, in: self.currentScope, for: self.currentTypes, with: nil, next: nil)
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		if case .library = self.searchViewKind {
			self.kSearchController.isActive = true
			DispatchQueue.main.async { [weak self] in
				self?.kSearchController.searchBar.becomeFirstResponder()
			}
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		#if !targetEnvironment(macCatalyst)
		IQKeyboardManager.shared.isEnabled = true
		#endif
	}

	// MARK: - Functions
	func configureFilterBarButtonItem() {
		self.filterBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle"), style: .plain, target: self, action: #selector(self.handleFilterBarButtonItemPressed(_:)))
	}

	/// Subscribes to local library mutations affecting the visible cells.
	private func observeLibraryChanges() {
		guard let slug = User.current?.attributes.slug else { return }
		self.libraryObserver = LocalLibraryEntryObserver(
			matching: LocalLibraryEntryObserver.matches(userSlug: slug),
			onChange: { [weak self] entry in
				self?.applyLibraryEntryChange(forTrackableID: entry.trackableID, userSlug: entry.userSlug, kind: entry.kind, isRemoval: false)
			},
			onRemove: { [weak self] removed in
				self?.applyLibraryEntryChange(forTrackableID: removed.trackableID, userSlug: removed.userSlug, kind: removed.kind, isRemoval: true)
			}
		)
	}

	/// Subscribes to playback changes so visible song cells reflect the currently playing song.
	private func observePlaybackChanges() {
		self.playbackObserver = Publishers.CombineLatest(MusicManager.shared.currentKKSongPublisher, MusicManager.shared.isPlayingPublisher)
			.receive(on: RunLoop.main)
			.sink { [weak self] _, _ in
				self?.refreshVisibleMusicCells()
			}
	}

	/// Refreshes the play button glyph and artwork of every visible song cell.
	private func refreshVisibleMusicCells() {
		for case let cell as MusicLockupCollectionViewCell in self.collectionView.visibleCells {
			guard
				let indexPath = self.collectionView.indexPath(for: cell),
				let song = self.fetchModel(at: indexPath) as Song?
			else { continue }
			cell.updatePlayButton(for: song)
			cell.updateArtwork(for: song, resolvedSong: song.attributes.amID.flatMap { self.resolvedSongs[$0] })
		}
	}

	/// Updates every search result whose underlying show/literature/game matches the given trackable identity.
	private func applyLibraryEntryChange(forTrackableID trackableID: String, userSlug: String, kind: LibraryKind, isRemoval: Bool) {
		var matchedItems: [SearchResults.Item] = []
		let currentSnapshot = self.dataSource.snapshot()

		for item in currentSnapshot.itemIdentifiers {
			switch (item, kind) {
			case (.show(let show), .shows) where show.id.rawValue == trackableID:
				matchedItems.append(item)
			case (.literature(let literature), .literatures) where literature.id.rawValue == trackableID:
				matchedItems.append(item)
			case (.game(let game), .games) where game.id.rawValue == trackableID:
				matchedItems.append(item)
			case (.showIdentity(let identity), .shows) where identity.id.rawValue == trackableID:
				if let indexPath = self.dataSource.indexPath(for: item),
				   let show = self.cache[indexPath] as? Show {
					matchedItems.append(item)
				}
			case (.literatureIdentity(let identity), .literatures) where identity.id.rawValue == trackableID:
				if let indexPath = self.dataSource.indexPath(for: item),
				   let literature = self.cache[indexPath] as? Literature {
					matchedItems.append(item)
				}
			case (.gameIdentity(let identity), .games) where identity.id.rawValue == trackableID:
				if let indexPath = self.dataSource.indexPath(for: item),
				   let game = self.cache[indexPath] as? Game {
					matchedItems.append(item)
				}
			default:
				break
			}
		}

		guard !matchedItems.isEmpty else { return }
		var snapshot = currentSnapshot
		snapshot.reconfigureItems(matchedItems)
		self.dataSource.apply(snapshot, animatingDifferences: false)
	}

	/// Returns the search types derived from the current tokens in the search field.
	@available(iOS 16.0, *)
	func typesFromTokens() -> [SearchType] {
		let tokens = self.kSearchController.searchBar.searchTextField.tokens
		return tokens.compactMap { $0.representedObject as? SearchType }
	}

	/// Returns the filter to forward when re-running a search.
	///
	/// - Parameter types: The requested search types, or empty when type resolution is deferred.
	///
	/// - Returns: The filter stored for the resolved type, or `nil` when none applies.
	func reusableFilter(for types: [SearchType]) -> SearchFilter? {
		let resolvedType: SearchType?

		if types.count == 1 {
			resolvedType = types.first
		} else if case let .single(type) = self.searchViewKind {
			resolvedType = type
		} else {
			resolvedType = self.searchTypes[safe: self.currentIndex]
		}

		guard let type = resolvedType else { return nil }
		return self.searchFilters[type] ?? nil
	}

	/// Returns the list of search types that are valid for the current search surface.
	func availableTypesForCurrentScope() -> [SearchType] {
		switch self.searchViewKind {
		case .single(let type):
			return [type]
		case .library:
			return [.shows, .literatures, .games]
		case .multiple:
			switch self.currentScope {
			case .library:
				return [.shows, .literatures, .games]
			case .kurozora:
				return [.shows, .literatures, .games, .episodes, .characters, .people, .songs, .studios, .users]
			}
		}
	}

	func configureView() {
		self.configureTabBarView()
		self.configureToolbar()
		self.configureViewHierarchy()
		self.configureViewConstraints()

		let tabBarBarButtonItem = UIBarButtonItem(customView: self.tabBarView)
		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			tabBarBarButtonItem.hidesSharedBackground = true
		}
		self.toolbar.setItems([tabBarBarButtonItem], animated: true)
	}

	func configureTabBarView() {
		self.tabBarView.delegate = self
		self.tabBarView.dataSource = self
		self.updateBar(to: 0.0, animated: false, direction: .none)
		self.styleTabBarView()
	}

	func updateBar(to position: CGFloat?, animated: Bool, direction: TMBarUpdateDirection) {
		let animation = TMAnimation(isEnabled: animated, duration: 0.25)
		self.tabBarView.update(for: position ?? 0.0, capacity: self.searchTypes.count, direction: .forward, animation: animation)
	}

	fileprivate func styleTabBarView() {
		// Background view
		self.tabBarView.backgroundView.style = .clear

		// Indicator
		self.tabBarView.indicator.layout(in: self.tabBarView)

		// Scrolling
		self.tabBarView.scrollMode = .interactive

		// State
		self.tabBarView.buttons.customize { button in
			button.contentInset = UIEdgeInsets(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0)
			button.selectedTintColor = KThemePicker.textColor.colorValue
			button.tintColor = button.selectedTintColor.withAlphaComponent(0.50)
		}

		// Layout
		self.tabBarView.layout.contentInset = UIEdgeInsets(top: 0.0, left: 0.2, bottom: 0.0, right: 0.0)
		self.tabBarView.layout.interButtonSpacing = 0.0
		self.tabBarView.layout.contentMode = .intrinsic

		// Style
		self.tabBarView.fadesContentEdges = true
	}

	func configureToolbar() {
		self.toolbar.translatesAutoresizingMaskIntoConstraints = false
		self.toolbar.delegate = self
		self.toolbar.isHidden = true
		self.toolbar.isTranslucent = false
		self.toolbar.backgroundColor = .clear
		self.toolbar.barStyle = .default
		self.toolbar.theme_tintColor = KThemePicker.tintColor.rawValue
		self.toolbar.theme_barTintColor = KThemePicker.barTintColor.rawValue

		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			let interaction = UIScrollEdgeElementContainerInteraction()
			interaction.scrollView = self.collectionView
			interaction.edge = .top
			self.toolbar.addInteraction(interaction)
		}
	}

	/// Setup the search controller with the desired settings.
	func setupSearchController() {
		// Set the current view as the view controller of the search
		self.kSearchController.viewController = self

		// Manual visibility control is required, so the suggestions controller can show with empty text.
		if #available(iOS 16.0, *) {
			self.kSearchController.automaticallyShowsSearchResultsController = false
		}

		// Add search bar to navigation controller
		self.navigationItem.searchController = self.kSearchController
		self.navigationItem.hidesSearchBarWhenScrolling = false

		#if !targetEnvironment(macCatalyst)
		if #available(iOS 16.0, *) {
			self.navigationItem.preferredSearchBarPlacement = .stacked
		}
		#endif
	}

	func configureViewHierarchy() {
		self.view.addSubview(self.toolbar)
	}

	func configureViewConstraints() {
		NSLayoutConstraint.activate([
			self.toolbar.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
			self.toolbar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.toolbar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.toolbar.heightAnchor.constraint(equalToConstant: 49.0),
		])

		self.tabBarView.fillToSuperview()
	}

	/// Perform search with the given search text and the search scope.
	///
	/// - Parameters:
	///    - query: The string which to search for.
	///    - searchScope: The scope in which the text should be searched.
	///    - types: The search types.
	///    - filter: The filter applied to the search request.
	///    - next: The URL string of the next page in the paginated response. Use nil to get first page.
	///    - resettingResults: Whether to reset the results.
	func performSearch(with query: String, in searchScope: SearchScope, for types: [SearchType], with filter: SearchFilter?, next: PageCursor?, resettingResults: Bool = true) {
		var searchScope = searchScope
		var types = types

		if case .library = self.searchViewKind {
			searchScope = .library
		}

		// Prepare view for search
		self.currentScope = searchScope

		// On iOS 16+, resolve types from tokens when none are explicitly provided.
		if #available(iOS 16.0, *), types.isEmpty {
			let tokenTypes = self.typesFromTokens()
			types = tokenTypes.isEmpty ? self.availableTypesForCurrentScope() : tokenTypes
		}

		if resettingResults {
			// Show activity indicator.
			self._prefersActivityIndicatorHidden = false

			// Reset results
			self.resetSearchResults(for: types.count > 1 ? nil : types.first)
		}

		// Decide with which endpoint to perform the search
		switch searchScope {
		case .kurozora:
			Task { [weak self] in
				guard let self = self else { return }
				let searchTypes: [SearchType]

				switch self.searchViewKind {
				case .single(let type):
					searchTypes = [type]
					self.searchTypes = searchTypes
				case .multiple:
					if #available(iOS 16.0, *) {
						searchTypes = types
					} else {
						searchTypes = self.searchResults != nil ? types : [.shows, .literatures, .games, .episodes, .characters, .people, .songs, .studios, .users]
					}
				case .library:
					return
				}

				await self.search(scope: searchScope, types: searchTypes, query: query, next: next, filter: filter)
			}
		case .library:
			Task { [weak self] in
				guard let self = self else { return }
				let signedIn = await WorkflowController.shared.isSignedIn(on: self)
				guard signedIn else { return }
				guard let userSlug = User.current?.attributes.slug else { return }

				let searchTypes: [SearchType]
				if #available(iOS 16.0, *) {
					searchTypes = types
				} else {
					searchTypes = self.searchResults != nil ? types : [.shows, .literatures, .games]
				}

				await self.searchLocalLibrary(types: searchTypes, query: query, userSlug: userSlug)
			}
		}
	}

	/// Performs the library scope's search against the local store.
	///
	/// - Parameters:
	///    - types: The library kinds (`shows`/`literatures`/`games`) to search.
	///    - query: The trimmed search query.
	///    - userSlug: The signed-in user's account slug.
	fileprivate func searchLocalLibrary(types: [SearchType], query: String, userSlug: String) async {
		guard !self.isRequestInProgress else { return }
		self.isRequestInProgress = true
		self.searchQuery = query

		let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
		if trimmed.isEmpty {
			self.isRequestInProgress = false
			self._prefersActivityIndicatorHidden = true
			return
		}

		for type in types {
			let kind: LibraryKind
			switch type {
			case .shows:
				kind = .shows
			case .literatures:
				kind = .literatures
			case .games:
				kind = .games
			default:
				continue
			}

			let entries = LibraryStore.shared.search(
				forUserSlug: userSlug,
				kind: kind,
				query: trimmed,
				sortType: .alphabetically,
				sortOption: .ascending,
				offset: 0,
				limit: 100
			)

			switch kind {
			case .shows:
				let identities = entries.map { ShowIdentity(id: KurozoraItemID($0.trackableID)) }
				self.showIdentities.appendDistinct(contentsOf: identities)
				self.showNextPageCursor = nil
			case .literatures:
				let identities = entries.map { LiteratureIdentity(id: KurozoraItemID($0.trackableID)) }
				self.literatureIdentities.appendDistinct(contentsOf: identities)
				self.literatureNextPageCursor = nil
			case .games:
				let identities = entries.map { GameIdentity(id: KurozoraItemID($0.trackableID)) }
				self.gameIdentities.appendDistinct(contentsOf: identities)
				self.gameNextPageCursor = nil
			}
		}

		if types.count > 1 {
			self.searchTypes = self.determineLocalResultTypes()
			#if targetEnvironment(macCatalyst)
			self.navigationItem.rightBarButtonItems = [self.filterBarButtonItem]
			#else
			self.kSearchController.searchBar.setShowsScope(false, animated: true)
			self.kSearchController.searchBar.showsBookmarkButton = true
			#endif
			self.setShowToolbar(true)
		} else {
			self.searchTypes = types
		}

		self.updateDataSource()
		await self.prefetchCurrentSections()

		self.isRequestInProgress = false
		self._prefersActivityIndicatorHidden = true
	}

	/// Returns the non-empty library result types after a local search.
	fileprivate func determineLocalResultTypes() -> [SearchType] {
		var resultTypes: [SearchType] = []
		if !self.showIdentities.isEmpty { resultTypes.append(.shows) }
		if !self.literatureIdentities.isEmpty { resultTypes.append(.literatures) }
		if !self.gameIdentities.isEmpty { resultTypes.append(.games) }
		return resultTypes
	}

	fileprivate func search(scope: SearchScope, types: [SearchType], query: String, next: PageCursor?, filter: SearchFilter?) async {
		guard !self.isRequestInProgress else {
			return
		}

		// Set request in progress
		self.isRequestInProgress = true

		// Store search query
		self.searchQuery = query

		do {
			// Perform library search request.
			let searchResponse = try await KService.search(scope, types: types, query: query).cursor(next).limit(next != nil ? 100 : 25).filter(filter).response()

			if types.count > 1 {
				self.searchResults = searchResponse.data

				self.characterNextPageCursor = searchResponse.data.characters?.nextCursor ?? self.characterNextPageCursor
				self.episodeNextPageCursor = searchResponse.data.episodes?.nextCursor ?? self.episodeNextPageCursor
				self.personNextPageCursor = searchResponse.data.people?.nextCursor ?? self.personNextPageCursor
				self.showNextPageCursor = searchResponse.data.shows?.nextCursor ?? self.showNextPageCursor
				self.literatureNextPageCursor = searchResponse.data.literatures?.nextCursor ?? self.literatureNextPageCursor
				self.gameNextPageCursor = searchResponse.data.games?.nextCursor ?? self.gameNextPageCursor
				self.songNextPageCursor = searchResponse.data.songs?.nextCursor ?? self.songNextPageCursor
				self.studioNextPageCursor = searchResponse.data.studios?.nextCursor ?? self.studioNextPageCursor
				self.userNextPageCursor = searchResponse.data.users?.nextCursor ?? self.userNextPageCursor

				self.characterIdentities.appendDistinct(contentsOf: searchResponse.data.characters?.data ?? [])
				self.episodeIdentities.appendDistinct(contentsOf: searchResponse.data.episodes?.data ?? [])
				self.personIdentities.appendDistinct(contentsOf: searchResponse.data.people?.data ?? [])
				self.showIdentities.appendDistinct(contentsOf: searchResponse.data.shows?.data ?? [])
				self.literatureIdentities.appendDistinct(contentsOf: searchResponse.data.literatures?.data ?? [])
				self.gameIdentities.appendDistinct(contentsOf: searchResponse.data.games?.data ?? [])
				self.songIdentities.appendDistinct(contentsOf: searchResponse.data.songs?.data ?? [])
				self.studioIdentities.appendDistinct(contentsOf: searchResponse.data.studios?.data ?? [])
				self.userIdentities.appendDistinct(contentsOf: searchResponse.data.users?.data ?? [])

				// Determine search types
				self.searchTypes = self.determineResultTypes()

				// Update search bar
				#if targetEnvironment(macCatalyst)
				self.navigationItem.rightBarButtonItems = [self.filterBarButtonItem]
				#else
				self.kSearchController.searchBar.setShowsScope(false, animated: true)
				self.kSearchController.searchBar.showsBookmarkButton = true
				#endif
				self.setShowToolbar(true)
			} else if let searchType = types.first {
				switch searchType {
				case .characters:
					self.characterNextPageCursor = searchResponse.data.characters?.nextCursor
					self.characterIdentities.appendDistinct(contentsOf: searchResponse.data.characters?.data ?? [])
				case .episodes:
					self.episodeNextPageCursor = searchResponse.data.episodes?.nextCursor
					self.episodeIdentities.appendDistinct(contentsOf: searchResponse.data.episodes?.data ?? [])
				case .games:
					self.gameNextPageCursor = searchResponse.data.games?.nextCursor
					self.gameIdentities.appendDistinct(contentsOf: searchResponse.data.games?.data ?? [])
				case .literatures:
					self.literatureNextPageCursor = searchResponse.data.literatures?.nextCursor
					self.literatureIdentities.appendDistinct(contentsOf: searchResponse.data.literatures?.data ?? [])
				case .people:
					self.personNextPageCursor = searchResponse.data.people?.nextCursor
					self.personIdentities.appendDistinct(contentsOf: searchResponse.data.people?.data ?? [])
				case .shows:
					self.showNextPageCursor = searchResponse.data.shows?.nextCursor
					self.showIdentities.appendDistinct(contentsOf: searchResponse.data.shows?.data ?? [])
				case .songs:
					self.songNextPageCursor = searchResponse.data.songs?.nextCursor
					self.songIdentities.appendDistinct(contentsOf: searchResponse.data.songs?.data ?? [])
				case .studios:
					self.studioNextPageCursor = searchResponse.data.studios?.nextCursor
					self.studioIdentities.appendDistinct(contentsOf: searchResponse.data.studios?.data ?? [])
				case .users:
					self.userNextPageCursor = searchResponse.data.users?.nextCursor
					self.userIdentities.appendDistinct(contentsOf: searchResponse.data.users?.data ?? [])
				}

				// Reflect a fresh single-type query in the tab bar. Pagination and filter
				// refreshes target the currently selected tab and must leave the tab set alone.
				if next == nil, filter == nil {
					switch self.searchViewKind {
					case .multiple, .library:
						self.searchTypes = types
					case .single:
						break
					}
				}
			}

			// Update data source.
			self.updateDataSource()

			await self.prefetchCurrentSections()
		} catch {
			print(error.localizedDescription)
		}

		self.isRequestInProgress = false

		// Hide activity indicator.
		self._prefersActivityIndicatorHidden = true
	}

	/// Fetches the details for every section currently in the data source.
	fileprivate func prefetchCurrentSections() async {
		let snapshot = self.dataSource.snapshot()
		for section in snapshot.sectionIdentifiers {
			await self.prefetch(section: section, snapshot: snapshot)
		}
	}

	/// Fetches the details for the items in the given section.
	///
	/// - Parameters:
	///    - section: The section to fetch.
	///    - snapshot: The snapshot whose items are inspected.
	fileprivate func prefetch(section: SearchResults.Section, snapshot: NSDiffableDataSourceSnapshot<SearchResults.Section, SearchResults.Item>) async {
		let items = snapshot.itemIdentifiers(inSection: section)
		guard let sectionIndex = snapshot.indexOfSection(section) else { return }

		guard let firstUncachedOffset = items.indices.first(where: { offset in
			self.cache[IndexPath(item: offset, section: sectionIndex)] == nil
		}) else { return }
		let indexPath = IndexPath(item: firstUncachedOffset, section: sectionIndex)
		let itemKind = items[firstUncachedOffset]

		switch section {
		case .characters:
			await self.fetchSectionIfNeeded(ResourceCollection<Character>.self, CharacterIdentity.self, at: indexPath, itemKind: itemKind)
		case .episodes:
			await self.fetchSectionIfNeeded(ResourceCollection<Episode>.self, EpisodeIdentity.self, at: indexPath, itemKind: itemKind)
		case .games:
			await self.fetchSectionIfNeeded(ResourceCollection<Game>.self, GameIdentity.self, at: indexPath, itemKind: itemKind)
		case .literatures:
			await self.fetchSectionIfNeeded(ResourceCollection<Literature>.self, LiteratureIdentity.self, at: indexPath, itemKind: itemKind)
		case .people:
			await self.fetchSectionIfNeeded(ResourceCollection<Person>.self, PersonIdentity.self, at: indexPath, itemKind: itemKind)
		case .shows:
			await self.fetchSectionIfNeeded(ResourceCollection<Show>.self, ShowIdentity.self, at: indexPath, itemKind: itemKind)
		case .songs:
			await self.fetchSongsSection(at: indexPath, itemKind: itemKind, sectionIndex: sectionIndex, itemCount: items.count)
		case .studios:
			await self.fetchSectionIfNeeded(ResourceCollection<Studio>.self, StudioIdentity.self, at: indexPath, itemKind: itemKind)
		case .users:
			await self.fetchSectionIfNeeded(ResourceCollection<User>.self, UserIdentity.self, at: indexPath, itemKind: itemKind)
		case .discover, .browse:
			break
		}
	}

	/// Fetches the details for the songs section and preloads the corresponding Apple Music entries.
	///
	/// - Parameters:
	///    - indexPath: The first index path of the songs section.
	///    - itemKind: The item at `indexPath`.
	///    - sectionIndex: The index of the songs section in the snapshot.
	///    - itemCount: The number of items in the songs section.
	fileprivate func fetchSongsSection(at indexPath: IndexPath, itemKind: SearchResults.Item, sectionIndex: Int, itemCount: Int) async {
		await self.fetchSectionIfNeeded(ResourceCollection<Song>.self, SongIdentity.self, at: indexPath, itemKind: itemKind)

		let appleMusicIDs: [Int] = (0 ..< itemCount).compactMap { offset in
			let ip = IndexPath(item: offset, section: sectionIndex)
			return (self.fetchModel(at: ip) as Song?)?.attributes.amID
		}
		if !appleMusicIDs.isEmpty {
			_ = await MusicManager.shared.getSongs(for: appleMusicIDs)
		}
	}

	fileprivate func determineResultTypes() -> [SearchType] {
		guard let searchResults = self.searchResults else { return [] }
		var resultTypes: [SearchType] = []

		if !(searchResults.shows?.data.isEmpty ?? true) {
			resultTypes.append(.shows)
		}
		if !(searchResults.literatures?.data.isEmpty ?? true) {
			resultTypes.append(.literatures)
		}
		if !(searchResults.games?.data.isEmpty ?? true) {
			resultTypes.append(.games)
		}
		if !(searchResults.episodes?.data.isEmpty ?? true) {
			resultTypes.append(.episodes)
		}
		if !(searchResults.characters?.data.isEmpty ?? true) {
			resultTypes.append(.characters)
		}
		if !(searchResults.people?.data.isEmpty ?? true) {
			resultTypes.append(.people)
		}
		if !(searchResults.songs?.data.isEmpty ?? true) {
			resultTypes.append(.songs)
		}
		if !(searchResults.studios?.data.isEmpty ?? true) {
			resultTypes.append(.studios)
		}
		if !(searchResults.users?.data.isEmpty ?? true) {
			resultTypes.append(.users)
		}

		return resultTypes
	}

	/// Clears the identities, pagination cursor, and cached models for the given type.
	///
	/// - Parameter type: The search type to reset, or `nil` to reset every type.
	fileprivate func resetSearchResults(for type: SearchType?) {
		if let type = type {
			switch type {
			case .characters:
				self.characterIdentities = []
				self.characterNextPageCursor = nil
			case .episodes:
				self.episodeIdentities = []
				self.episodeNextPageCursor = nil
			case .games:
				self.gameIdentities = []
				self.gameNextPageCursor = nil
			case .literatures:
				self.literatureIdentities = []
				self.literatureNextPageCursor = nil
			case .people:
				self.personIdentities = []
				self.personNextPageCursor = nil
			case .shows:
				self.showIdentities = []
				self.showNextPageCursor = nil
			case .songs:
				self.songIdentities = []
				self.songNextPageCursor = nil
			case .studios:
				self.studioIdentities = []
				self.studioNextPageCursor = nil
			case .users:
				self.userIdentities = []
				self.userNextPageCursor = nil
			}

			self.cachesByType[type] = nil
		} else {
			self.currentIndex = 0
			self.searchResults = nil

			self.characterIdentities = []
			self.episodeIdentities = []
			self.personIdentities = []
			self.showIdentities = []
			self.literatureIdentities = []
			self.gameIdentities = []
			self.songIdentities = []
			self.studioIdentities = []
			self.userIdentities = []

			self.characterNextPageCursor = nil
			self.episodeNextPageCursor = nil
			self.personNextPageCursor = nil
			self.showNextPageCursor = nil
			self.literatureNextPageCursor = nil
			self.gameNextPageCursor = nil
			self.songNextPageCursor = nil
			self.studioNextPageCursor = nil
			self.userNextPageCursor = nil

			self.cachesByType.removeAll()
		}

		self.updateDataSource()
	}

	func fetchSearchSuggestions() async {
		do {
			let alphabet = "abcdefghijklmnopqrstuvwxyz"
			let suggestionString = String(alphabet.randomElement() ?? "o")
			let searchSuggestionResponse = try await KService.searchSuggestions(.kurozora, types: [.shows], query: suggestionString).response()
			self.discoverSuggestions = searchSuggestionResponse.data.map { searchSuggestion in
				QuickLink(title: searchSuggestion, image: UIImage(systemName: "magnifyingglass"), url: "")
			}
		} catch {
			print(error.localizedDescription)
		}
	}

	func setShowToolbar(_ show: Bool) {
		if show {
			self.currentTopContentInset = self.collectionView.contentInset.top
		}

		self.collectionView.contentInset.top = show ? 62.0 : self.currentTopContentInset
		self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset

		self.toolbar.isHidden = !show
	}

	func getSearchFilterCollectionViewController() -> SearchFilterCollectionViewController? {
		guard let searchType = self.searchTypes[safe: self.currentIndex] else { return nil }
		let searchFilterViewController = SearchFilterCollectionViewController()
		searchFilterViewController.delegate = self
		searchFilterViewController.searchType = searchType
		searchFilterViewController.filter = self.searchFilters[searchType] ?? nil
		return searchFilterViewController
	}

	@objc func handleFilterBarButtonItemPressed(_ sender: UIBarButtonItem) {
		guard let searchFilterCollectionViewController = self.getSearchFilterCollectionViewController() else { return }
		let kNavigationController = KNavigationController(rootViewController: searchFilterCollectionViewController)
		kNavigationController.modalPresentationStyle = .popover
		kNavigationController.popoverPresentationController?.barButtonItem = sender
		kNavigationController.navigationBar.prefersLargeTitles = false

		self.present(kNavigationController, animated: true)
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .searchSegue: return SearchResultsCollectionViewController()
		case .characterDetailsSegue: return CharacterDetailsCollectionViewController()
		case .episodeDetailsSegue: return EpisodeDetailsCollectionViewController()
		case .literatureDetailsSegue: return LiteratureDetailsCollectionViewController()
		case .gameDetailsSegue: return GameDetailsCollectionViewController()
		case .personDetailsSegue: return PersonDetailsCollectionViewController()
		case .showDetailsSegue: return ShowDetailsCollectionViewController()
		case .songDetailsSegue: return SongDetailsCollectionViewController()
		case .studioDetailsSegue: return StudioDetailsCollectionViewController()
		case .userDetailsSegue: return ProfileTableViewController()
		case .charactersListSegue: return CharactersListCollectionViewController()
		case .episodesListSegue: return EpisodesListCollectionViewController()
		case .literaturesListSegue: return LiteraturesListCollectionViewController()
		case .gamesListSegue: return GamesListCollectionViewController()
		case .peopleListSegue: return PeopleListCollectionViewController()
		case .songsListSegue: return ShowSongsListCollectionViewController()
		case .showsListSegue: return ShowsListCollectionViewController()
		case .studiosListSegue: return StudiosListCollectionViewController()
		case .usersListSegue: return UsersListCollectionViewController()
		case .scheduleSegue: return ScheduleCollectionViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .searchSegue:
			// Segue to character details
			guard let searchResultsCollectionViewController = destination as? SearchResultsCollectionViewController else { return }
			guard let browseCategory = sender as? BrowseCategory else { return }
			guard let searchType = browseCategory.searchType else { return }
			searchResultsCollectionViewController.title = browseCategory.title
			searchResultsCollectionViewController.searchViewKind = .single(searchType)
		case .characterDetailsSegue:
			// Segue to character details
			guard let characterDetailCollectionViewController = destination as? CharacterDetailsCollectionViewController else { return }
			guard let character = sender as? Character else { return }
			characterDetailCollectionViewController.character = character
		case .episodeDetailsSegue:
			// Segue to episode details
			guard let episodeDetailsCollectionViewController = destination as? EpisodeDetailsCollectionViewController else { return }
			guard let episode = sender as? Episode else { return }
			episodeDetailsCollectionViewController.episode = episode
		case .literatureDetailsSegue:
			// Segue to literature details
			guard let literatureDetailCollectionViewController = destination as? LiteratureDetailsCollectionViewController else { return }
			guard let literature = sender as? Literature else { return }
			literatureDetailCollectionViewController.literature = literature
		case .gameDetailsSegue:
			// Segue to game details
			guard let gameDetailCollectionViewController = destination as? GameDetailsCollectionViewController else { return }
			guard let game = sender as? Game else { return }
			gameDetailCollectionViewController.game = game
		case .personDetailsSegue:
			// Segue to person details
			guard let personDetailCollectionViewController = destination as? PersonDetailsCollectionViewController else { return }
			guard let person = sender as? Person else { return }
			personDetailCollectionViewController.person = person
		case .showDetailsSegue:
			// Segue to show details
			guard let showDetailsCollectionViewController = destination as? ShowDetailsCollectionViewController else { return }
			if let show = sender as? Show {
				showDetailsCollectionViewController.show = show
			} else if let showIdentity = sender as? ShowIdentity {
				showDetailsCollectionViewController.showIdentity = showIdentity
			}
		case .songDetailsSegue:
			// Segue to studio details
			guard let songDetailCollectionViewController = destination as? SongDetailsCollectionViewController else { return }
			guard let song = sender as? Song else { return }
			songDetailCollectionViewController.song = song
		case .studioDetailsSegue:
			// Segue to studio details
			guard let studioDetailCollectionViewController = destination as? StudioDetailsCollectionViewController else { return }
			guard let studio = sender as? Studio else { return }
			studioDetailCollectionViewController.studio = studio
		case .userDetailsSegue:
			// Segue to user details
			guard let profileTableViewController = destination as? ProfileTableViewController else { return }
			guard let user = sender as? User else { return }
			profileTableViewController.user = user
		case .charactersListSegue:
			// Segue to characters list
			guard let charactersListCollectionViewController = destination as? CharactersListCollectionViewController else { return }
			charactersListCollectionViewController.searchQuery = self.searchQuery
			charactersListCollectionViewController.charactersListFetchType = .search
		case .episodesListSegue:
			// Segue to episodes list
			guard let episodesListCollectionViewController = destination as? EpisodesListCollectionViewController else { return }

			if let season = sender as? Season {
				episodesListCollectionViewController.season = season
			} else if let seasonIdentity = sender as? SeasonIdentity {
				episodesListCollectionViewController.seasonIdentity = seasonIdentity
			} else {
				episodesListCollectionViewController.searchQuery = self.searchQuery
			}

			episodesListCollectionViewController.episodesListFetchType = .season
		case .literaturesListSegue:
			// Segue to literatures list
			guard let literaturesListCollectionViewController = destination as? LiteraturesListCollectionViewController else { return }
			literaturesListCollectionViewController.searchQuery = self.searchQuery
			literaturesListCollectionViewController.literaturesListFetchType = .search
		case .gamesListSegue:
			// Segue to games list
			guard let gamesListCollectionViewController = destination as? GamesListCollectionViewController else { return }
			gamesListCollectionViewController.searchQuery = self.searchQuery
			gamesListCollectionViewController.gamesListFetchType = .search
		case .peopleListSegue:
			// Segue to people list
			guard let peopleListCollectionViewController = destination as? PeopleListCollectionViewController else { return }
			peopleListCollectionViewController.searchQuery = self.searchQuery
			peopleListCollectionViewController.peopleListFetchType = .search
		case .songsListSegue:
			// Segue to songs list
			guard let showSongsListCollectionViewController = destination as? ShowSongsListCollectionViewController else { return }
			let snapshot = self.dataSource.snapshot()
			if let songsSectionIndex = snapshot.indexOfSection(.songs) {
				let items = snapshot.itemIdentifiers(inSection: .songs)
				showSongsListCollectionViewController.songs = items.indices.compactMap { offset in
					self.fetchModel(at: IndexPath(item: offset, section: songsSectionIndex)) as Song?
				}
			}
		case .showsListSegue:
			// Segue to shows list
			guard let showsListCollectionViewController = destination as? ShowsListCollectionViewController else { return }
			showsListCollectionViewController.searchQuery = self.searchQuery
			showsListCollectionViewController.showsListFetchType = .search
		case .studiosListSegue:
			// Segue to studios list
			guard let studiosListCollectionViewController = destination as? StudiosListCollectionViewController else { return }
			studiosListCollectionViewController.searchQuery = self.searchQuery
			studiosListCollectionViewController.studiosListFetchType = .search
		case .usersListSegue:
			// Segue to users list
			guard let usersListCollectionViewController = destination as? UsersListCollectionViewController else { return }
			usersListCollectionViewController.searchQuery = self.searchQuery
			usersListCollectionViewController.usersListFetchType = .search
		case .scheduleSegue: break
		}
	}
}

// MARK: - TMBarDataSource
extension SearchResultsCollectionViewController: TMBarDataSource {
	func reloadView() {
		guard self.searchTypes.count > 0 else { return }
		self.tabBarView.reloadData(at: 0 ... self.searchTypes.count - 1, context: .full)
		// Keep the bar's visual selection in sync with `currentIndex`. A fresh search resets
		// `currentIndex` to 0 but the bar would otherwise keep its previous selection,
		// leaving the highlighted tab and the rendered section out of sync.
		self.updateBar(to: CGFloat(self.currentIndex), animated: false, direction: .none)
	}

	func barItem(for bar: Tabman.TMBar, at index: Int) -> Tabman.TMBarItemable {
		return TMBarItem(title: self.searchTypes[index].stringValue)
	}
}

// MARK: - TMBarDelegate
extension SearchResultsCollectionViewController: TMBarDelegate {
	func bar(_ bar: Tabman.TMBar, didRequestScrollTo index: Int) {
		let direction = TMBarUpdateDirection.forPage(index, previousPage: self.currentIndex)
		self.updateBar(to: CGFloat(index), animated: true, direction: direction)

		self.currentIndex = index

		guard let searchType = self.searchTypes[safe: self.currentIndex] else { return }

		switch searchType {
		case .songs, .users:
			self.kSearchController.searchBar.showsBookmarkButton = false
		default:
			self.kSearchController.searchBar.showsBookmarkButton = true
			if self.searchFilters[searchType] != nil {
				self.kSearchController.searchBar.setImage(UIImage(systemName: "line.3.horizontal.decrease.circle.fill"), for: .bookmark, state: .normal)
			} else {
				self.kSearchController.searchBar.setImage(UIImage(systemName: "line.3.horizontal.decrease.circle"), for: .bookmark, state: .normal)
			}
		}

		self.updateDataSource()
		Task { [weak self] in await self?.prefetchCurrentSections() }
	}
}

extension TMBarUpdateDirection {
	static func forPage(_ page: Int, previousPage: Int) -> TMBarUpdateDirection {
		return self.forPosition(CGFloat(page), previous: CGFloat(previousPage))
	}

	static func forPosition(_ position: CGFloat, previous previousPosition: CGFloat) -> TMBarUpdateDirection {
		if position == previousPosition {
			return .none
		}
		return position > previousPosition ? .forward : .reverse
	}
}

// MARK: - UISearchBarDelegate
extension SearchResultsCollectionViewController: UISearchBarDelegate {
	func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
		if #available(iOS 16.0, *), self.tokenSuggestionsViewController?.isTrackingSuggestionTap == true {
			return false
		}

		return true
	}

	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		// Search-as-you-type only applies to library scope.
		guard self.currentScope == .library else { return }

		self.libraryAsYouTypeWorkItem?.cancel()
		guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
			self.resetSearchResults(for: nil)
			self.updateDataSource()
			return
		}

		let workItem = DispatchWorkItem { [weak self] in
			guard let self = self else { return }

			let types: [SearchType]
			if #available(iOS 16.0, *) {
				let tokenTypes = self.typesFromTokens()
				types = tokenTypes.isEmpty ? self.availableTypesForCurrentScope() : tokenTypes
			} else {
				types = self.availableTypesForCurrentScope()
			}

			self.performSearch(with: searchText, in: .library, for: types, with: self.reusableFilter(for: types), next: nil)
		}
		self.libraryAsYouTypeWorkItem = workItem
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: workItem)
	}

	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		switch self.searchViewKind {
		case .single:
			break
		case .multiple:
			#if targetEnvironment(macCatalyst)
			self.navigationItem.rightBarButtonItems = []
			#else
			searchBar.setShowsScope(true, animated: true)
			searchBar.showsBookmarkButton = false
			#endif
			self.setShowToolbar(false)
		case .library:
			#if targetEnvironment(macCatalyst)
			self.navigationItem.rightBarButtonItems = []
			#else
			searchBar.showsBookmarkButton = false
			#endif
			self.setShowToolbar(false)
		}

		if #available(iOS 16.0, *) {
			self.refreshTokenSuggestions()
		}
	}

	/// Whether the current surface supports token suggestions.
	fileprivate var shouldOfferTokenSuggestions: Bool {
		switch self.searchViewKind {
		case .multiple, .library:
			return true
		case .single:
			return false
		}
	}

	func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
		#if !targetEnvironment(macCatalyst)
		searchBar.setShowsScope(false, animated: true)
		#endif

		if self.searchResults != nil {
			switch self.searchViewKind {
			case .single:
				break
			case .multiple:
				#if targetEnvironment(macCatalyst)
				self.navigationItem.rightBarButtonItems = [self.filterBarButtonItem]
				#else
				searchBar.showsBookmarkButton = true
				#endif
				self.setShowToolbar(true)
			case .library:
				#if targetEnvironment(macCatalyst)
				self.navigationItem.rightBarButtonItems = [self.filterBarButtonItem]
				#else
				searchBar.showsBookmarkButton = true
				#endif
				self.setShowToolbar(true)
			}
		}
	}

	func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
		guard let searchScope = SearchScope(rawValue: selectedScope) else { return }

		// Drop tokens whose type is no longer valid for the new scope (iOS 16+).
		if #available(iOS 16.0, *), searchScope == .library {
			let allowed: Set<SearchType> = [.shows, .literatures, .games]
			let textField = searchBar.searchTextField
			for index in textField.tokens.indices.reversed() {
				let token = textField.tokens[index]
				if let type = token.representedObject as? SearchType, !allowed.contains(type) {
					textField.removeToken(at: index)
				}
			}
		}

		let previousScope = self.currentScope
		self.currentScope = searchScope
		self.updateDataSource()

		if #available(iOS 16.0, *) {
			self.refreshTokenSuggestions()
		}

		// Composition phase: no network request.
		guard self.searchResults != nil, let query = searchBar.text, !query.isEmpty else { return }
		let filter = self.reusableFilter(for: [])

		switch searchScope {
		case .kurozora:
			self.performSearch(with: query, in: searchScope, for: [], with: filter, next: nil)
		case .library:
			Task { [weak self] in
				guard let self = self else { return }
				let signedIn = await WorkflowController.shared.isSignedIn(on: self)
				guard signedIn else {
					self.currentScope = previousScope
					searchBar.selectedScopeButtonIndex = previousScope.rawValue
					return
				}
				self.performSearch(with: query, in: searchScope, for: [], with: filter, next: nil)
			}
		}
	}

	func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
		guard let searchFilterCollectionViewController = self.getSearchFilterCollectionViewController() else { return }

		let kNavigationController = KNavigationController(rootViewController: searchFilterCollectionViewController)
		self.present(kNavigationController, animated: true)
	}

	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		guard let searchScope = SearchScope(rawValue: searchBar.selectedScopeButtonIndex) else { return }
		guard let query = searchBar.text else { return }

		var types: [SearchType] = []
		if #available(iOS 16.0, *) {
			types = self.typesFromTokens()
			self.kSearchController.showsSearchResultsController = false
		}
		self.performSearch(with: query, in: searchScope, for: types, with: self.reusableFilter(for: types), next: nil)
	}

	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		if #available(iOS 16.0, *) {
			searchBar.searchTextField.tokens.indices.reversed().forEach { searchBar.searchTextField.removeToken(at: $0) }
			self.kSearchController.showsSearchResultsController = false
		}

		switch self.searchViewKind {
		case .single(let type):
			self.performSearch(with: "", in: .kurozora, for: [type], with: self.searchFilters[type] as? SearchFilter, next: nil)
		case .multiple:
			#if targetEnvironment(macCatalyst)
			self.navigationItem.rightBarButtonItems = []
			#else
			searchBar.showsBookmarkButton = false
			#endif
			self.setShowToolbar(false)
			self.resetSearchResults(for: nil)
		case .library:
			#if targetEnvironment(macCatalyst)
			self.navigationItem.rightBarButtonItems = []
			#else
			searchBar.showsBookmarkButton = false
			#endif
			self.setShowToolbar(false)
			self.resetSearchResults(for: nil)
		}
	}
}

// MARK: - BaseLockupCollectionViewCellDelegate
extension SearchResultsCollectionViewController: BaseLockupCollectionViewCellDelegate {
	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressReminder button: UIButton) async {}

	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressStatus button: UIButton) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard signedIn else { return }
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		let target: any Libraryable

		switch cell.libraryKind {
		case .shows:
			guard let show: Show = self.fetchModel(at: indexPath) else { return }
			target = show
		case .literatures:
			guard let literature: Literature = self.fetchModel(at: indexPath) else { return }
			target = literature
		case .games:
			guard let game: Game = self.fetchModel(at: indexPath) else { return }
			target = game
		}

		let oldLibraryStatus = cell.libraryStatus
		let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: LibraryStatus.alertControllerItems(for: cell.libraryKind), currentSelection: oldLibraryStatus, action: { title, value in
			Task {
				await target.addToLibrary(status: value)
				cell.libraryStatus = value
				button.setTitle("\(title) ▾", for: .normal)
			}
		})

		if cell.libraryStatus != .none {
			actionSheetAlertController.addAction(UIAlertAction(title: L10n.removeFromLibrary, style: .destructive, handler: { _ in
				Task {
					await target.removeFromLibrary()
					cell.libraryStatus = .none
					button.setTitle(L10n.add.uppercased(with: Locale.current), for: .normal)
				}
			}))
		}

		// Present the controller
		if let popoverController = actionSheetAlertController.popoverPresentationController {
			popoverController.sourceView = button
			popoverController.sourceRect = button.bounds
		}

		if (self.navigationController?.visibleViewController as? UIAlertController) == nil {
			self.present(actionSheetAlertController, animated: true, completion: nil)
		}
	}
}

// MARK: - TitleHeaderCollectionReusableViewDelegate
extension SearchResultsCollectionViewController: TitleHeaderCollectionReusableViewDelegate {
	func titleHeaderCollectionReusableView(_ reusableView: TitleHeaderCollectionReusableView, didPress button: UIButton) {
		guard let segueID = reusableView.segueID else { return }
		self.show(segueID, sender: reusableView.indexPath)
	}
}

// MARK: - UserLockupCollectionViewCellDelegate
extension SearchResultsCollectionViewController: UserLockupCollectionViewCellDelegate {
	func userLockupCollectionViewCell(_ cell: UserLockupCollectionViewCell, didPressFollow button: UIButton) {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		guard let user: User = self.fetchModel(at: indexPath) else { return }

		Task {
			do {
				let userIdentity = UserIdentity(id: user.id)
				let followUpdateResponse = try await KService.toggleFollow(userIdentity).response()
				user.attributes.update(using: followUpdateResponse.data)
				cell.updateFollowButton(using: followUpdateResponse.data.followStatus)
			} catch {
				print("-----", error.localizedDescription)
			}
		}
	}
}

// MARK: - EpisodeLockupCollectionViewCellDelegate
extension SearchResultsCollectionViewController: EpisodeLockupCollectionViewCellDelegate {
	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressWatchStatusButton button: UIButton) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard signedIn else { return }
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }

		cell.watchStatusButton.isEnabled = false
		await (self.fetchModel(at: indexPath) as Episode?)?.updateWatchStatus(userInfo: ["indexPath": indexPath])
		cell.watchStatusButton.isEnabled = true
	}

	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressShowButton button: UIButton) {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		guard let showIdentity = (self.fetchModel(at: indexPath) as Episode?)?.relationships?.shows?.data.first else { return }

		self.show(.showDetailsSegue, sender: showIdentity)
	}

	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressSeasonButton button: UIButton) {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		guard let seasonIdentity = (self.fetchModel(at: indexPath) as Episode?)?.relationships?.seasons?.data.first else { return }

		self.show(.episodesListSegue, sender: seasonIdentity)
	}
}

// MARK: - MusicLockupCollectionViewCellDelegate
extension SearchResultsCollectionViewController: MusicLockupCollectionViewCellDelegate {
	func showButtonPressed(_ sender: UIButton, indexPath: IndexPath) {}

	func musicLockupCollectionViewCell(_ cell: MusicLockupCollectionViewCell, didTapPlayButtonAt indexPath: IndexPath) {
		(self.fetchModel(at: indexPath) as Song?)?.play()
	}

	/// Resolves and caches the Apple Music song for the given Kurozora song.
	///
	/// - Parameter song: The Kurozora song to resolve.
	func resolveMusicSong(_ song: KKSong) {
		guard let appleMusicID = song.attributes.amID, self.resolvedSongs[appleMusicID] == nil else { return }

		Task { [weak self] in
			self?.resolvedSongs[appleMusicID] = await MusicManager.shared.getSong(for: appleMusicID)
			self?.refreshVisibleMusicCells()
		}
	}
}

// MARK: - ActionBaseExploreCollectionViewCellDelegate
extension SearchResultsCollectionViewController: ActionBaseExploreCollectionViewCellDelegate {
	func actionButtonPressed(_ sender: UIButton, cell: ActionBaseExploreCollectionViewCell) {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }

		switch cell.self {
		case is ActionLinkExploreCollectionViewCell:
			let discoverSuggestion = self.discoverSuggestions[indexPath.item]
			self.kSearchController.searchBar.text = discoverSuggestion.title
			self.kSearchController.searchBar.becomeFirstResponder()
			self.kSearchController.searchBar.resignFirstResponder()
			self.searchBarSearchButtonClicked(self.kSearchController.searchBar)
		case is ActionButtonExploreCollectionViewCell: break
		default: break
		}
	}
}

// MARK: - UIToolbarDelegate
extension SearchResultsCollectionViewController: UIToolbarDelegate {
	func position(for bar: UIBarPositioning) -> UIBarPosition {
		return .topAttached
	}
}

// MARK: - SearchFilterCollectionViewControllerDelegate
extension SearchResultsCollectionViewController: SearchFilterCollectionViewControllerDelegate {
	func searchFilterCollectionViewController(_ searchFilterCollectionViewController: SearchFilterCollectionViewController, didApply filter: SearchFilter) {
		guard let searchScope = SearchScope(rawValue: self.kSearchController.searchBar.selectedScopeButtonIndex) else { return }
		guard let searchType = self.searchTypes[safe: self.currentIndex] else { return }

		self.searchFilters[searchType] = filter

		self.performSearch(with: self.searchQuery, in: searchScope, for: [searchType], with: filter, next: nil, resettingResults: true)

		self.kSearchController.searchBar.setImage(UIImage(systemName: "line.3.horizontal.decrease.circle.fill"), for: .bookmark, state: .normal)
	}

	func searchFilterCollectionViewControllerDidReset(_ searchFilterCollectionViewController: SearchFilterCollectionViewController) {
		guard let searchType = self.searchTypes[safe: self.currentIndex] else { return }

		self.searchFilters[searchType] = nil

		self.kSearchController.searchBar.setImage(UIImage(systemName: "line.3.horizontal.decrease.circle"), for: .bookmark, state: .normal)
	}

	func searchFilterCollectionViewControllerDidCancel(_ searchFilterCollectionViewController: SearchFilterCollectionViewController) {
		print("----- search filter did cancel")
	}
}

// MARK: - UISearchResultsUpdating
@available(iOS 16.0, *)
extension SearchResultsCollectionViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		guard self.shouldOfferTokenSuggestions else {
			searchController.showsSearchResultsController = false
			return
		}

		self.refreshTokenSuggestions()
	}

	/// Refreshes the token suggestions controller with the types currently applicable to the
	/// active scope and toggles its visibility.
	///
	/// Call this after any change that might shift the result of `tokenSuggestionTypes()`:
	/// text edits, scope changes, token insertions, etc.
	func refreshTokenSuggestions() {
		guard self.shouldOfferTokenSuggestions else {
			self.kSearchController.showsSearchResultsController = false
			return
		}

		self.tokenizeTypedKeywordIfNeeded()

		let types = self.tokenSuggestionTypes()
		self.tokenSuggestionsViewController?.types = types
		self.kSearchController.showsSearchResultsController = !types.isEmpty
	}

	/// Inserts a token representing `type` and refreshes the suggestion list.
	///
	/// - Parameter type: The search type to convert into a token.
	func handleTokenSuggestionSelected(_ type: SearchType) {
		let searchTextField = self.kSearchController.searchBar.searchTextField
		self.removeCurrentTypedWord()

		let token = UISearchToken(icon: nil, text: type.stringValue)
		token.representedObject = type
		searchTextField.insertToken(token, at: searchTextField.tokens.count)

		self.refreshTokenSuggestions()
	}
}
