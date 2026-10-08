//
//  HomeCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import Combine
import KurozoraKit
import SPConfetti
import UIKit
import WhatsNew

class HomeCollectionViewController: KCollectionViewController, SectionFetchable, MusicResolving, ProfileNavigable, TypedSegueHandling {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case redeemSegue
		case subscriptionSegue
		case showDetailsSegue
		case literatureDetailsSegue
		case gameDetailsSegue
		case songsListSegue
		case exploreSegue
		case characterSegue
		case personSegue
		case songDetailsSegue
		case showsListSegue
		case literaturesListSegue
		case gamesListSegue
		case charactersListSegue
		case peopleListSegue
		case reCapSegue
		case episodeDetailsSegue
		case episodesListSegue
		case genresSegue
		case themesSegue
		case legalSegue
		case seasonalBrowseSegue
	}

	// MARK: - Views
	var profileBarButtonItem: ProfileBarButtonItem?
	#if DEBUG
	var apiBarButtonItem: UIBarButtonItem!
	#endif

	// MARK: - Properties
	lazy var genre: Genre? = nil
	lazy var theme: Theme? = nil
	let quickLinks: [QuickLink] = [
		QuickLink(title: L10n.quickLinkIAP, url: "https://kurozora.app/kb/iap"),
		QuickLink(title: L10n.quickLinkPersonalization, url: "https://kurozora.app/kb/personalization"),
		QuickLink(title: L10n.quickLinkWelcome, url: "https://kurozora.app/welcome"),
	]
	var upNextCategory: ExploreCategory?
	var quickActions: [QuickAction] = []

	var exploreCategories: [ExploreCategory] = [] {
		didSet {
			if !self.suppressDataSourceUpdate {
				self.updateDataSource()
			}
			self._prefersActivityIndicatorHidden = true
			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
			#endif
		}
	}

	/// When `true`, mutations of ``exploreCategories`` skip the full ``updateDataSource()`` rebuild.
	private var suppressDataSourceUpdate = false

	/// When `true`, an Up Next refresh is in flight and further requests coalesce into one.
	private var isRefreshingUpNext = false

	/// When `true`, a refresh arrived mid-flight and runs once the current one finishes.
	private var needsUpNextRefresh = false

	/// Stable identifier for the Quick Links section so it persists across snapshot rebuilds.
	let quickLinksSectionID = UUID()

	/// Stable identifier for the Quick Actions section so it persists across snapshot rebuilds.
	let quickActionsSectionID = UUID()

	/// Stable identifier for the Legal section so it persists across snapshot rebuilds.
	let legalSectionID = UUID()

	/// Stable identifier for the singleton Legal item so it persists across snapshot rebuilds.
	let legalItemID = UUID()

	/// The static ``ItemKind`` values for the Quick Links section, built once so their UUIDs stay stable.
	lazy var quickLinkItemKinds: [ItemKind] = self.quickLinks.map { .quickLink($0) }

	var cache: [ItemKind: KurozoraItem] = [:]

	/// The number of items an explore category shows.
	static let exploreCategoryItemLimit = 10
	var isFetchingSection: Set<SectionLayoutKind> = []

	/// The resolved Apple Music songs keyed by Apple Music identifier.
	var resolvedSongs: [Int: MKSong] = [:]

	/// Observes local library mutations to refresh visible cells.
	private var libraryObserver: LocalLibraryEntryObserver?

	/// Observes playback changes so visible song cells reflect the currently playing song.
	private var playbackObserver: AnyCancellable?

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

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

	// MARK: - Initializers
	@available(*, unavailable)
	@MainActor required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override init() {
		super.init()
	}

	/// Initialize a new instance of HomeCollectionViewController with the given genre object.
	///
	/// - Parameter genre: The genre object to use when initializing the view.
	init(with genre: Genre) {
		super.init()
		self.genre = genre
	}

	/// Initialize a new instance of HomeCollectionViewController with the given theme object.
	///
	/// - Parameter theme: The theme object to use when initializing the view.
	init(with theme: Theme) {
		super.init()
		self.theme = theme
	}

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.configureQuickActions()
			self.configureUserDetails()
			self.handleRefreshControl()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		NotificationCenter.default.addObserver(self, selector: #selector(self.handleEpisodeWatchStatusDidUpdate(_:)), name: .KEpisodeWatchStatusDidUpdate, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleLibraryStoreDidHydrate(_:)), name: .KLibraryStoreDidHydrate, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleUpNextDidChangeRemotely(_:)), name: .KUpNextDidChangeRemotely, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleEpisodeWatchStatusDidSync(_:)), name: .KEpisodeWatchStatusDidSync, object: nil)

		// Add Refresh Control to Collection View
		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		// Play confetti if it's a special day
		ConfettiManager.shared.play()

		// Configurations
		self.configureQuickActions()
		self.configureDataSource()
		self.configureNavigationItems()
		self.observeLibraryChanges()
		self.observePlaybackChanges()

		// Fetch explore details.
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchExplore()
		}
	}

	/// Subscribes to local library mutations affecting the visible cells.
	private func observeLibraryChanges() {
		guard let slug = User.current?.attributes.slug else { return }
		self.libraryObserver = LocalLibraryEntryObserver(
			matching: LocalLibraryEntryObserver.matches(userSlug: slug),
			onChange: { [weak self] entry in
				self?.applyLibraryEntryChange(forTrackableID: entry.trackableID, userSlug: entry.userSlug, kind: entry.kind, isRemoval: false)
				self?.refreshUpNext()
				WatchSessionManager.shared.notifyUpNextDidChange()
			},
			onRemove: { [weak self] removed in
				self?.applyLibraryEntryChange(forTrackableID: removed.trackableID, userSlug: removed.userSlug, kind: removed.kind, isRemoval: true)
				self?.refreshUpNext()
				WatchSessionManager.shared.notifyUpNextDidChange()
			}
		)
	}

	/// Reconfigures every cached show/literature/game item once the overlay cache is ready.
	@objc private func handleLibraryStoreDidHydrate(_ notification: Notification) {
		Task { @MainActor [weak self] in
			guard let self = self else { return }

			self.reconfigureItems { item in
				switch item {
				case .showIdentity, .literatureIdentity, .gameIdentity:
					return self.cache[item] != nil
				default:
					return false
				}
			}
		}
	}

	/// Updates every cached show/literature/game whose identity matches the given trackable identity.
	private func applyLibraryEntryChange(forTrackableID trackableID: String, userSlug: String, kind: LibraryKind, isRemoval: Bool) {
		self.reconfigureItems { item in
			switch (item, kind) {
			case (.showIdentity(let identity, _), .shows):
				return identity.id.rawValue == trackableID && self.cache[item] is Show
			case (.literatureIdentity(let identity, _), .literatures):
				return identity.id.rawValue == trackableID && self.cache[item] is Literature
			case (.gameIdentity(let identity, _), .games):
				return identity.id.rawValue == trackableID && self.cache[item] is Game
			default:
				return false
			}
		}
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
	func song(at indexPath: IndexPath) -> KKSong? {
		return (self.cachedItem(at: indexPath) as? ShowSong)?.song
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.title = self.genre?.attributes.name ?? self.theme?.attributes.name ?? L10n.explore
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		// Show what's new in the app if necessary
		self.showWhatsNew()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		// Stop confetti when user navigates away
		ConfettiManager.shared.stop()
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchExplore()
		}
	}

	override func layoutContainerWidthDidChange() {
		self.remeasureAllCellHeights()
	}

	override func cellHeightEnvironmentDidChange() {
		self.remeasureAllCellHeights()
	}

	#if DEBUG
	override func measuredItemWidth(forSectionAt section: Int) -> CGFloat? {
		guard let sectionIdentifier = self.snapshot?.sectionIdentifiers[safe: section] else { return nil }

		return self.measuredItemWidth(forSection: sectionIdentifier)
	}
	#endif

	/// Configures the profile bar button item.
	private func configureProfileBarButtonItem() {
		self.profileBarButtonItem = ProfileBarButtonItem(primaryAction: UIAction { [weak self] _ in
			guard let self = self else { return }
			Task {
				await self.segueToProfile()
			}
		})

		if let profileBarButtonItem = self.profileBarButtonItem {
			self.navigationItem.rightBarButtonItem = profileBarButtonItem
		}

		self.configureUserDetails()
	}

	/// Configures the navigation items.
	fileprivate func configureNavigationItems() {
		self.configureProfileBarButtonItem()

		#if DEBUG
		if self.genre == nil && self.theme == nil {
			self.apiBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "globe"))
			self.populateAPIEndpoints()

			self.navigationItem.leftBarButtonItem = self.apiBarButtonItem
		}
		#endif

		self.configureKotodamaBarButtonItem()
	}

	/// Configures the bar button item that opens Kotodama.
	///
	/// The item stands in for the Kotodama tab on layouts that don't carry one.
	private func configureKotodamaBarButtonItem() {
		guard self.genre == nil, self.theme == nil else { return }
		guard !TabBarItem.tabBarCases.contains(.kotodama) else { return }

		let kotodamaBarButtonItem = UIBarButtonItem(
			image: TabBarItem.kotodama.imageValue,
			primaryAction: UIAction { [weak self] _ in
				guard let self = self else { return }
				self.show(KotodamaHubCollectionViewController(), sender: nil)
			}
		)
		kotodamaBarButtonItem.accessibilityLabel = L10n.kotodama

		self.navigationItem.leftBarButtonItems = (self.navigationItem.leftBarButtonItems ?? []) + [kotodamaBarButtonItem]
	}

	#if DEBUG
	/// Builds and presents the API endpoints in an action sheet.
	fileprivate func populateAPIEndpoints() {
		var menuItems: [UIMenuElement] = []

		APIEndpoints.forEach { apiEndpoint in
			let actionIsOn = apiEndpoint.baseURL == KService.apiEndpoint.baseURL

			let action = UIAction(title: apiEndpoint.baseURL, state: actionIsOn ? .on : .off) { _ in
				self.changeAPIEndpoint(to: apiEndpoint)
			}
			menuItems.append(action)
		}

		self.apiBarButtonItem.menu = UIMenu(title: "", children: [UIDeferredMenuElement.uncached { [weak self] completion in
			guard let self = self else { return }
			completion(menuItems)
			self.populateAPIEndpoints()
		}])
	}

	/// Changes the API endpoint to the given one.
	///
	/// - Parameters:
	///    - apiEndpoint: The desired API endpoint to be used.
	fileprivate func changeAPIEndpoint(to apiEndpoint: KurozoraAPI) {
		UserSettings.set(apiEndpoint.baseURL, forKey: .apiEndpoint)
		KService.apiEndpoint(apiEndpoint)
		NotificationCenter.default.post(name: .KUserIsSignedInDidChange, object: nil)
	}
	#endif

	/// Configure the data source of the quick actions shown to the user.
	fileprivate func configureQuickActions() {
		let title: String

		if User.current?.attributes.isSubscribed ?? false {
			title = L10n.viewSubscription
		} else {
			title = L10n.becomeASubscriber
		}

		self.quickActions = [
			QuickAction(title: L10n.redeem, segueID: SegueIdentifiers.redeemSegue),
			QuickAction(title: title, segueID: SegueIdentifiers.subscriptionSegue),
		]
	}

	/// Shows what's new in the app if necessary.
	fileprivate func showWhatsNew() {
		if WhatsNew.shouldPresent(with: .majorVersion) {
			let whatsNew = WhatsNewViewController(titleText: L10n.whatsNew, buttonText: L10n.continue, items: KWhatsNew.current)
			self.present(whatsNew, animated: true)
		}
	}

	/// Fetches the explore page from the server.
	fileprivate func fetchExplore() async {
		do {
			let exploreCategoryResponse = try await KService.explore().genre(self.genre?.id).theme(self.theme?.id).response()
			let exploreCategories = exploreCategoryResponse.data

			// Remove any empty sections
			self.exploreCategories = exploreCategories.filter { exploreCategory in
				switch exploreCategory.attributes.exploreCategoryType {
				case .shows, .upcomingShows, .mostPopularShows, .newShows:
					return !(exploreCategory.relationships.shows?.data.isEmpty ?? false)
				case .literatures, .upcomingLiteratures, .mostPopularLiteratures, .newLiteratures:
					return !(exploreCategory.relationships.literatures?.data.isEmpty ?? false)
				case .games, .upcomingGames, .mostPopularGames, .newGames:
					return !(exploreCategory.relationships.games?.data.isEmpty ?? false)
				case .episodes:
					return !(exploreCategory.relationships.episodes?.data.isEmpty ?? false)
				case .upNextEpisodes:
					self.upNextCategory = exploreCategory
					return !(exploreCategory.relationships.episodes?.data.isEmpty ?? false)
				case .songs:
					return !(exploreCategory.relationships.showSongs?.data.isEmpty ?? false)
				case .genres:
					return !(exploreCategory.relationships.genres?.data.isEmpty ?? false)
				case .themes:
					return !(exploreCategory.relationships.themes?.data.isEmpty ?? false)
				case .characters:
					return !(exploreCategory.relationships.characters?.data.isEmpty ?? false)
				case .people:
					return !(exploreCategory.relationships.people?.data.isEmpty ?? false)
				case .recap:
					return !(exploreCategory.relationships.recaps?.data.isEmpty ?? false)
				case .showsSeason:
					return !(exploreCategory.relationships.shows?.data.isEmpty ?? false)
				case .literaturesSeason:
					return !(exploreCategory.relationships.literatures?.data.isEmpty ?? false)
				case .gamesSeason:
					return !(exploreCategory.relationships.games?.data.isEmpty ?? false)
				}
			}

			let appleMusicIDs = self.exploreCategories.flatMap { exploreCategory -> [Int] in
				guard exploreCategory.attributes.exploreCategoryType == .songs else { return [] }
				return exploreCategory.relationships.showSongs?.data.prefix(10).compactMap { $0.song.attributes.amID } ?? []
			}
			_ = await MusicManager.shared.getSongs(for: appleMusicIDs)
		} catch {
			print("----- Error fetchExplore:", String(describing: error))
		}
	}

	/// Configures the view with the user's details.
	func configureUserDetails() {
		self.profileBarButtonItem?.configure(for: User.current)
	}

	/// Handles the episode watch status update notification.
	///
	/// - Parameters:
	///    - notification: An object containing information broadcast to registered observers that bridges to Notification.
	@objc func handleEpisodeWatchStatusDidUpdate(_ notification: NSNotification) {
		if let indexPath = notification.userInfo?["indexPath"] as? IndexPath,
		   let itemKind = self.dataSource.itemIdentifier(for: indexPath) {
			self.cache.removeValue(forKey: itemKind)
		}

		WatchSessionManager.shared.notifyUpNextDidChange()
	}

	/// Refetches Up Next once the watch status has reached the server.
	@objc func handleEpisodeWatchStatusDidSync(_ notification: NSNotification) {
		self.refreshUpNext()
	}

	/// Handles an Up Next change reported by the paired Watch.
	@objc func handleUpNextDidChangeRemotely(_ notification: NSNotification) {
		self.refreshUpNext()
	}

	/// Rebuilds the Up Next section, which changes whenever a title enters or leaves the library.
	private func refreshUpNext() {
		// Marking watched mutates the library and posts a watch status notification, so two
		// refreshes arrive at once. fetchEpisodes() reassigns upNextCategory while it runs, so a
		// concurrent second pass bails on a stale index or applies a stale snapshot.
		guard !self.isRefreshingUpNext else {
			self.needsUpNextRefresh = true
			return
		}

		self.isRefreshingUpNext = true

		Task { @MainActor [weak self] in
			guard let self = self else { return }

			await self.fetchEpisodes()

			self.isRefreshingUpNext = false

			guard self.needsUpNextRefresh else { return }

			self.needsUpNextRefresh = false
			self.refreshUpNext()
		}
	}

	fileprivate func fetchEpisodes() async {
		guard
			let upNextCategory = self.upNextCategory,
			let index = self.exploreCategories.firstIndex(of: upNextCategory)
		else { return }
		let exploreCategoryIdentity = ExploreCategoryIdentity(id: upNextCategory.id)

		do {
			let upNextResponse = try await KService.exploreCategory(exploreCategoryIdentity).limit(10).response()

			guard let episodeResponse = upNextResponse.data.first(where: { exploreCategory in
				exploreCategory.relationships.episodes != nil
			}) else { return }

			self.suppressDataSourceUpdate = true
			self.exploreCategories[index] = episodeResponse
			self.suppressDataSourceUpdate = false
			self.upNextCategory = episodeResponse

			var snapshot = self.dataSource.snapshot()
			guard index < snapshot.sectionIdentifiers.count else { return }

			let sectionIdentifier = snapshot.sectionIdentifiers[index]
			let oldItems = snapshot.itemIdentifiers(inSection: sectionIdentifier)
			let newItems: [ItemKind] = (episodeResponse.relationships.episodes?.data.prefix(10) ?? []).map { identity in
				.episodeIdentity(identity)
			}
			var oldModelsByIdentityID: [KurozoraItemID: KurozoraItem] = [:]

			for item in oldItems {
				guard let model = self.cache.removeValue(forKey: item) else { continue }

				oldModelsByIdentityID[model.id] = model
			}

			for item in newItems {
				guard
					let id = self.identityID(from: item),
					let model = oldModelsByIdentityID[id]
				else { continue }

				self.cache[item] = model
			}

			snapshot.deleteItems(oldItems)
			snapshot.appendItems(newItems, toSection: sectionIdentifier)
			self.snapshot = snapshot

			self.setMeasuredItems(newItems, for: sectionIdentifier)
			self.measureCellHeights(of: newItems)

			await self.dataSource.apply(snapshot, animatingDifferences: true)
		} catch {
			print(error.localizedDescription)
		}
	}

	// MARK: - SectionFetchable
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .episodeIdentity(let id, _): return id as? Element
		case .literatureIdentity(let id, _): return id as? Element
		case .showIdentity(let id, _): return id as? Element
		case .gameIdentity(let id, _): return id as? Element
		case .characterIdentity(let id, _): return id as? Element
		case .personIdentity(let id, _): return id as? Element
		case .genreIdentity(let id, _): return id as? Element
		case .themeIdentity(let id, _): return id as? Element
		default: return nil
		}
	}

	/// Returns the identity id carried by the given ``ItemKind``, or `nil` for static cases that don't represent a resource.
	///
	/// - Parameter itemKind: The item kind to inspect.
	///
	/// - Returns: The ``KurozoraItemID`` of the underlying resource, or `nil` for quick links, quick actions, and legal items.
	func identityID(from itemKind: ItemKind) -> KurozoraItemID? {
		switch itemKind {
		case .showIdentity(let identity, _): return identity.id
		case .literatureIdentity(let identity, _): return identity.id
		case .gameIdentity(let identity, _): return identity.id
		case .episodeIdentity(let identity, _): return identity.id
		case .characterIdentity(let identity, _): return identity.id
		case .personIdentity(let identity, _): return identity.id
		case .genreIdentity(let identity, _): return identity.id
		case .themeIdentity(let identity, _): return identity.id
		case .showSong(let showSong, _): return showSong.id
		case .recap(let recap, _): return recap.id
		case .quickLink, .quickAction, .legal: return nil
		}
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .exploreSegue: return HomeCollectionViewController()
		case .genresSegue: return GenresCollectionViewController()
		case .themesSegue: return ThemesCollectionViewController()
		case .showDetailsSegue: return ShowDetailsCollectionViewController()
		case .literatureDetailsSegue: return LiteratureDetailsCollectionViewController()
		case .gameDetailsSegue: return GameDetailsCollectionViewController()
		case .songsListSegue: return ShowSongsListCollectionViewController()
		case .characterSegue: return CharacterDetailsCollectionViewController()
		case .personSegue: return PersonDetailsCollectionViewController()
		case .songDetailsSegue: return SongDetailsCollectionViewController()
		case .showsListSegue: return ShowsListCollectionViewController()
		case .literaturesListSegue: return LiteraturesListCollectionViewController()
		case .gamesListSegue: return GamesListCollectionViewController()
		case .charactersListSegue: return CharactersListCollectionViewController()
		case .peopleListSegue: return PeopleListCollectionViewController()
		case .episodeDetailsSegue: return EpisodeDetailsCollectionViewController()
		case .episodesListSegue: return EpisodesListCollectionViewController()
		case .reCapSegue: return ReCapCollectionViewController()
		case .redeemSegue: return KNavigationController(rootViewController: RedeemTableViewController())
		case .subscriptionSegue: return KNavigationController(rootViewController: SubscriptionCollectionViewController())
		case .legalSegue: return KNavigationController(rootViewController: LegalViewController())
		case .seasonalBrowseSegue: return SeasonalCollectionViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .redeemSegue, .subscriptionSegue, .legalSegue, .genresSegue, .themesSegue: break
		case .showDetailsSegue:
			guard let showDetailsCollectionViewController = destination as? ShowDetailsCollectionViewController else { return }
			if let show = sender as? Show {
				showDetailsCollectionViewController.show = show
			} else if let showIdentity = sender as? ShowIdentity {
				showDetailsCollectionViewController.showIdentity = showIdentity
			}
		case .literatureDetailsSegue:
			guard let literatureDetailCollectionViewController = destination as? LiteratureDetailsCollectionViewController else { return }
			if let literature = sender as? Literature {
				literatureDetailCollectionViewController.literature = literature
			}
		case .gameDetailsSegue:
			guard let gameDetailCollectionViewController = destination as? GameDetailsCollectionViewController else { return }
			if let game = sender as? Game {
				gameDetailCollectionViewController.game = game
			}
		case .songsListSegue:
			guard let showSongsListCollectionViewController = destination as? ShowSongsListCollectionViewController else { return }
			guard let indexPath = sender as? IndexPath else { return }
			let exploreCategory = self.exploreCategories[indexPath.section]
			showSongsListCollectionViewController.title = exploreCategory.attributes.title
			showSongsListCollectionViewController.showSongs = exploreCategory.relationships.showSongs?.data ?? []
		case .exploreSegue:
			guard let homeCollectionViewController = destination as? HomeCollectionViewController else { return }
			if let genre = sender as? Genre {
				homeCollectionViewController.genre = genre
			} else if let theme = sender as? Theme {
				homeCollectionViewController.theme = theme
			}
		case .characterSegue:
			guard let characterDetailsCollectionViewController = destination as? CharacterDetailsCollectionViewController else { return }
			if let character = sender as? Character {
				characterDetailsCollectionViewController.character = character
			}
		case .personSegue:
			guard let personDetailsCollectionViewController = destination as? PersonDetailsCollectionViewController else { return }
			if let person = sender as? Person {
				personDetailsCollectionViewController.person = person
			}
		case .songDetailsSegue:
			guard let songDetailsCollectionViewController = destination as? SongDetailsCollectionViewController else { return }
			if let song = sender as? Song {
				songDetailsCollectionViewController.song = song
			}
		case .showsListSegue:
			guard let showsListCollectionViewController = destination as? ShowsListCollectionViewController else { return }
			guard let indexPath = sender as? IndexPath else { return }
			let exploreCategory = self.exploreCategories[indexPath.section]

			showsListCollectionViewController.title = self.exploreCategories[indexPath.section].attributes.title

			if exploreCategory.attributes.exploreCategoryType == .upcomingShows {
				showsListCollectionViewController.showsListFetchType = .upcoming
			} else {
				showsListCollectionViewController.exploreCategoryIdentity = ExploreCategoryIdentity(id: exploreCategory.id)
				showsListCollectionViewController.showsListFetchType = .explore
			}
		case .literaturesListSegue:
			guard let literaturesListCollectionViewController = destination as? LiteraturesListCollectionViewController else { return }
			guard let indexPath = sender as? IndexPath else { return }
			let exploreCategory = self.exploreCategories[indexPath.section]

			literaturesListCollectionViewController.title = self.exploreCategories[indexPath.section].attributes.title

			if exploreCategory.attributes.exploreCategoryType == .upcomingLiteratures {
				literaturesListCollectionViewController.literaturesListFetchType = .upcoming
			} else {
				literaturesListCollectionViewController.exploreCategoryIdentity = ExploreCategoryIdentity(id: exploreCategory.id)
				literaturesListCollectionViewController.literaturesListFetchType = .explore
			}
		case .gamesListSegue:
			guard let gamesListCollectionViewController = destination as? GamesListCollectionViewController else { return }
			guard let indexPath = sender as? IndexPath else { return }
			let exploreCategory = self.exploreCategories[indexPath.section]

			gamesListCollectionViewController.title = self.exploreCategories[indexPath.section].attributes.title

			if exploreCategory.attributes.exploreCategoryType == .upcomingGames {
				gamesListCollectionViewController.gamesListFetchType = .upcoming
			} else {
				gamesListCollectionViewController.exploreCategoryIdentity = ExploreCategoryIdentity(id: exploreCategory.id)
				gamesListCollectionViewController.gamesListFetchType = .explore
			}
		case .charactersListSegue:
			guard let charactersListCollectionViewController = destination as? CharactersListCollectionViewController else { return }
			guard let indexPath = sender as? IndexPath else { return }
			let exploreCategory = self.exploreCategories[indexPath.section]
			charactersListCollectionViewController.title = exploreCategory.attributes.title
			charactersListCollectionViewController.exploreCategoryIdentity = ExploreCategoryIdentity(id: exploreCategory.id)
			charactersListCollectionViewController.charactersListFetchType = .explore
		case .peopleListSegue:
			guard let peopleListCollectionViewController = destination as? PeopleListCollectionViewController else { return }
			guard let indexPath = sender as? IndexPath else { return }
			let exploreCategory = self.exploreCategories[indexPath.section]
			peopleListCollectionViewController.title = exploreCategory.attributes.title
			peopleListCollectionViewController.exploreCategoryIdentity = ExploreCategoryIdentity(id: exploreCategory.id)
			peopleListCollectionViewController.peopleListFetchType = .explore
		case .reCapSegue:
			guard let reCapCollectionViewController = destination as? ReCapCollectionViewController else { return }
			guard let recap = sender as? Recap else { return }
			reCapCollectionViewController.year = recap.attributes.year
			reCapCollectionViewController.month = recap.attributes.month
		case .episodeDetailsSegue:
			guard let episodeDetailsCollectionViewController = destination as? EpisodeDetailsCollectionViewController else { return }
			guard let episodeDict = (sender as? [IndexPath: Episode])?.first else { return }
			episodeDetailsCollectionViewController.indexPath = episodeDict.key
			episodeDetailsCollectionViewController.episode = episodeDict.value
		case .episodesListSegue:
			guard let episodesListCollectionViewController = destination as? EpisodesListCollectionViewController else { return }
			if let seasonIdentity = sender as? SeasonIdentity {
				episodesListCollectionViewController.seasonIdentity = seasonIdentity
				episodesListCollectionViewController.episodesListFetchType = .season
			} else if let upNextCategory = self.upNextCategory {
				episodesListCollectionViewController.episodesListFetchType = .upNext(exploreCategory: upNextCategory)
			}
		case .seasonalBrowseSegue:
			guard let seasonalCollectionViewController = destination as? SeasonalCollectionViewController else { return }
			guard let indexPath = sender as? IndexPath else { return }
			let exploreCategory = self.exploreCategories[indexPath.section]
			var serverCalendar = Calendar(identifier: .gregorian)
			serverCalendar.timeZone = TimeZone(identifier: "UTC") ?? .current

			let upcomingDate = serverCalendar.date(byAdding: .day, value: 3, to: Date()) ?? Date()
			let upcomingDay = serverCalendar.dateComponents([.year, .month, .day], from: upcomingDate)
			let (year, season) = SeasonOfYear.yearAndSeason(from: Calendar.current.date(from: upcomingDay) ?? upcomingDate)

			seasonalCollectionViewController.year = year
			seasonalCollectionViewController.season = season

			switch exploreCategory.attributes.exploreCategoryType {
			case .showsSeason:
				seasonalCollectionViewController.kind = .shows
			case .literaturesSeason:
				seasonalCollectionViewController.kind = .literatures
			case .gamesSeason:
				seasonalCollectionViewController.kind = .games
			default: break
			}
		}
	}
}

// MARK: - Measurement
extension HomeCollectionViewController {
	func measuredItemWidth(for section: SectionLayoutKind, containerWidth: CGFloat) -> CGFloat? {
		let columns = self.columnCount(forSection: section, width: containerWidth)

		switch section {
		case .quickLinks, .legal:
			return Layouts.itemWidth(columns: columns, containerWidth: containerWidth, isHorizontal: false)
		case .quickActions:
			let isCompactWidth = self.traitCollection.horizontalSizeClass == .compact

			return Layouts.quickActionItemWidth(columns: columns, containerWidth: containerWidth, isCompactWidth: isCompactWidth)
		default:
			return Layouts.itemWidth(columns: columns, containerWidth: containerWidth, isHorizontal: true)
		}
	}

	func measurableItem(for itemKind: ItemKind, in section: SectionLayoutKind) -> CellHeightMeasurer.Item? {
		switch section {
		case .banner:
			return self.showMeasurableItem(for: itemKind, in: BannerLockupCollectionViewCell.self) { show in
				BannerLockupCollectionViewCell.measurableItem(for: show)
			}
		case .large:
			return self.showMeasurableItem(for: itemKind, in: LargeLockupCollectionViewCell.self) { show in
				LargeLockupCollectionViewCell.measurableItem(for: show)
			}
		case .video:
			return self.showMeasurableItem(for: itemKind, in: VideoLockupCollectionViewCell.self) { show in
				VideoLockupCollectionViewCell.measurableItem(for: show)
			}
		case .upcoming:
			return self.showMeasurableItem(for: itemKind, in: UpcomingLockupCollectionViewCell.self) { show in
				UpcomingLockupCollectionViewCell.measurableItem(for: show)
			}
		case .episode:
			return self.episodeMeasurableItem(for: itemKind)
		case .medium:
			return self.mediumMeasurableItem(for: itemKind)
		case .small:
			return self.smallMeasurableItem(for: itemKind)
		case .profile:
			return self.profileMeasurableItem(for: itemKind)
		case .music:
			return self.musicMeasurableItem(for: itemKind)
		case .quickLinks:
			return self.quickLinkMeasurableItem(for: itemKind)
		case .quickActions:
			return self.quickActionMeasurableItem(for: itemKind)
		case .legal:
			return LegalCollectionViewCell.measurableItem()
		}
	}

	/// Returns the item that measures the given item's quick link cell.
	///
	/// - Parameter itemKind: The item whose cell is measured.
	///
	/// - Returns: The item that measures the cell.
	private func quickLinkMeasurableItem(for itemKind: ItemKind) -> CellHeightMeasurer.Item? {
		switch itemKind {
		case .quickLink(let quickLink, _):
			return ActionLinkExploreCollectionViewCell.measurableItem(for: quickLink)
		default:
			return nil
		}
	}

	/// Returns the item that measures the given item's quick action cell.
	///
	/// - Parameter itemKind: The item whose cell is measured.
	///
	/// - Returns: The item that measures the cell.
	private func quickActionMeasurableItem(for itemKind: ItemKind) -> CellHeightMeasurer.Item? {
		switch itemKind {
		case .quickAction(let quickAction, _):
			return ActionButtonExploreCollectionViewCell.measurableItem(for: quickAction)
		default:
			return nil
		}
	}

	/// Returns the item that measures the given item's show cell.
	///
	/// - Parameters:
	///    - itemKind: The item whose cell is measured.
	///    - cellType: The type of cell the show is rendered in.
	///    - measurableItem: Returns the item that measures a cached show.
	///
	/// - Returns: The item that measures the cell.
	private func showMeasurableItem<Cell: BaseLockupCollectionViewCell>(for itemKind: ItemKind, in cellType: Cell.Type, measurableItem: (Show) -> CellHeightMeasurer.Item) -> CellHeightMeasurer.Item {
		let show: Show? = self.fetchModel(for: itemKind)

		guard let show = show else {
			return CellHeightMeasurer.Item(cellType: cellType, isSkeleton: true) { cell in
				cell.configure(using: nil as Show?, scheduleIsShown: false)
			}
		}

		return measurableItem(show)
	}

	/// Returns the item that measures the given item's episode cell.
	///
	/// - Parameter itemKind: The item whose cell is measured.
	///
	/// - Returns: The item that measures the cell.
	private func episodeMeasurableItem(for itemKind: ItemKind) -> CellHeightMeasurer.Item {
		let episode: Episode? = self.fetchModel(for: itemKind)

		guard let episode = episode else {
			return CellHeightMeasurer.Item(cellType: EpisodeLockupCollectionViewCell.self, isSkeleton: true) { cell in
				cell.configure(using: nil as Episode?)
			}
		}

		return EpisodeLockupCollectionViewCell.measurableItem(for: episode)
	}

	/// Returns the item that measures the given item's medium cell.
	///
	/// - Parameter itemKind: The item whose cell is measured.
	///
	/// - Returns: The item that measures the cell.
	private func mediumMeasurableItem(for itemKind: ItemKind) -> CellHeightMeasurer.Item? {
		switch itemKind {
		case .genreIdentity:
			let genre: Genre? = self.fetchModel(for: itemKind)

			guard let genre = genre else {
				return CellHeightMeasurer.Item(cellType: MediumLockupCollectionViewCell.self, isSkeleton: true) { cell in
					cell.configure(using: nil as Genre?)
				}
			}

			return MediumLockupCollectionViewCell.measurableItem(for: genre)
		case .themeIdentity:
			let theme: Theme? = self.fetchModel(for: itemKind)

			guard let theme = theme else {
				return CellHeightMeasurer.Item(cellType: MediumLockupCollectionViewCell.self, isSkeleton: true) { cell in
					cell.configure(using: nil as Theme?)
				}
			}

			return MediumLockupCollectionViewCell.measurableItem(for: theme)
		default:
			return nil
		}
	}

	/// Returns the item that measures the given item's small cell.
	///
	/// - Parameter itemKind: The item whose cell is measured.
	///
	/// - Returns: The item that measures the cell.
	private func smallMeasurableItem(for itemKind: ItemKind) -> CellHeightMeasurer.Item? {
		switch itemKind {
		case .showIdentity:
			return self.showMeasurableItem(for: itemKind, in: SmallLockupCollectionViewCell.self) { show in
				SmallLockupCollectionViewCell.measurableItem(for: show)
			}
		case .literatureIdentity:
			let literature: Literature? = self.fetchModel(for: itemKind)

			guard let literature = literature else {
				return CellHeightMeasurer.Item(cellType: SmallLockupCollectionViewCell.self, isSkeleton: true) { cell in
					cell.configure(using: nil as Literature?)
				}
			}

			return SmallLockupCollectionViewCell.measurableItem(for: literature)
		case .gameIdentity:
			let game: Game? = self.fetchModel(for: itemKind)

			guard let game = game else {
				return CellHeightMeasurer.Item(cellType: GameLockupCollectionViewCell.self, isSkeleton: true) { cell in
					cell.configure(using: nil as Game?)
				}
			}

			return GameLockupCollectionViewCell.measurableItem(for: game)
		case .episodeIdentity:
			return self.episodeMeasurableItem(for: itemKind)
		case .recap:
			let recap: Recap? = self.fetchModel(for: itemKind)

			guard let recap = recap else {
				return CellHeightMeasurer.Item(cellType: RecapPosterLockupCollectionViewCell.self, isSkeleton: true) { cell in
					cell.configure(using: nil as Recap?)
				}
			}

			return RecapPosterLockupCollectionViewCell.measurableItem(for: recap)
		default:
			return nil
		}
	}

	/// Returns the item that measures the given item's profile cell.
	///
	/// - Parameter itemKind: The item whose cell is measured.
	///
	/// - Returns: The item that measures the cell.
	private func profileMeasurableItem(for itemKind: ItemKind) -> CellHeightMeasurer.Item? {
		switch itemKind {
		case .characterIdentity:
			let character: Character? = self.fetchModel(for: itemKind)

			guard let character = character else {
				return CellHeightMeasurer.Item(cellType: ProfileLockupCollectionViewCell.self, isSkeleton: true) { cell in
					cell.configure(using: nil as Character?)
				}
			}

			return ProfileLockupCollectionViewCell.measurableItem(for: character)
		case .personIdentity:
			let person: Person? = self.fetchModel(for: itemKind)

			guard let person = person else {
				return CellHeightMeasurer.Item(cellType: ProfileLockupCollectionViewCell.self, isSkeleton: true) { cell in
					cell.configure(using: nil as Person?)
				}
			}

			return ProfileLockupCollectionViewCell.measurableItem(for: person)
		default:
			return nil
		}
	}

	/// Returns the item that measures the given item's music cell.
	///
	/// - Parameter itemKind: The item whose cell is measured.
	///
	/// - Returns: The item that measures the cell.
	private func musicMeasurableItem(for itemKind: ItemKind) -> CellHeightMeasurer.Item {
		let showSong: ShowSong? = self.fetchModel(for: itemKind)

		guard let showSong = showSong else {
			return CellHeightMeasurer.Item(cellType: MusicLockupCollectionViewCell.self, isSkeleton: true) { cell in
				cell.configure(using: nil as ShowSong?, at: MusicLockupCollectionViewCell.measurementIndexPath, showEpisodes: false, showShow: true)
			}
		}

		return MusicLockupCollectionViewCell.measurableItem(for: showSong, showEpisodes: false, showShow: true)
	}
}

// MARK: - NSTouchBarDelegate
#if targetEnvironment(macCatalyst)
extension HomeCollectionViewController: NSTouchBarDelegate {
	override func makeTouchBar() -> NSTouchBar? {
		let touchBar = NSTouchBar()
		touchBar.delegate = self
		touchBar.defaultItemIdentifiers = [
			.fixedSpaceSmall,
			.fixedSpaceSmall
		]
		return touchBar
	}

	func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
		let touchBarItem: NSTouchBarItem?

		switch identifier {
		default:
			touchBarItem = nil
		}
		return touchBarItem
	}
}
#endif
