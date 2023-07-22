//
//  SearchResultsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import Tabman
import KurozoraKit
import Alamofire
import AVFoundation
import MediaPlayer

/// The collection view controller in charge of providing the necessary functionalities for searching shows, threads and users.
class SearchResultsCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var filterBarButtonItem: UIBarButtonItem!
	let toolbar = UIToolbar()
	let tabBarView = TMBar.KBar()
	var currentTopContentInset: CGFloat = 0
	var currentIndex: Int = 0

	/// The collection of results fetched by the search request.
	var searchResults: Search?

	/// The current scope of the search.
	var currentScope: KKSearchScope = .kurozora

	/// The search query that is performed.
	var searachQuery: String = ""

	/// The collection of discover suggestions.
	var discoverSuggestions: [String] = []

	/// The collection of search types in the current search request
	var searchTypes: [KKSearchType] = [] {
		didSet {
			self.reloadView()
		}
	}

	/// The search filters applied to the respective search type
	var searchFilters: [KKSearchType: KKSearchFilter?] = [:]

	var characters: [IndexPath: Character] = [:]
	var episodes: [IndexPath: Episode] = [:]
	var people: [IndexPath: Person] = [:]
	var shows: [IndexPath: Show] = [:]
	var literatures: [IndexPath: Literature] = [:]
	var games: [IndexPath: Game] = [:]
	var songs: [IndexPath: Song] = [:]
	var studios: [IndexPath: Studio] = [:]
	var users: [IndexPath: User] = [:]

	var characterIdentities: [CharacterIdentity] = []
	var episodeIdentities: [EpisodeIdentity] = []
	var personIdentities: [PersonIdentity] = []
	var showIdentities: [ShowIdentity] = []
	var literatureIdentities: [LiteratureIdentity] = []
	var gameIdentities: [GameIdentity] = []
	var songIdentities: [SongIdentity] = []
	var studioIdentities: [StudioIdentity] = []
	var userIdentities: [UserIdentity] = []

	var characterNextPageURL: String? = nil
	var episodeNextPageURL: String? = nil
	var personNextPageURL: String? = nil
	var showNextPageURL: String? = nil
	var literatureNextPageURL: String? = nil
	var gameNextPageURL: String? = nil
	var songNextPageURL: String? = nil
	var studioNextPageURL: String? = nil
	var userNextPageURL: String? = nil

	/// The object that provides the interface to control the player’s transport behavior.
	var player: AVPlayer?

	/// The index path of the song that's currently playing.
	var currentPlayerIndexPath: IndexPath?

	var dataSource: UICollectionViewDiffableDataSource<SearchResults.Section, SearchResults.Item>! = nil
	var snapshot: NSDiffableDataSourceSnapshot<SearchResults.Section, SearchResults.Item>! = nil
	var prefetchingIndexPathOperations: [IndexPath: DataRequest] = [:]

	/// Whether a fetch request is currently in progress.
	var isRequestInProgress: Bool = false

	/// The object containing the search controller
	lazy var kSearchController: KSearchController = KSearchController()

	/// Whether to include a search controller in the navigation bar
	var includesSearchBar = true

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
		// Disable Refresh Control & hide Activity Indicator
		self._prefersRefreshControlDisabled = true
		self._prefersActivityIndicatorHidden = true

		// Determine if search bar is included
		if self.includesSearchBar {
			self.setupSearchController()
		}

		// Configurations
		#if targetEnvironment(macCatalyst)
		self.configureFilterBarButtonItem()
		#endif
		self.configureTabBarView()
		self.configureToolbar()
		self.configureViewHierarchy()
		self.configureViewConstraints()

		// Fetch discover elements
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchSearchSuggestions()
			self.updateDataSource()
		}

		// Update data source
		self.configureDataSource()
		self.updateDataSource()
    }

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		self.player?.pause()
	}

	// MARK: - Functions
	func configureFilterBarButtonItem() {
		self.filterBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle"), style: .plain, target: self, action: #selector(self.handleFilterBarButtonItemPressed(_:)))
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
			button.contentInset = UIEdgeInsets(top: 8.0, left: 12.0, bottom: 4.0, right: 12.0)
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
	}

	/// Setup the search controller with the desired settings.
	func setupSearchController() {
		// Set the current view as the view controller of the search
		self.kSearchController.viewController = self

		// Add search bar to navigation controller
		self.navigationItem.searchController = self.kSearchController

		#if !targetEnvironment(macCatalyst)
		if #available(iOS 16.0, *) {
			self.navigationItem.preferredSearchBarPlacement = .stacked
		}
		#endif
	}

	func configureViewHierarchy() {
		self.view.addSubview(self.toolbar)
		self.toolbar.setItems([UIBarButtonItem(customView: self.tabBarView)], animated: true)
	}

	func configureViewConstraints() {
		NSLayoutConstraint.activate([
			self.toolbar.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
			self.toolbar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.toolbar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.toolbar.heightAnchor.constraint(equalToConstant: 49.0)
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
	func performSearch(with query: String, in searchScope: KKSearchScope, for types: [KKSearchType], with filter: KKSearchFilter?, next: String?, resettingResults: Bool = true) {
		// Prepare view for search
		self.currentScope = searchScope

		if resettingResults {
			// Show activity indicator.
			self._prefersActivityIndicatorHidden = false

			// Reset results
			self.resetSearchResults(for: types.count > 1 ? nil : types.first)
		}

		// Decide with wich endpoint to perform the search
		switch searchScope {
		case .kurozora:
			Task { [weak self] in
				guard let self = self else { return }
				let types: [KKSearchType] = self.searchResults != nil ? types : [.shows, .literatures, .games, .episodes, .characters, .people, .songs, .studios, .users]
				await self.search(scope: searchScope, types: types, query: query, next: next, filter: filter)
			}
		case .library:
			WorkflowController.shared.isSignedIn { [weak self] in
				Task {
					guard let self = self else { return }
					let types: [KKSearchType] = self.searchResults != nil ? types : [.shows, .literatures, .games]
					await self.search(scope: searchScope, types: types, query: query, next: next, filter: filter)
				}
			}
		}
	}

	fileprivate func search(scope: KKSearchScope, types: [KKSearchType], query: String, next: String?, filter: KKSearchFilter?) async {
		guard !self.isRequestInProgress else {
			return
		}

		// Set request in progress
		self.isRequestInProgress = true

		// Store search query
		self.searachQuery = query

		do {
			// Perform library search request.
			let searchResponse = try await KService.search(scope, of: types, for: query, next: next, limit: 25, filter: filter).value

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

				self.characterIdentities.append(contentsOf: searchResponse.data.characters?.data ?? [])
				self.episodeIdentities.append(contentsOf: searchResponse.data.episodes?.data ?? [])
				self.personIdentities.append(contentsOf: searchResponse.data.people?.data ?? [])
				self.showIdentities.append(contentsOf: searchResponse.data.shows?.data ?? [])
				self.literatureIdentities.append(contentsOf: searchResponse.data.literatures?.data ?? [])
				self.gameIdentities.append(contentsOf: searchResponse.data.games?.data ?? [])
				self.songIdentities.append(contentsOf: searchResponse.data.songs?.data ?? [])
				self.studioIdentities.append(contentsOf: searchResponse.data.studios?.data ?? [])
				self.userIdentities.append(contentsOf: searchResponse.data.users?.data ?? [])

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
					self.characterNextPageURL = searchResponse.data.characters?.next ?? self.characterNextPageURL
					self.characterIdentities.append(contentsOf: searchResponse.data.characters?.data ?? [])
				case .episodes:
					self.episodeNextPageURL = searchResponse.data.episodes?.next ?? self.episodeNextPageURL
					self.episodeIdentities.append(contentsOf: searchResponse.data.episodes?.data ?? [])
				case .games:
					self.gameNextPageURL = searchResponse.data.games?.next ?? self.gameNextPageURL
					self.gameIdentities.append(contentsOf: searchResponse.data.games?.data ?? [])
				case .literatures:
					self.literatureNextPageURL = searchResponse.data.literatures?.next ?? self.literatureNextPageURL
					self.literatureIdentities.append(contentsOf: searchResponse.data.literatures?.data ?? [])
				case .people:
					self.personNextPageURL = searchResponse.data.people?.next ?? self.personNextPageURL
					self.personIdentities.append(contentsOf: searchResponse.data.people?.data ?? [])
				case .shows:
					self.showNextPageURL = searchResponse.data.shows?.next ?? self.showNextPageURL
					self.showIdentities.append(contentsOf: searchResponse.data.shows?.data ?? [])
				case .songs:
					self.songNextPageURL = searchResponse.data.songs?.next ?? self.songNextPageURL
					self.songIdentities.append(contentsOf: searchResponse.data.songs?.data ?? [])
				case .studios:
					self.studioNextPageURL = searchResponse.data.studios?.next ?? self.studioNextPageURL
					self.studioIdentities.append(contentsOf: searchResponse.data.studios?.data ?? [])
				case .users:
					self.userNextPageURL = searchResponse.data.users?.next ?? self.userNextPageURL
					self.userIdentities.append(contentsOf: searchResponse.data.users?.data ?? [])
				}
			}

			// Update data source.
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		self.isRequestInProgress = false

		// Hide activity indicator.
		self._prefersActivityIndicatorHidden = true
	}

	fileprivate func determineResultTypes() -> [KKSearchType] {
		guard let searchResults = self.searchResults else { return [] }
		var resultTypes: [KKSearchType] = []

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

	/// Sets all search results to nil and reloads the table view
	fileprivate func resetSearchResults(for type: KKSearchType?) {
		if let type = type {
			switch type {
			case .characters:
				self.characterIdentities = []
				self.characterNextPageURL = nil
				self.characters = [:]
			case .episodes:
				self.episodeIdentities = []
				self.episodeNextPageURL = nil
				self.episodes = [:]
			case .games:
				self.gameIdentities = []
				self.gameNextPageURL = nil
				self.games = [:]
			case .literatures:
				self.literatureIdentities = []
				self.literatureNextPageURL = nil
				self.literatures = [:]
			case .people:
				self.personIdentities = []
				self.personNextPageURL = nil
				self.people = [:]
			case .shows:
				self.showIdentities = []
				self.showNextPageURL = nil
				self.shows = [:]
			case .songs:
				self.songIdentities = []
				self.songNextPageURL = nil
				self.songs = [:]
			case .studios:
				self.studioIdentities = []
				self.studioNextPageURL = nil
				self.studios = [:]
			case .users:
				self.userIdentities = []
				self.userNextPageURL = nil
				self.users = [:]
			}
		} else {
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

			self.characters = [:]
			self.episodes = [:]
			self.people = [:]
			self.shows = [:]
			self.literatures = [:]
			self.games = [:]
			self.songs = [:]
			self.studios = [:]
			self.users = [:]
		}

		self.updateDataSource()
	}

	func fetchSearchSuggestions() async {
		do {
			let searchSuggestionResponse = try await KService.getSearchSuggestions(.kurozora, of: [.shows], for: "o").value
			self.discoverSuggestions = searchSuggestionResponse.data
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
		guard let searchFilterViewController = R.storyboard.searchFilter.searchFilterCollectionViewController() else { return nil }
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
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.searchResultsCollectionViewController.characterDetailsSegue.identifier:
			// Segue to character details
			guard let characterDetailCollectionViewController = segue.destination as? CharacterDetailsCollectionViewController else { return }
			guard let character = sender as? Character else { return }
			characterDetailCollectionViewController.character = character
		case R.segue.searchResultsCollectionViewController.episodeDetailsSegue.identifier:
			// Segue to episode details
			guard let episodeDetailsCollectionViewController = segue.destination as? EpisodeDetailsCollectionViewController else { return }
			guard let episode = sender as? Episode else { return }
			episodeDetailsCollectionViewController.episode = episode
		case R.segue.searchResultsCollectionViewController.literatureDetailsSegue.identifier:
			// Segue to literature details
			guard let literatureDetailCollectionViewController = segue.destination as? LiteratureDetailsCollectionViewController else { return }
			guard let literature = sender as? Literature else { return }
			literatureDetailCollectionViewController.literature = literature
		case R.segue.searchResultsCollectionViewController.gameDetailsSegue.identifier:
			// Segue to game details
			guard let gameDetailCollectionViewController = segue.destination as? GameDetailsCollectionViewController else { return }
			guard let game = sender as? Game else { return }
			gameDetailCollectionViewController.game = game
		case R.segue.searchResultsCollectionViewController.personDetailsSegue.identifier:
			// Segue to person details
			guard let personDetailCollectionViewController = segue.destination as? PersonDetailsCollectionViewController else { return }
			guard let person = sender as? Person else { return }
			personDetailCollectionViewController.person = person
		case R.segue.searchResultsCollectionViewController.showDetailsSegue.identifier:
			// Segue to show details
			guard let showDetailCollectionViewController = segue.destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailCollectionViewController.show = show
		case R.segue.searchResultsCollectionViewController.songDetailsSegue.identifier:
			// Segue to studio details
			guard let songDetailCollectionViewController = segue.destination as? SongDetailsCollectionViewController else { return }
			guard let song = sender as? Song else { return }
			songDetailCollectionViewController.song = song
		case R.segue.searchResultsCollectionViewController.studioDetailsSegue.identifier:
			// Segue to studio details
			guard let studioDetailCollectionViewController = segue.destination as? StudioDetailsCollectionViewController else { return }
			guard let studio = sender as? Studio else { return }
			studioDetailCollectionViewController.studio = studio
		case R.segue.searchResultsCollectionViewController.userDetailsSegue.identifier:
			// Segue to user details
			guard let profileTableViewController = segue.destination as? ProfileTableViewController else { return }
			guard let user = sender as? User else { return }
			profileTableViewController.user = user
		case R.segue.searchResultsCollectionViewController.charactersListSegue.identifier:
			// Segue to characters list
			guard let charactersListCollectionViewController = segue.destination as? CharactersListCollectionViewController else { return }
			charactersListCollectionViewController.searachQuery = self.searachQuery
			charactersListCollectionViewController.charactersListFetchType = .search
		case R.segue.searchResultsCollectionViewController.episodesListSegue.identifier:
			// Segue to episodes list
			guard let episodesListCollectionViewController = segue.destination as? EpisodesListCollectionViewController else { return }
			if let season = sender as? Season {
				episodesListCollectionViewController.seasonIdentity = SeasonIdentity(id: season.id)
				episodesListCollectionViewController.episodesListFetchType = .season
			} else {
				episodesListCollectionViewController.searachQuery = self.searachQuery
				episodesListCollectionViewController.episodesListFetchType = .search
			}
		case R.segue.searchResultsCollectionViewController.literaturesListSegue.identifier:
			// Segue to literatures list
			guard let literaturesListCollectionViewController = segue.destination as? LiteraturesListCollectionViewController else { return }
			literaturesListCollectionViewController.searachQuery = self.searachQuery
			literaturesListCollectionViewController.literaturesListFetchType = .search
		case R.segue.searchResultsCollectionViewController.gamesListSegue.identifier:
			// Segue to games list
			guard let gamesListCollectionViewController = segue.destination as? GamesListCollectionViewController else { return }
			gamesListCollectionViewController.searachQuery = self.searachQuery
			gamesListCollectionViewController.gamesListFetchType = .search
		case R.segue.searchResultsCollectionViewController.peopleListSegue.identifier:
			// Segue to people list
			guard let peopleListCollectionViewController = segue.destination as? PeopleListCollectionViewController else { return }
			peopleListCollectionViewController.searachQuery = self.searachQuery
			peopleListCollectionViewController.peopleListFetchType = .search
		case R.segue.searchResultsCollectionViewController.songsListSegue.identifier:
			// Segue to songs list
			guard let showSongsListCollectionViewController = segue.destination as? ShowSongsListCollectionViewController else { return }
			showSongsListCollectionViewController.songs = self.songs.map { _, song in
				return song
			}
		case R.segue.searchResultsCollectionViewController.showsListSegue.identifier:
			// Segue to shows list
			guard let showsListCollectionViewController = segue.destination as? ShowsListCollectionViewController else { return }
			showsListCollectionViewController.searachQuery = self.searachQuery
			showsListCollectionViewController.showsListFetchType = .search
		case R.segue.searchResultsCollectionViewController.studiosListSegue.identifier:
			// Segue to studios list
			guard let studiosListCollectionViewController = segue.destination as? StudiosListCollectionViewController else { return }
			studiosListCollectionViewController.searachQuery = self.searachQuery
			studiosListCollectionViewController.studiosListFetchType = .search
		case R.segue.searchResultsCollectionViewController.usersListSegue.identifier:
			// Segue to users list
			guard let usersListCollectionViewController = segue.destination as? UsersListCollectionViewController else { return }
			usersListCollectionViewController.searachQuery = self.searachQuery
			usersListCollectionViewController.usersListFetchType = .search
		default: break
		}
	}
}

// MARK: - TMBarDataSource
extension SearchResultsCollectionViewController: TMBarDataSource {
	func reloadView() {
		self.tabBarView.reloadData(at: 0...self.searchTypes.count - 1, context: .full)
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
		self.updateDataSource()
	}
}

extension TMBarUpdateDirection {
	static func forPage(_ page: Int, previousPage: Int) -> TMBarUpdateDirection {
		return forPosition(CGFloat(page), previous: CGFloat(previousPage))
	}

	static func forPosition(_ position: CGFloat, previous previousPosition: CGFloat) -> TMBarUpdateDirection {
		if position == previousPosition {
			return .none
		}
		return  position > previousPosition ? .forward : .reverse
	}
}

// MARK: - UISearchBarDelegate
extension SearchResultsCollectionViewController: UISearchBarDelegate {
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		#if targetEnvironment(macCatalyst)
		self.navigationItem.rightBarButtonItems = []
		#else
		searchBar.setShowsScope(true, animated: true)
		searchBar.showsBookmarkButton = false
		#endif
		self.setShowToolbar(false)
	}

	func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
		#if !targetEnvironment(macCatalyst)
		searchBar.setShowsScope(false, animated: true)
		#endif

		if self.searchResults != nil {
			#if targetEnvironment(macCatalyst)
			self.navigationItem.rightBarButtonItems = [self.filterBarButtonItem]
			#else
			searchBar.showsBookmarkButton = true
			#endif
			self.setShowToolbar(true)
		}
	}

	func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
		guard let searchScope = KKSearchScope(rawValue: selectedScope) else { return }
		guard let query = searchBar.text, !query.isEmpty else { return }

		switch searchScope {
		case .kurozora:
			self.performSearch(with: query, in: searchScope, for: [], with: nil, next: nil)
		case .library:
			WorkflowController.shared.isSignedIn { [weak self] in
				guard let self = self else { return }
				self.performSearch(with: query, in: searchScope, for: [], with: nil, next: nil)
				return
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
		guard let searchScope = KKSearchScope(rawValue: searchBar.selectedScopeButtonIndex) else { return }
		guard let query = searchBar.text else { return }
		self.performSearch(with: query, in: searchScope, for: [], with: nil, next: nil)
	}

	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		#if targetEnvironment(macCatalyst)
		self.navigationItem.rightBarButtonItems = []
		#else
		searchBar.showsBookmarkButton = false
		#endif
		self.setShowToolbar(false)
		self.resetSearchResults(for: nil)
	}
}

// MARK: - BaseLockupCollectionViewCellDelegate
extension SearchResultsCollectionViewController: BaseLockupCollectionViewCellDelegate {
	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressReminder button: UIButton) { }

	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressStatus button: UIButton) {
		WorkflowController.shared.isSignedIn { [weak self] in
			guard let self = self else { return }
			guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
			let modelID: String

			switch cell.libraryKind {
			case .shows:
				guard let show = self.shows[indexPath] else { return }
				modelID = show.id
			case .literatures:
				guard let literature = self.literatures[indexPath] else { return }
				modelID = literature.id
			case .games:
				guard let game = self.games[indexPath] else { return }
				modelID = game.id
			}

			let oldLibraryStatus = cell.libraryStatus
			let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: KKLibrary.Status.alertControllerItems(for: cell.libraryKind), currentSelection: oldLibraryStatus, action: { title, value  in
				Task {
					do {
						let libraryUpdateResponse = try await KService.addToLibrary(cell.libraryKind, withLibraryStatus: value, modelID: modelID).value

						switch cell.libraryKind {
						case .shows:
							self.shows[indexPath]?.attributes.update(using: libraryUpdateResponse.data)
						case .literatures:
							self.literatures[indexPath]?.attributes.update(using: libraryUpdateResponse.data)
						case .games:
							self.games[indexPath]?.attributes.update(using: libraryUpdateResponse.data)
						}

						// Update entry in library
						cell.libraryStatus = value
						button.setTitle("\(title) ▾", for: .normal)

						let libraryAddToNotificationName = Notification.Name("AddTo\(value.sectionValue)Section")
						NotificationCenter.default.post(name: libraryAddToNotificationName, object: nil)
					} catch let error as KKAPIError {
						self.presentAlertController(title: "Can't Add to Your Library 😔", message: error.message)
						print("----- Add to library failed", error.message)
					}
				}
			})

			if cell.libraryStatus != .none {
				actionSheetAlertController.addAction(UIAlertAction(title: Trans.removeFromLibrary, style: .destructive, handler: { _ in
					Task {
						do {
							let libraryUpdateResponse = try await KService.removeFromLibrary(cell.libraryKind, modelID: modelID).value

							switch cell.libraryKind {
							case .shows:
								self.shows[indexPath]?.attributes.update(using: libraryUpdateResponse.data)
							case .literatures:
								self.literatures[indexPath]?.attributes.update(using: libraryUpdateResponse.data)
							case .games:
								self.games[indexPath]?.attributes.update(using: libraryUpdateResponse.data)
							}

							// Update edntry in library
							cell.libraryStatus = .none
							button.setTitle("ADD", for: .normal)

							let libraryRemoveFromNotificationName = Notification.Name("RemoveFrom\(oldLibraryStatus.sectionValue)Section")
							NotificationCenter.default.post(name: libraryRemoveFromNotificationName, object: nil)
						} catch let error as KKAPIError {
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
}

// MARK: - TitleHeaderCollectionReusableViewDelegate
extension SearchResultsCollectionViewController: TitleHeaderCollectionReusableViewDelegate {
	func titleHeaderCollectionReusableView(_ reusableView: TitleHeaderCollectionReusableView, didPress button: UIButton) {
		self.performSegue(withIdentifier: reusableView.segueID, sender: reusableView.indexPath)
	}
}

// MARK: - UserLockupCollectionViewCellDelegate
extension SearchResultsCollectionViewController: UserLockupCollectionViewCellDelegate {
	func userLockupCollectionViewCell(_ cell: UserLockupCollectionViewCell, didPressFollow button: UIButton) {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		guard var user = self.users[indexPath] else { return }

		Task {
			do {
				let userIdentity = UserIdentity(id: user.id)
				let followUpdateResponse = try await KService.updateFollowStatus(forUser: userIdentity).value
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
	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressWatchStatusButton button: UIButton) {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		Task { [weak self] in
			guard let self = self else { return }
			await self.episodes[indexPath]?.updateWatchStatus(userInfo: ["indexPath": indexPath])
		}
	}

	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressShowButton button: UIButton) {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		guard let show = self.episodes[indexPath]?.relationships?.shows?.data.first else { return }

		self.performSegue(withIdentifier: R.segue.searchResultsCollectionViewController.showDetailsSegue, sender: show)
	}

	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressSeasonButton button: UIButton) {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		guard let season = self.episodes[indexPath]?.relationships?.seasons?.data.first else { return }

		self.performSegue(withIdentifier: R.segue.searchResultsCollectionViewController.episodesListSegue, sender: season)
	}
}

// MARK: - MusicLockupCollectionViewCellDelegate
extension SearchResultsCollectionViewController: MusicLockupCollectionViewCellDelegate {
	func playButtonPressed(_ sender: UIButton, cell: MusicLockupCollectionViewCell) {
		guard let song = cell.song else { return }

		if let songURL = song.previewAssets?.first?.url {
			let playerItem = AVPlayerItem(url: songURL)

			if (self.player?.currentItem?.asset as? AVURLAsset)?.url == (playerItem.asset as? AVURLAsset)?.url {
				switch self.player?.timeControlStatus {
				case .playing:
					cell.playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
					self.player?.pause()
				case .paused:
					cell.playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
					self.player?.play()
				default: break
				}
			} else {
				if let indexPath = self.currentPlayerIndexPath {
					if let cell = collectionView.cellForItem(at: indexPath) as? MusicLockupCollectionViewCell {
						cell.playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
					}
				}

				self.currentPlayerIndexPath = cell.indexPath
				self.player = AVPlayer(playerItem: playerItem)
				self.player?.actionAtItemEnd = .none
				self.player?.play()
				cell.playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)

				NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .current, using: { [weak self] _ in
					guard let self = self else { return }
					self.player = nil
					cell.playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
				})
			}
		}
	}

	func showButtonPressed(_ sender: UIButton, indexPath: IndexPath) {
		// No action
	}
}

// MARK: - ActionBaseExploreCollectionViewCellDelegate
extension SearchResultsCollectionViewController: ActionBaseExploreCollectionViewCellDelegate {
	func actionButtonPressed(_ sender: UIButton, cell: ActionBaseExploreCollectionViewCell) {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }

		switch cell.self {
		case is ActionLinkExploreCollectionViewCell:
			let discoverSuggestion = self.discoverSuggestions[indexPath.item]
			self.kSearchController.searchBar.text = discoverSuggestion
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
	func searchFilterCollectionViewController(_ searchFilterCollectionViewController: SearchFilterCollectionViewController, didApply filter: KKSearchFilter) {
		guard let searchScope = KKSearchScope(rawValue: self.kSearchController.searchBar.selectedScopeButtonIndex) else { return }
		guard let searchType = self.searchTypes[safe: self.currentIndex] else { return }

		self.searchFilters[searchType] = filter

		self.performSearch(with: self.searachQuery, in: searchScope, for: [searchType], with: filter, next: nil, resettingResults: true)

		self.kSearchController.searchBar.setImage(UIImage(systemName: "line.3.horizontal.decrease.circle.fill"), for: .bookmark, state: .normal)
	}

	func searchFilterCollectionViewControllerDidReset(_ searchFilterCollectionViewController: SearchFilterCollectionViewController) {
		guard let searchType = self.searchTypes[safe: self.currentIndex] else { return }

		self.searchFilters[searchType] = nil

		self.kSearchController.searchBar.setImage(UIImage(systemName: "line.3.horizontal.decrease.circle"), for: .bookmark, state: .normal)
	}

	func searchFilterCollectionViewControllerDidCancel(_ searchFilterCollectionViewController: SearchFilterCollectionViewController) {
		print("----- did cancel")
	}
}
