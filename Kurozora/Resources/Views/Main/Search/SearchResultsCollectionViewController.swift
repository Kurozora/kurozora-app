//
//  SearchResultsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

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
class SearchResultsCollectionViewController: KCollectionViewController, SectionFetchable {
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

	/// The hydrated models keyed by index path.
	var cache: [IndexPath: KurozoraItem] = [:]

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

	var characterNextPageURL: String?
	var episodeNextPageURL: String?
	var personNextPageURL: String?
	var showNextPageURL: String?
	var literatureNextPageURL: String?
	var gameNextPageURL: String?
	var songNextPageURL: String?
	var studioNextPageURL: String?
	var userNextPageURL: String?

	var dataSource: UICollectionViewDiffableDataSource<SearchResults.Section, SearchResults.Item>!
	var snapshot: NSDiffableDataSourceSnapshot<SearchResults.Section, SearchResults.Item>!

	/// Whether a fetch request is currently in progress.
	var isRequestInProgress: Bool = false

	/// The object containing the search controller
	lazy var kSearchController: KSearchController = KSearchController()

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

		if case .library = self.searchViewKind {
			searchScope = .library
		}

		// Prepare view for search
		self.currentScope = searchScope

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
				let searchTypes: [KKSearchType]

				switch self.searchViewKind {
				case .single(let type):
					searchTypes = [type]
					self.searchTypes = searchTypes
				case .multiple:
					searchTypes = self.searchResults != nil ? types : [.shows, .literatures, .games, .episodes, .characters, .people, .songs, .studios, .users]
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

				let types: [KKSearchType] = self.searchResults != nil ? types : [.shows, .literatures, .games]
				await self.search(scope: searchScope, types: types, query: query, next: next, filter: filter)
			}
		}
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
			let searchResponse = try await KService.search(scope, of: types, for: query, next: next, limit: next != nil ? 100 : 25, filter: filter)

			if types.count > 1 {
				self.searchResults = searchResponse.data

				self.characterNextPageURL = searchResponse.data.characters?.next ?? self.characterNextPageURL
				self.episodeNextPageURL = searchResponse.data.episodes?.next ?? self.episodeNextPageURL
				self.personNextPageURL = searchResponse.data.people?.next ?? self.personNextPageURL
				self.showNextPageURL = searchResponse.data.shows?.next ?? self.showNextPageURL
				self.literatureNextPageURL = searchResponse.data.literatures?.next ?? self.literatureNextPageURL
				self.gameNextPageURL = searchResponse.data.games?.next ?? self.gameNextPageURL
				self.songNextPageURL = searchResponse.data.songs?.next ?? self.songNextPageURL
				self.studioNextPageURL = searchResponse.data.studios?.next ?? self.studioNextPageURL
				self.userNextPageURL = searchResponse.data.users?.next ?? self.userNextPageURL

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
					self.characterNextPageURL = searchResponse.data.characters?.next
					self.characterIdentities.appendDistinct(contentsOf: searchResponse.data.characters?.data ?? [])
				case .episodes:
					self.episodeNextPageURL = searchResponse.data.episodes?.next
					self.episodeIdentities.appendDistinct(contentsOf: searchResponse.data.episodes?.data ?? [])
				case .games:
					self.gameNextPageURL = searchResponse.data.games?.next
					self.gameIdentities.appendDistinct(contentsOf: searchResponse.data.games?.data ?? [])
				case .literatures:
					self.literatureNextPageURL = searchResponse.data.literatures?.next
					self.literatureIdentities.appendDistinct(contentsOf: searchResponse.data.literatures?.data ?? [])
				case .people:
					self.personNextPageURL = searchResponse.data.people?.next
					self.personIdentities.appendDistinct(contentsOf: searchResponse.data.people?.data ?? [])
				case .shows:
					self.showNextPageURL = searchResponse.data.shows?.next
					self.showIdentities.appendDistinct(contentsOf: searchResponse.data.shows?.data ?? [])
				case .songs:
					self.songNextPageURL = searchResponse.data.songs?.next
					self.songIdentities.appendDistinct(contentsOf: searchResponse.data.songs?.data ?? [])
				case .studios:
					self.studioNextPageURL = searchResponse.data.studios?.next
					self.studioIdentities.appendDistinct(contentsOf: searchResponse.data.studios?.data ?? [])
				case .users:
					self.userNextPageURL = searchResponse.data.users?.next
					self.userIdentities.appendDistinct(contentsOf: searchResponse.data.users?.data ?? [])
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
		guard
			let firstItem = items.first,
			let sectionIndex = snapshot.indexOfSection(section)
		else { return }
		let firstIndexPath = IndexPath(item: 0, section: sectionIndex)

		switch section {
		case .characters:
			await self.fetchSectionIfNeeded(CharacterResponse.self, CharacterIdentity.self, at: firstIndexPath, itemKind: firstItem)
		case .episodes:
			await self.fetchSectionIfNeeded(EpisodeResponse.self, EpisodeIdentity.self, at: firstIndexPath, itemKind: firstItem)
		case .games:
			await self.fetchSectionIfNeeded(GameResponse.self, GameIdentity.self, at: firstIndexPath, itemKind: firstItem)
		case .literatures:
			await self.fetchSectionIfNeeded(LiteratureResponse.self, LiteratureIdentity.self, at: firstIndexPath, itemKind: firstItem)
		case .people:
			await self.fetchSectionIfNeeded(PersonResponse.self, PersonIdentity.self, at: firstIndexPath, itemKind: firstItem)
		case .shows:
			await self.fetchSectionIfNeeded(ShowResponse.self, ShowIdentity.self, at: firstIndexPath, itemKind: firstItem)
		case .songs:
			await self.fetchSongsSection(at: firstIndexPath, itemKind: firstItem, sectionIndex: sectionIndex, itemCount: items.count)
		case .studios:
			await self.fetchSectionIfNeeded(StudioResponse.self, StudioIdentity.self, at: firstIndexPath, itemKind: firstItem)
		case .users:
			await self.fetchSectionIfNeeded(UserResponse.self, UserIdentity.self, at: firstIndexPath, itemKind: firstItem)
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
		await self.fetchSectionIfNeeded(SongResponse.self, SongIdentity.self, at: indexPath, itemKind: itemKind)

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
				self.characterNextPageURL = nil
			case .episodes:
				self.episodeIdentities = []
				self.episodeNextPageURL = nil
			case .games:
				self.gameIdentities = []
				self.gameNextPageURL = nil
			case .literatures:
				self.literatureIdentities = []
				self.literatureNextPageURL = nil
			case .people:
				self.personIdentities = []
				self.personNextPageURL = nil
			case .shows:
				self.showIdentities = []
				self.showNextPageURL = nil
			case .songs:
				self.songIdentities = []
				self.songNextPageURL = nil
			case .studios:
				self.studioIdentities = []
				self.studioNextPageURL = nil
			case .users:
				self.userIdentities = []
				self.userNextPageURL = nil
			}
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

			self.characterNextPageURL = nil
			self.episodeNextPageURL = nil
			self.personNextPageURL = nil
			self.showNextPageURL = nil
			self.literatureNextPageURL = nil
			self.gameNextPageURL = nil
			self.songNextPageURL = nil
			self.studioNextPageURL = nil
			self.userNextPageURL = nil
		}

		self.cache.removeAll()

		self.updateDataSource()
	}

	func fetchSearchSuggestions() async {
		do {
			let alphabet = "abcdefghijklmnopqrstuvwxyz"
			let suggestionString = String(alphabet.randomElement() ?? "o")
			let searchSuggestionResponse = try await KService.getSearchSuggestions(.kurozora, of: [.shows], for: suggestionString)
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
		guard let query = searchBar.text, !query.isEmpty else { return }
		guard let searchScope = SearchScope(rawValue: selectedScope) else { return }

		switch searchScope {
		case .kurozora:
			self.performSearch(with: query, in: searchScope, for: [], with: nil, next: nil)
		case .library:
			Task { [weak self] in
				guard let self = self else { return }
				let signedIn = await WorkflowController.shared.isSignedIn(on: self)
				guard signedIn else { return }
				self.performSearch(with: query, in: searchScope, for: [], with: nil, next: nil)
			}
			searchBar.selectedScopeButtonIndex = self.currentScope.rawValue
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
		self.performSearch(with: query, in: searchScope, for: [], with: nil, next: nil)
	}

	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
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
		let modelID: KurozoraItemID

		switch cell.libraryKind {
		case .shows:
			guard let show: Show = self.fetchModel(at: indexPath) else { return }
			modelID = show.id
		case .literatures:
			guard let literature: Literature = self.fetchModel(at: indexPath) else { return }
			modelID = literature.id
		case .games:
			guard let game: Game = self.fetchModel(at: indexPath) else { return }
			modelID = game.id
		}

		let oldLibraryStatus = cell.libraryStatus
		let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: LibraryStatus.alertControllerItems(for: cell.libraryKind), currentSelection: oldLibraryStatus, action: { title, value in
			Task {
				do {
					let libraryUpdateResponse = try await KService.addToLibrary(cell.libraryKind, status: value, itemIDs: [modelID]).response()

					switch cell.libraryKind {
					case .shows:
						(self.fetchModel(at: indexPath) as Show?)?.attributes.library?.update(using: libraryUpdateResponse.data)
					case .literatures:
						(self.fetchModel(at: indexPath) as Literature?)?.attributes.library?.update(using: libraryUpdateResponse.data)
					case .games:
						(self.fetchModel(at: indexPath) as Game?)?.attributes.library?.update(using: libraryUpdateResponse.data)
					}

					// Update entry in library
					cell.libraryStatus = value
					button.setTitle("\(title) ▾", for: .normal)

					let libraryAddToNotificationName = Notification.Name("AddTo\(value.sectionValue)Section")
					NotificationCenter.default.post(name: libraryAddToNotificationName, object: nil)

					// Request review
					ReviewManager.shared.requestReview(for: .itemAddedToLibrary(status: value))
				} catch let error as APIError {
					self.presentAlertController(title: "Can't Add to Your Library 😔", message: error.message)
					print("----- Add to library failed", error.message)
				}
			}
		})

		if cell.libraryStatus != .none {
			actionSheetAlertController.addAction(UIAlertAction(title: L10n.removeFromLibrary, style: .destructive, handler: { _ in
				Task {
					do {
						let libraryUpdateResponse = try await KService.removeFromLibrary(cell.libraryKind, itemIDs: [modelID]).response()

						switch cell.libraryKind {
						case .shows:
							(self.fetchModel(at: indexPath) as Show?)?.attributes.library?.update(using: libraryUpdateResponse.data)
						case .literatures:
							(self.fetchModel(at: indexPath) as Literature?)?.attributes.library?.update(using: libraryUpdateResponse.data)
						case .games:
							(self.fetchModel(at: indexPath) as Game?)?.attributes.library?.update(using: libraryUpdateResponse.data)
						}

						// Update entry in library
						cell.libraryStatus = .none
						button.setTitle(L10n.add.uppercased(), for: .normal)

						let libraryRemoveFromNotificationName = Notification.Name("RemoveFrom\(oldLibraryStatus.sectionValue)Section")
						NotificationCenter.default.post(name: libraryRemoveFromNotificationName, object: nil)
					} catch let error as APIError {
						self.presentAlertController(title: "Can't Remove From Your Library 😔", message: error.message)
						print("----- Remove from library failed", error.message)
					}
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
				let followUpdateResponse = try await KService.updateFollowStatus(forUser: userIdentity)
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

		self.show(SegueIdentifiers.showDetailsSegue, sender: showIdentity)
	}

	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressSeasonButton button: UIButton) {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		guard let seasonIdentity = (self.fetchModel(at: indexPath) as Episode?)?.relationships?.seasons?.data.first else { return }

		self.show(SegueIdentifiers.episodesListSegue, sender: seasonIdentity)
	}
}

// MARK: - MusicLockupCollectionViewCellDelegate
extension SearchResultsCollectionViewController: MusicLockupCollectionViewCellDelegate {
	func showButtonPressed(_ sender: UIButton, indexPath: IndexPath) {}
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
