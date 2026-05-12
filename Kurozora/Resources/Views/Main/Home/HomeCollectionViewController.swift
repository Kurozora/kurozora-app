//
//  HomeCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KurozoraKit
import SPConfetti
import UIKit
import WhatsNew

class HomeCollectionViewController: KCollectionViewController, SectionFetchable, ProfileNavigable, TypedSegueHandling {
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
		QuickLink(title: "About In-App Purchases", url: "https://kurozora.app/kb/iap"),
		QuickLink(title: "About Personalisation", url: "https://kurozora.app/kb/personalisation"),
		QuickLink(title: "Welcome to Kurozora", url: "https://kurozora.app/welcome"),
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

	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

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

		// Fetch explore details.
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchExplore()
		}
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
		self.profileBarButtonItem?.image = User.current?.attributes.profileImageView.image ?? .Placeholders.userProfile
	}

	/// Handles the episode watch status update notification.
	///
	/// - Parameters:
	///    - notification: An object containing information broadcast to registered observers that bridges to Notification.
	@objc func handleEpisodeWatchStatusDidUpdate(_ notification: NSNotification) {
		Task { @MainActor [weak self] in
			guard let self = self else { return }
			await self.fetchEpisodes()
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
			var oldItemsByIdentityID: [KurozoraItemID: ItemKind] = [:]

			for item in oldItems {
				guard let id = self.identityID(from: item) else { continue }
				oldItemsByIdentityID[id] = item
			}

			let newItems: [ItemKind] = (episodeResponse.relationships.episodes?.data.prefix(10) ?? []).map { identity in
				oldItemsByIdentityID[identity.id] ?? .episodeIdentity(identity)
			}
			var oldModelsByIdentityID: [KurozoraItemID: KurozoraItem] = [:]

			for (indexPath, model) in self.cache where indexPath.section == index {
				oldModelsByIdentityID[model.id] = model
			}

			self.cache = self.cache.filter { $0.key.section != index }

			for (itemIndex, item) in newItems.enumerated() {
				guard
					let id = self.identityID(from: item),
					let model = oldModelsByIdentityID[id]
				else { continue }
				self.cache[IndexPath(item: itemIndex, section: index)] = model
			}

			snapshot.deleteItems(oldItems)
			snapshot.appendItems(newItems, toSection: sectionIdentifier)
			self.snapshot = snapshot
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
		}
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
