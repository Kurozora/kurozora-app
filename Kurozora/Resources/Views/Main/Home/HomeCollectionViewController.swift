//
//  HomeCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import Alamofire
import KurozoraKit
import SPConfetti
import TRON
import UIKit
import WhatsNew

class HomeCollectionViewController: KCollectionViewController, SectionFetchable, StoryboardInstantiable {
	static var storyboardName: String = "Home"

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

	// MARK: - IBOutlets
	@IBOutlet weak var profileImageButton: ProfileImageButton!

	#if DEBUG
	// Views
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
			self.updateDataSource()
			self._prefersActivityIndicatorHidden = true
			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
			#endif
		}
	}

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
	/// Initialize a new instance of HomeCollectionViewController with the given genre object.
	///
	/// - Parameter genre: The genre object to use when initializing the view.
	///
	/// - Returns: an initialized instance of HomeCollectionViewController.
	func callAsFunction(with genre: Genre) -> HomeCollectionViewController {
		let homeCollectionViewController = HomeCollectionViewController.instantiate()
			homeCollectionViewController.genre = genre
		return homeCollectionViewController
	}

	/// Initialize a new instance of HomeCollectionViewController with the given theme object.
	///
	/// - Parameter theme: The theme object to use when initializing the view.
	///
	/// - Returns: an initialized instance of HomeCollectionViewController.
	func callAsFunction(with theme: Theme) -> HomeCollectionViewController {
		let homeCollectionViewController = HomeCollectionViewController.instantiate()
			homeCollectionViewController.theme = theme
		return homeCollectionViewController
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
		self.configureUserDetails()
		#if DEBUG
		self.configureNavigationItems()
		#endif

		// Fetch explore details.
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchExplore()
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.title = self.genre?.attributes.name ?? self.theme?.attributes.name ?? "Explore"
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

	#if DEBUG
	/// Configures the navigation items.
	fileprivate func configureNavigationItems() {
		guard self.genre == nil && self.theme == nil else { return }

		self.apiBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "globe"))
		self.populateAPIEndpoints()

		self.navigationItem.leftBarButtonItem = self.apiBarButtonItem
	}

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
			title = Trans.viewSubscription
		} else {
			title = Trans.becomeASubscriber
		}

		self.quickActions = [
			QuickAction(title: Trans.redeem, segueID: SegueIdentifiers.redeemSegue),
			QuickAction(title: title, segueID: SegueIdentifiers.subscriptionSegue),
		]
	}

	/// Shows what's new in the app if necessary.
	fileprivate func showWhatsNew() {
		if WhatsNew.shouldPresent(with: .majorVersion) {
			let whatsNew = WhatsNewViewController(titleText: Trans.whatsNew, buttonText: Trans.continue, items: KWhatsNew.current)
			self.present(whatsNew, animated: true)
		}
	}

	/// Fetches the explore page from the server.
	fileprivate func fetchExplore() async {
		do {
			let exploreCategoryResponse = try await KService.getExplore(genreID: self.genre?.id, themeID: self.theme?.id).value
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
		} catch {
			print("----- Error fetchExplore:", String(describing: error))
		}
	}

	/// Configures the view with the user's details.
	func configureUserDetails() {
		self.profileImageButton.setImage(User.current?.attributes.profileImageView.image ?? .Placeholders.userProfile, for: .normal)
	}

	/// Performs segue to the profile view.
	@objc func segueToProfile() {
		Task {
			let isSignedIn = await WorkflowController.shared.isSignedIn()
			guard isSignedIn else { return }

			let profileTableViewController = ProfileTableViewController.instantiate()
			self.show(profileTableViewController, sender: nil)
		}
	}

	/// Handles the episode watch status update notification.
	///
	/// - Parameters:
	///    - notification: An object containing information broadcast to registered observers that bridges to Notification.
	@objc func handleEpisodeWatchStatusDidUpdate(_ notification: NSNotification) {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }

			if let indexPath = notification.userInfo?["indexPath"] as? IndexPath, let selectedEpisode = self.dataSource.itemIdentifier(for: indexPath) {
				var newSnapshot = self.dataSource.snapshot()
				newSnapshot.reloadItems([selectedEpisode])
				self.dataSource.apply(newSnapshot)
			}
		}
	}

	// MARK: - IBActions
	@IBAction func profileButtonPressed(_ sender: UIButton) {
		self.segueToProfile()
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

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard
			let segueIdentifier = segue.identifier,
			let segueID = SegueIdentifiers(rawValue: segueIdentifier)
		else { return }

		switch segueID {
		case .showDetailsSegue:
			// Segue to show details
			guard let showDetailsCollectionViewController = segue.destination as? ShowDetailsCollectionViewController else { return }
			if let show = sender as? Show {
				showDetailsCollectionViewController.show = show
			} else if let showIdentity = sender as? ShowIdentity {
				showDetailsCollectionViewController.showIdentity = showIdentity
			}
		case .literatureDetailsSegue:
			// Segue to show details
			guard let literatureDetailCollectionViewController = segue.destination as? LiteratureDetailsCollectionViewController else { return }
			guard let literature = sender as? Literature else { return }
			literatureDetailCollectionViewController.literature = literature
		case .gameDetailsSegue:
			// Segue to show details
			guard let gameDetailCollectionViewController = segue.destination as? GameDetailsCollectionViewController else { return }
			guard let game = sender as? Game else { return }
			gameDetailCollectionViewController.game = game
		case .songsListSegue:
			// Segue to show songs list
			guard let showSongsListCollectionViewController = segue.destination as? ShowSongsListCollectionViewController else { return }
			guard let indexPath = sender as? IndexPath else { return }
			let exploreCategory = self.exploreCategories[indexPath.section]
			showSongsListCollectionViewController.title = exploreCategory.attributes.title
			showSongsListCollectionViewController.showSongs = exploreCategory.relationships.showSongs?.data ?? []
		case .exploreSegue:
			// Segue to genre or theme explore
			guard let homeCollectionViewController = segue.destination as? HomeCollectionViewController else { return }
			if let genre = sender as? Genre {
				homeCollectionViewController.genre = genre
			} else if let theme = sender as? Theme {
				homeCollectionViewController.theme = theme
			}
		case .characterSegue:
			// Segue to character details
			guard let characterDetailsCollectionViewController = segue.destination as? CharacterDetailsCollectionViewController else { return }
			guard let character = sender as? Character else { return }
			characterDetailsCollectionViewController.character = character
		case .personSegue:
			// Segue to person details
			guard let personDetailsCollectionViewController = segue.destination as? PersonDetailsCollectionViewController else { return }
			guard let person = sender as? Person else { return }
			personDetailsCollectionViewController.person = person
		case .songDetailsSegue:
			// Segue to song details
			guard let songDetailsCollectionViewController = segue.destination as? SongDetailsCollectionViewController else { return }
			guard let song = sender as? Song else { return }
			songDetailsCollectionViewController.song = song
		case .showsListSegue:
			// Segue to shows list
			guard let showsListCollectionViewController = segue.destination as? ShowsListCollectionViewController else { return }
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
			// Segue to literatures list
			guard let literaturesListCollectionViewController = segue.destination as? LiteraturesListCollectionViewController else { return }
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
			// Segue to games list
			guard let gamesListCollectionViewController = segue.destination as? GamesListCollectionViewController else { return }
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
			// Segue to characters list
			guard let charactersListCollectionViewController = segue.destination as? CharactersListCollectionViewController else { return }
			guard let indexPath = sender as? IndexPath else { return }
			let exploreCategory = self.exploreCategories[indexPath.section]
			charactersListCollectionViewController.title = exploreCategory.attributes.title
			charactersListCollectionViewController.exploreCategoryIdentity = ExploreCategoryIdentity(id: exploreCategory.id)
			charactersListCollectionViewController.charactersListFetchType = .explore
		case .peopleListSegue:
			// Segue to people list
			guard let peopleListCollectionViewController = segue.destination as? PeopleListCollectionViewController else { return }
			guard let indexPath = sender as? IndexPath else { return }
			let exploreCategory = self.exploreCategories[indexPath.section]
			peopleListCollectionViewController.title = exploreCategory.attributes.title
			peopleListCollectionViewController.exploreCategoryIdentity = ExploreCategoryIdentity(id: exploreCategory.id)
			peopleListCollectionViewController.peopleListFetchType = .explore
		case .reCapSegue:
			guard let reCapCollectionViewController = segue.destination as? ReCapCollectionViewController else { return }
			guard let recap = sender as? Recap else { return }
			reCapCollectionViewController.year = recap.attributes.year
			reCapCollectionViewController.month = recap.attributes.month
		case .episodeDetailsSegue:
			// Segue to episode details
			guard let episodeDetailsCollectionViewController = segue.destination as? EpisodeDetailsCollectionViewController else { return }
			guard let episodeDict = (sender as? [IndexPath: Episode])?.first else { return }
			episodeDetailsCollectionViewController.indexPath = episodeDict.key
			episodeDetailsCollectionViewController.episode = episodeDict.value
		case .episodesListSegue:
			// Segue to episodes list
			guard let episodesListCollectionViewController = segue.destination as? EpisodesListCollectionViewController else { return }
			if let seasonIdentity = sender as? SeasonIdentity {
				episodesListCollectionViewController.seasonIdentity = seasonIdentity
				episodesListCollectionViewController.episodesListFetchType = .season
			} else if let upNextCategory = self.upNextCategory {
				episodesListCollectionViewController.episodesListFetchType = .upNext(exploreCategory: upNextCategory)
			}
		default: break
		}
	}
}

// MARK: - TitleHeaderCollectionReusableViewDelegate
extension HomeCollectionViewController: TitleHeaderCollectionReusableViewDelegate {
	func titleHeaderCollectionReusableView(_ reusableView: TitleHeaderCollectionReusableView, didPress button: UIButton) {
		guard let segueID = reusableView.segueID else { return }
		self.performSegue(withIdentifier: segueID, sender: reusableView.indexPath)
	}
}

// MARK: - BaseLockupCollectionViewCellDelegate
extension HomeCollectionViewController: BaseLockupCollectionViewCellDelegate {
	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressStatus button: UIButton) async {
		let isSignedIn = await WorkflowController.shared.isSignedIn()
		guard isSignedIn else { return }

		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		let modelID: KurozoraItemID

		switch cell.libraryKind {
		case .shows:
			guard let show = self.cache[indexPath] else { return }
			modelID = show.id
		case .literatures:
			guard let literature = self.cache[indexPath] else { return }
			modelID = literature.id
		case .games:
			guard let game = self.cache[indexPath] else { return }
			modelID = game.id
		}

		let oldLibraryStatus = cell.libraryStatus
		let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: KKLibrary.Status.alertControllerItems(for: cell.libraryKind), currentSelection: oldLibraryStatus, action: { title, value in
			Task {
				do {
					let libraryUpdateResponse = try await KService.addToLibrary(cell.libraryKind, withLibraryStatus: value, modelID: modelID).value

					switch cell.libraryKind {
					case .shows:
						let show = self.cache[indexPath] as? Show
						show?.attributes.library?.update(using: libraryUpdateResponse.data)
					case .literatures:
						let literature = self.cache[indexPath] as? Literature
						literature?.attributes.library?.update(using: libraryUpdateResponse.data)
					case .games:
						let game = self.cache[indexPath] as? Game
						game?.attributes.library?.update(using: libraryUpdateResponse.data)
					}

					// Update entry in library
					cell.libraryStatus = value
					button.setTitle("\(title) ▾", for: .normal)

					let libraryAddToNotificationName = Notification.Name("AddTo\(value.sectionValue)Section")
					NotificationCenter.default.post(name: libraryAddToNotificationName, object: nil)

					// Request review
					ReviewManager.shared.requestReview(for: .itemAddedToLibrary(status: value))
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
							let show = self.cache[indexPath] as? Show
							show?.attributes.library?.update(using: libraryUpdateResponse.data)
						case .literatures:
							let literature = self.cache[indexPath] as? Literature
							literature?.attributes.library?.update(using: libraryUpdateResponse.data)
						case .games:
							let game = self.cache[indexPath] as? Game
							game?.attributes.library?.update(using: libraryUpdateResponse.data)
						}

						// Update entry in library
						cell.libraryStatus = .none
						button.setTitle(Trans.add.uppercased(), for: .normal)

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

	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressReminder button: UIButton) async {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		guard let show = self.cache[indexPath] as? Show else { return }
		await show.toggleReminder(on: self)
		cell.configureReminderButton(for: show.attributes.library?.reminderStatus)
	}
}

// MARK: - EpisodeLockupCollectionViewCellDelegate
extension HomeCollectionViewController: EpisodeLockupCollectionViewCellDelegate {
	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressWatchStatusButton button: UIButton) async {
		let isSignedIn = await WorkflowController.shared.isSignedIn()
		guard isSignedIn else { return }

		guard
			let indexPath = self.collectionView.indexPath(for: cell),
			let episode = self.cache[indexPath] as? Episode
		else { return }
		cell.watchStatusButton.isEnabled = false
		await episode.updateWatchStatus(userInfo: ["indexPath": indexPath])
		cell.watchStatusButton.isEnabled = true
	}

	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressShowButton button: UIButton) {
		guard
			let indexPath = self.collectionView.indexPath(for: cell),
			let episode = self.cache[indexPath] as? Episode,
			let showIdentity = episode.relationships?.shows?.data.first
		else { return }

		self.performSegue(withIdentifier: SegueIdentifiers.showDetailsSegue, sender: showIdentity)
	}

	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressSeasonButton button: UIButton) {
		guard
			let indexPath = self.collectionView.indexPath(for: cell),
			let episode = self.cache[indexPath] as? Episode,
			let seasonIdentity = episode.relationships?.seasons?.data.first
		else { return }

		self.performSegue(withIdentifier: SegueIdentifiers.episodesListSegue, sender: seasonIdentity)
	}
}

// MARK: - MusicLockupCollectionViewCellDelegate
extension HomeCollectionViewController: MusicLockupCollectionViewCellDelegate {
	func showButtonPressed(_ sender: UIButton, indexPath: IndexPath) {
		guard let show = self.exploreCategories[indexPath.section].relationships.showSongs?.data[indexPath.item].show else { return }
		self.performSegue(withIdentifier: SegueIdentifiers.showDetailsSegue, sender: show)
	}
}

// MARK: - ActionBaseExploreCollectionViewCellDelegate
extension HomeCollectionViewController: ActionBaseExploreCollectionViewCellDelegate {
	func actionButtonPressed(_ sender: UIButton, cell: ActionBaseExploreCollectionViewCell) {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }

		switch cell.self {
		case is ActionLinkExploreCollectionViewCell:
			let quickLink = self.quickLinks[indexPath.item]

			let kWebViewController = KWebViewController.instantiate()
			kWebViewController.title = quickLink.title
			kWebViewController.url = quickLink.url

			let kNavigationController = KNavigationController(rootViewController: kWebViewController)
			kNavigationController.modalPresentationStyle = .custom

			self.present(kNavigationController, animated: true)
		case is ActionButtonExploreCollectionViewCell:
			let quickAction = self.quickActions[indexPath.item]
			self.performSegue(withIdentifier: quickAction.segueID, sender: nil)
		default: break
		}
	}
}

// MARK: - SectionLayoutKind
extension HomeCollectionViewController {
	/// List of available Section Layout Kind types.
	enum SectionLayoutKind: Hashable {
		// MARK: - Cases
		/// Indicates a banner section layout type.
		case banner(_: ExploreCategory)

		/// Indicates a small section layout type.
		case small(_: ExploreCategory)

		/// Indicates a medium section layout type.
		case medium(_: ExploreCategory)

		/// Indicates a large section layout type.
		case large(_: ExploreCategory)

		/// Indicates a video section layout type.
		case video(_: ExploreCategory)

		/// Indicates a upcoming section layout type.
		case upcoming(_: ExploreCategory)

		/// Indicates a genre section layout type.
		case profile(_: ExploreCategory)

		/// Indicates a episode section layout type.
		case episode(_: ExploreCategory)

		/// Indicates a music section layout type.
		case music(_: ExploreCategory)

		/// Indicates a quick links section layout type.
		case quickLinks(id: UUID = UUID())

		/// Indicates a quick actions section layout type.
		case quickActions(id: UUID = UUID())

		/// Indicates a legal section layout type.
		case legal(id: UUID = UUID())

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .banner(let exploreCategory):
				hasher.combine(exploreCategory)
			case .small(let exploreCategory):
				hasher.combine(exploreCategory)
			case .medium(let exploreCategory):
				hasher.combine(exploreCategory)
			case .large(let exploreCategory):
				hasher.combine(exploreCategory)
			case .video(let exploreCategory):
				hasher.combine(exploreCategory)
			case .upcoming(let exploreCategory):
				hasher.combine(exploreCategory)
			case .profile(let exploreCategory):
				hasher.combine(exploreCategory)
			case .episode(let exploreCategory):
				hasher.combine(exploreCategory)
			case .music(let exploreCategory):
				hasher.combine(exploreCategory)
			case .quickLinks(let id):
				hasher.combine(id)
			case .quickActions(let id):
				hasher.combine(id)
			case .legal(let id):
				hasher.combine(id)
			}
		}

		static func == (lhs: SectionLayoutKind, rhs: SectionLayoutKind) -> Bool {
			switch (lhs, rhs) {
			case (.banner(let exploreCategory1), .banner(let exploreCategory2)):
				return exploreCategory1 == exploreCategory2
			case (.small(let exploreCategory1), .small(let exploreCategory2)):
				return exploreCategory1 == exploreCategory2
			case (.medium(let exploreCategory1), .medium(let exploreCategory2)):
				return exploreCategory1 == exploreCategory2
			case (.large(let exploreCategory1), .large(let exploreCategory2)):
				return exploreCategory1 == exploreCategory2
			case (.video(let exploreCategory1), .video(let exploreCategory2)):
				return exploreCategory1 == exploreCategory2
			case (.upcoming(let exploreCategory1), .upcoming(let exploreCategory2)):
				return exploreCategory1 == exploreCategory2
			case (.profile(let exploreCategory1), .profile(let exploreCategory2)):
				return exploreCategory1 == exploreCategory2
			case (.episode(let exploreCategory1), .episode(let exploreCategory2)):
				return exploreCategory1 == exploreCategory2
			case (.music(let exploreCategory1), .music(let exploreCategory2)):
				return exploreCategory1 == exploreCategory2
			case (.quickLinks(let id1), .quickLinks(let id2)):
				return id1 == id2
			case (.quickActions(let id1), .quickActions(let id2)):
				return id1 == id2
			case (.legal(let id1), .legal(let id2)):
				return id1 == id2
			default: return false
			}
		}
	}
}

// MARK: - ItemKind
extension HomeCollectionViewController {
	/// List of available Item Kind types.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `ShowIdentity` object.
		case showIdentity(_: ShowIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `LiteratureIdentity` object.
		case literatureIdentity(_: LiteratureIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `GameIdentity` object.
		case gameIdentity(_: GameIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `EpisodeIdentity` object.
		case episodeIdentity(_: EpisodeIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `ShowSong` object.
		case showSong(_: ShowSong, id: UUID = UUID())

		/// Indicates the item kind contains a `GenreIdentity` object.
		case genreIdentity(_: GenreIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `ThemeIdentity` object.
		case themeIdentity(_: ThemeIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `CharacterIdentity` object.
		case characterIdentity(_: CharacterIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `PersonIdentity` object.
		case personIdentity(_: PersonIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `Recap` object.
		case recap(_: Recap, id: UUID = UUID())

		/// Indicates the item kind contains a `QuickLink` object.
		case quickLink(_: QuickLink, id: UUID = UUID())

		/// Indicates the item kind contains a `QuickAction` object.
		case quickAction(_: QuickAction, id: UUID = UUID())

		/// Indicates a legal section layout type.
		case legal(id: UUID = UUID())

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .showIdentity(let showIdentity, let id):
				hasher.combine(showIdentity)
				hasher.combine(id)
			case .literatureIdentity(let literatureIdentity, let id):
				hasher.combine(literatureIdentity)
				hasher.combine(id)
			case .gameIdentity(let gameIdentity, let id):
				hasher.combine(gameIdentity)
				hasher.combine(id)
			case .episodeIdentity(let episodeIdentity, let id):
				hasher.combine(episodeIdentity)
				hasher.combine(id)
			case .showSong(let showSong, let id):
				hasher.combine(showSong)
				hasher.combine(id)
			case .genreIdentity(let genreIdentity, let id):
				hasher.combine(genreIdentity)
				hasher.combine(id)
			case .themeIdentity(let themeIdentity, let id):
				hasher.combine(themeIdentity)
				hasher.combine(id)
			case .characterIdentity(let characterIdentity, let id):
				hasher.combine(characterIdentity)
				hasher.combine(id)
			case .personIdentity(let personIdentity, let id):
				hasher.combine(personIdentity)
				hasher.combine(id)
			case .recap(let recap, let id):
				hasher.combine(recap)
				hasher.combine(id)
			case .quickLink(let quickLink, let id):
				hasher.combine(quickLink)
				hasher.combine(id)
			case .quickAction(let quickAction, let id):
				hasher.combine(quickAction)
				hasher.combine(id)
			case .legal(let id):
				hasher.combine(id)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.showIdentity(let showIdentity1, let id1), .showIdentity(let showIdentity2, let id2)):
				return showIdentity1 == showIdentity2 && id1 == id2
			case (.literatureIdentity(let literatureIdentity1, let id1), .literatureIdentity(let literatureIdentity2, let id2)):
				return literatureIdentity1 == literatureIdentity2 && id1 == id2
			case (.gameIdentity(let gameIdentity1, let id1), .gameIdentity(let gameIdentity2, let id2)):
				return gameIdentity1 == gameIdentity2 && id1 == id2
			case (.episodeIdentity(let episodeIdentity1, let id1), .episodeIdentity(let episodeIdentity2, let id2)):
				return episodeIdentity1 == episodeIdentity2 && id1 == id2
			case (.showSong(let showSong1, let id1), .showSong(let showSong2, let id2)):
				return showSong1 == showSong2 && id1 == id2
			case (.genreIdentity(let genreIdentity1, let id1), .genreIdentity(let genreIdentity2, let id2)):
				return genreIdentity1 == genreIdentity2 && id1 == id2
			case (.themeIdentity(let themeIdentity1, let id1), .themeIdentity(let themeIdentity2, let id2)):
				return themeIdentity1 == themeIdentity2 && id1 == id2
			case (.characterIdentity(let characterIdentity1, let id1), .characterIdentity(let characterIdentity2, let id2)):
				return characterIdentity1 == characterIdentity2 && id1 == id2
			case (.personIdentity(let personIdentity1, let id1), .personIdentity(let personIdentity2, let id2)):
				return personIdentity1 == personIdentity2 && id1 == id2
			case (.recap(let recap1, let id1), .recap(let recap2, let id2)):
				return recap1 == recap2 && id1 == id2
			case (.quickLink(let quickLink1, let id1), .quickLink(let quickLink2, let id2)):
				return quickLink1 == quickLink2 && id1 == id2
			case (.quickAction(let quickAction1, let id1), .quickAction(let quickAction2, let id2)):
				return quickAction1 == quickAction2 && id1 == id2
			case (.legal(let id1), .legal(let id2)):
				return id1 == id2
			default:
				return false
			}
		}
	}
}

// MARK: - Cell Configuration
extension HomeCollectionViewController {
	func getConfiguredActionLinkCell() -> UICollectionView.CellRegistration<ActionLinkExploreCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<ActionLinkExploreCollectionViewCell, ItemKind>(cellNib: ActionLinkExploreCollectionViewCell.nib) { [weak self] actionLinkExploreCollectionViewCell, _, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .quickLink(let quickLink, _):
				actionLinkExploreCollectionViewCell.delegate = self
				#if !targetEnvironment(macCatalyst)
				actionLinkExploreCollectionViewCell.separatorIsHidden = self.quickLinks.last == quickLink
				#endif
				actionLinkExploreCollectionViewCell.configure(using: quickLink)
			default: break
			}
		}
	}

	func getConfiguredBannerCell() -> UICollectionView.CellRegistration<BannerLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<BannerLockupCollectionViewCell, ItemKind>(cellNib: BannerLockupCollectionViewCell.nib) { [weak self] bannerLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .showIdentity:
				let show: Show? = self.fetchModel(at: indexPath)

				if show == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ShowResponse.self, ShowIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				bannerLockupCollectionViewCell.delegate = self
				bannerLockupCollectionViewCell.configure(using: show)
			default: break
			}
		}
	}

	func getConfiguredSmallCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: SmallLockupCollectionViewCell.nib) { [weak self] smallLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .showIdentity:
				let show: Show? = self.fetchModel(at: indexPath)

				if show == nil {
					Task {
						await self.fetchSectionIfNeeded(ShowResponse.self, ShowIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.configure(using: show)
			case .literatureIdentity:
				let literature: Literature? = self.fetchModel(at: indexPath)

				if literature == nil {
					Task {
						await self.fetchSectionIfNeeded(LiteratureResponse.self, LiteratureIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.configure(using: literature)
			default: break
			}
		}
	}

	func getConfiguredEpisodeCell() -> UICollectionView.CellRegistration<EpisodeLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<EpisodeLockupCollectionViewCell, ItemKind>(cellNib: EpisodeLockupCollectionViewCell.nib) { [weak self] episodeLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .episodeIdentity:
				let episode: Episode? = self.fetchModel(at: indexPath)

				if episode == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(EpisodeResponse.self, EpisodeIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				episodeLockupCollectionViewCell.delegate = self
				episodeLockupCollectionViewCell.configure(using: episode)
			default: break
			}
		}
	}

	func getConfiguredGameCell() -> UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind>(cellNib: GameLockupCollectionViewCell.nib) { [weak self] gameLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .gameIdentity:
				let game: Game? = self.fetchModel(at: indexPath)

				if game == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(GameResponse.self, GameIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				gameLockupCollectionViewCell.delegate = self
				gameLockupCollectionViewCell.configure(using: game)
			default: break
			}
		}
	}

	func getConfiguredMediumCell() -> UICollectionView.CellRegistration<MediumLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<MediumLockupCollectionViewCell, ItemKind>(cellNib: MediumLockupCollectionViewCell.nib) { [weak self] mediumLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .genreIdentity:
				let genre: Genre? = self.fetchModel(at: indexPath)

				if genre == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(GenreResponse.self, GenreIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				mediumLockupCollectionViewCell.configure(using: genre)
			case .themeIdentity:
				let theme: Theme? = self.fetchModel(at: indexPath)

				if theme == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ThemeResponse.self, ThemeIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				mediumLockupCollectionViewCell.configure(using: theme)
			default: break
			}
		}
	}

	func getConfiguredLargeCell() -> UICollectionView.CellRegistration<LargeLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<LargeLockupCollectionViewCell, ItemKind>(cellNib: LargeLockupCollectionViewCell.nib) { [weak self] largeLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .showIdentity:
				let show: Show? = self.fetchModel(at: indexPath)

				if show == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ShowResponse.self, ShowIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				largeLockupCollectionViewCell.delegate = self
				largeLockupCollectionViewCell.configure(using: show)
			default: break
			}
		}
	}

	func getConfiguredUpcomingCell() -> UICollectionView.CellRegistration<UpcomingLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<UpcomingLockupCollectionViewCell, ItemKind>(cellNib: UpcomingLockupCollectionViewCell.nib) { [weak self] upcomingLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .showIdentity:
				let show: Show? = self.fetchModel(at: indexPath)

				if show == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ShowResponse.self, ShowIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				upcomingLockupCollectionViewCell.delegate = self
				upcomingLockupCollectionViewCell.configure(using: show)
			default: break
			}
		}
	}

	func getConfiguredVideoCell() -> UICollectionView.CellRegistration<VideoLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<VideoLockupCollectionViewCell, ItemKind>(cellNib: VideoLockupCollectionViewCell.nib) { [weak self] videoLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .showIdentity:
				let show: Show? = self.fetchModel(at: indexPath)

				if show == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ShowResponse.self, ShowIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				videoLockupCollectionViewCell.delegate = self
				videoLockupCollectionViewCell.configure(using: show)
			default: break
			}
		}
	}

	func getConfiguredMusicCell() -> UICollectionView.CellRegistration<MusicLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<MusicLockupCollectionViewCell, ItemKind>(cellNib: MusicLockupCollectionViewCell.nib) { [weak self] musicLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .showSong(let showSong, _):
				self.cache[indexPath] = showSong
				musicLockupCollectionViewCell.delegate = self
				musicLockupCollectionViewCell.configure(using: showSong, at: indexPath, showEpisodes: false, showShow: true)
			default: break
			}
		}
	}

	func getConfiguredPersonCell() -> UICollectionView.CellRegistration<PersonLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<PersonLockupCollectionViewCell, ItemKind>(cellNib: PersonLockupCollectionViewCell.nib) { [weak self] personLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .personIdentity:
				let person: Person? = self.fetchModel(at: indexPath)

				if person == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(PersonResponse.self, PersonIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				personLockupCollectionViewCell.configure(using: person)
			default: return
			}
		}
	}

	func getConfiguredCharacterCell() -> UICollectionView.CellRegistration<CharacterLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<CharacterLockupCollectionViewCell, ItemKind>(cellNib: CharacterLockupCollectionViewCell.nib) { [weak self] characterLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .characterIdentity:
				let character: Character? = self.fetchModel(at: indexPath)

				if character == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(CharacterResponse.self, CharacterIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				characterLockupCollectionViewCell.configure(using: character)
			default: return
			}
		}
	}

	func getConfiguredRecapCell() -> UICollectionView.CellRegistration<RecapLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<RecapLockupCollectionViewCell, ItemKind>(cellNib: RecapLockupCollectionViewCell.nib) { [weak self] recapLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .recap(let recap, _):
				self.cache[indexPath] = recap
				recapLockupCollectionViewCell.configure(using: recap)
			default: return
			}
		}
	}
}
