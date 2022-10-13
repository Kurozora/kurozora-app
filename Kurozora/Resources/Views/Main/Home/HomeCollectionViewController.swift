//
//  HomeCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Alamofire
import AVFoundation
import MediaPlayer
import WhatsNew

class HomeCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	lazy var genre: Genre? = nil
	lazy var theme: Theme? = nil
	let quickLinks: [QuickLink] = [
		QuickLink(title: "About In-App Purchases", url: "https://kurozora.app/kb/iap"),
		QuickLink(title: "About Personalisation", url: "https://kurozora.app/kb/personalisation"),
		QuickLink(title: "Welcome to Kurozora", url: "https://kurozora.app/welcome")
	]
	let quickActions: [QuickAction] = [
		QuickAction(title: "Redeem", segueID: R.segue.homeCollectionViewController.redeemSegue.identifier),
		QuickAction(title: "Become a Subscriber", segueID: R.segue.homeCollectionViewController.subscriptionSegue.identifier)
	]

	var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>! = nil
	var prefetchingIndexPathOperations: [IndexPath: DataRequest] = [:]
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

	/// The object that provides the interface to control the player’s transport behavior.
	var player: AVPlayer?

	/// The index path of the song that's currently playing.
	var currentPlayerIndexPath: IndexPath?

	/// Which is used? This or exploreCategories?
	var shows: [IndexPath: Show] = [:]
	var characters: [IndexPath: Character] = [:]
	var people: [IndexPath: Person] = [:]
	var genres: [IndexPath: Genre] = [:]
	var themes: [IndexPath: Theme] = [:]

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
	static func `init`(with genre: Genre) -> HomeCollectionViewController {
		if let homeCollectionViewController = R.storyboard.home.homeCollectionViewController() {
			homeCollectionViewController.genre = genre
			return homeCollectionViewController
		}

		fatalError("Failed to instantiate HomeCollectionViewController with the given Genre object.")
	}

	/// Initialize a new instance of HomeCollectionViewController with the given theme object.
	///
	/// - Parameter theme: The theme object to use when initializing the view.
	///
	/// - Returns: an initialized instance of HomeCollectionViewController.
	static func `init`(with theme: Theme) -> HomeCollectionViewController {
		if let homeCollectionViewController = R.storyboard.home.homeCollectionViewController() {
			homeCollectionViewController.theme = theme
			return homeCollectionViewController
		}

		fatalError("Failed to instantiate HomeCollectionViewController with the given Theme object.")
	}

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		self.handleRefreshControl()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Add Refresh Control to Collection View
		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		self.configureDataSource()

		// Fetch explore details.
		DispatchQueue.global(qos: .userInteractive).async {
			self.fetchExplore()
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.title = self.genre?.attributes.name ?? self.theme?.attributes.name ?? "Explore"
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		// Show what's new in the app if necessary.
		self.showWhatsNew()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		self.player?.pause()
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		DispatchQueue.global(qos: .userInteractive).async {
			self.fetchExplore()
		}
	}

	/// Shows what's new in the app if necessary.
	fileprivate func showWhatsNew() {
		if WhatsNew.shouldPresent() {
			let whatsNew = KWhatsNewViewController(titleText: "What's New", buttonText: "Continue", items: KWhatsNew.current)
			self.present(whatsNew, animated: true)
		}
	}

	/// Fetches the explore page from the server.
	fileprivate func fetchExplore() {
		KService.getExplore(genreID: self.genre?.id, themeID: self.theme?.id) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let exploreCategories):
				// Remove any empty sections
				self.exploreCategories = exploreCategories.filter { exploreCategory in
					switch exploreCategory.attributes.exploreCategoryType {
					case .shows, .upcomingShows, .mostPopularShows:
						return !(exploreCategory.relationships.shows?.data.isEmpty ?? false)
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
					}
				}
			case .failure: break
			}
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.homeCollectionViewController.showDetailsSegue.identifier:
			// Segue to show details
			guard let showDetailCollectionViewController = segue.destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailCollectionViewController.show = show
		case R.segue.homeCollectionViewController.songsListSegue.identifier:
			// Segue to show songs list
			guard let showSongsListCollectionViewController = segue.destination as? ShowSongsListCollectionViewController else { return }
			guard let indexPath = sender as? IndexPath else { return }
			let exploreCategory = self.exploreCategories[indexPath.section]
			showSongsListCollectionViewController.title = exploreCategory.attributes.title
			showSongsListCollectionViewController.showSongs = exploreCategory.relationships.showSongs?.data ?? []
		case R.segue.homeCollectionViewController.exploreSegue.identifier:
			// Segue to genre or theme explore
			guard let homeCollectionViewController = segue.destination as? HomeCollectionViewController else { return }
			if let genre = sender as? Genre {
				homeCollectionViewController.genre = genre
			} else if let theme = sender as? Theme {
				homeCollectionViewController.theme = theme
			}
		case R.segue.homeCollectionViewController.characterSegue.identifier:
			// Segue to character details
			guard let characterDetailsCollectionViewController = segue.destination as? CharacterDetailsCollectionViewController else { return }
			guard let character = sender as? Character else { return }
			characterDetailsCollectionViewController.character = character
		case R.segue.homeCollectionViewController.personSegue.identifier:
			// Segue to person details
			guard let personDetailsCollectionViewController = segue.destination as? PersonDetailsCollectionViewController else { return }
			guard let person = sender as? Person else { return }
			personDetailsCollectionViewController.person = person
		case R.segue.homeCollectionViewController.showsListSegue.identifier:
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
		case R.segue.homeCollectionViewController.charactersListSegue.identifier:
			// Segue to characters list
			guard let charactersListCollectionViewController = segue.destination as? CharactersListCollectionViewController else { return }
			guard let indexPath = sender as? IndexPath else { return }
			let exploreCategory = self.exploreCategories[indexPath.section]
			charactersListCollectionViewController.title = exploreCategory.attributes.title
			charactersListCollectionViewController.exploreCategoryIdentity = ExploreCategoryIdentity(id: exploreCategory.id)
			charactersListCollectionViewController.charactersListFetchType = .explore
		case R.segue.homeCollectionViewController.peopleListSegue.identifier:
			// Segue to people list
			guard let peopleListCollectionViewController = segue.destination as? PeopleListCollectionViewController else { return }
			guard let indexPath = sender as? IndexPath else { return }
			let exploreCategory = self.exploreCategories[indexPath.section]
			peopleListCollectionViewController.title = exploreCategory.attributes.title
			peopleListCollectionViewController.exploreCategoryIdentity = ExploreCategoryIdentity(id: exploreCategory.id)
			peopleListCollectionViewController.peopleListFetchType = .explore
		default: break
		}
	}
}

// MARK: - TitleHeaderCollectionReusableViewDelegate
extension HomeCollectionViewController: TitleHeaderCollectionReusableViewDelegate {
	func titleHeaderCollectionReusableView(_ reusableView: TitleHeaderCollectionReusableView, didPress button: UIButton) {
		self.performSegue(withIdentifier: reusableView.segueID, sender: reusableView.indexPath)
	}
}

// MARK: - BaseLockupCollectionViewCellDelegate
extension HomeCollectionViewController: BaseLockupCollectionViewCellDelegate {
	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressReminder button: UIButton) {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		guard let show = self.shows[indexPath] else { return }
		show.toggleReminder()
	}

	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressStatus button: UIButton) {
		WorkflowController.shared.isSignedIn {
			guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
			guard let show = self.shows[indexPath] else { return }

			let oldLibraryStatus = cell.libraryStatus
			let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: KKLibrary.Status.alertControllerItems, currentSelection: oldLibraryStatus, action: { title, value  in
				KService.addToLibrary(withLibraryStatus: value, showID: show.id) { result in
					switch result {
					case .success(let libraryUpdate):
						show.attributes.update(using: libraryUpdate)

						// Update entry in library
						cell.libraryStatus = value
						button.setTitle("\(title) ▾", for: .normal)

						let libraryAddToNotificationName = Notification.Name("AddTo\(value.sectionValue)Section")
						NotificationCenter.default.post(name: libraryAddToNotificationName, object: nil)
					case .failure:
						break
					}
				}
			})

			if cell.libraryStatus != .none {
				actionSheetAlertController.addAction(UIAlertAction(title: "Remove from library", style: .destructive, handler: { _ in
					KService.removeFromLibrary(showID: show.id) { result in
						switch result {
						case .success(let libraryUpdate):
							show.attributes.update(using: libraryUpdate)

							// Update edntry in library
							cell.libraryStatus = .none
							button.setTitle("ADD", for: .normal)

							let libraryRemoveFromNotificationName = Notification.Name("RemoveFrom\(oldLibraryStatus.sectionValue)Section")
							NotificationCenter.default.post(name: libraryRemoveFromNotificationName, object: nil)
						case .failure:
							break
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

// MARK: - MusicLockupCollectionViewCellDelegate
extension HomeCollectionViewController: MusicLockupCollectionViewCellDelegate {
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
		let show = self.exploreCategories[indexPath.section].relationships.showSongs?.data[indexPath.item].show
		self.performSegue(withIdentifier: R.segue.homeCollectionViewController.showDetailsSegue.identifier, sender: show)
	}
}

// MARK: - ActionBaseExploreCollectionViewCellDelegate
extension HomeCollectionViewController: ActionBaseExploreCollectionViewCellDelegate {
	func actionButtonPressed(_ sender: UIButton, cell: ActionBaseExploreCollectionViewCell) {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }

		switch cell.self {
		case is ActionLinkExploreCollectionViewCell:
			guard let kNavigationController = R.storyboard.webBrowser.kWebViewKNavigationController() else { return }
			let quickLink = self.quickLinks[indexPath.item]
			if let kWebViewController = kNavigationController.viewControllers.first as? KWebViewController {
				kWebViewController.title = quickLink.title
				kWebViewController.url = quickLink.url

				kNavigationController.modalPresentationStyle = .custom
				self.present(kNavigationController, animated: true)
			}
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

		/// Indicates a genre section layout type.
		case small(_: ExploreCategory)

		/// Indicates a genre section layout type.
		case medium(_: ExploreCategory)

		/// Indicates a genre section layout type.
		case large(_: ExploreCategory)

		/// Indicates a genre section layout type.
		case video(_: ExploreCategory)

		/// Indicates a genre section layout type.
		case upcoming(_: ExploreCategory)

		/// Indicates a genre section layout type.
		case profile(_: ExploreCategory)

		/// Indicates a genre section layout type.
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

extension HomeCollectionViewController {
	func getConfiguredBannerCell() -> UICollectionView.CellRegistration<BannerLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<BannerLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.bannerLockupCollectionViewCell)) { [weak self] bannerLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .showIdentity(let showIdentity, _):
				let show = self.fetchShow(at: indexPath)
				var dataRequest = self.prefetchingIndexPathOperations[indexPath] ?? bannerLockupCollectionViewCell.dataRequest

				if dataRequest == nil && show == nil {
					dataRequest = KService.getDetails(forShow: showIdentity) { result in
						switch result {
						case .success(let shows):
							self.shows[indexPath] = shows.first
							self.setItemKindNeedsUpdate(itemKind)
						case .failure: break
						}
					}
				}

				bannerLockupCollectionViewCell.delegate = self
				bannerLockupCollectionViewCell.dataRequest = dataRequest
				bannerLockupCollectionViewCell.configure(using: show)
			default: break
			}
		}
	}

	func getConfiguredSmallCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.smallLockupCollectionViewCell)) { [weak self] smallLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .showIdentity(let showIdentity, _):
				let show = self.fetchShow(at: indexPath)
				var dataRequest = self.prefetchingIndexPathOperations[indexPath] ?? smallLockupCollectionViewCell.dataRequest

				if dataRequest == nil && show == nil {
					dataRequest = KService.getDetails(forShow: showIdentity) { result in
						switch result {
						case .success(let shows):
							self.shows[indexPath] = shows.first
							self.setItemKindNeedsUpdate(itemKind)
						case .failure: break
						}
					}
				}

				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.dataRequest = dataRequest
				smallLockupCollectionViewCell.configure(using: show)
			default: break
			}
		}
	}

	func getConfiguredMediumCell() -> UICollectionView.CellRegistration<MediumLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<MediumLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.mediumLockupCollectionViewCell)) { [weak self] mediumLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .genreIdentity(let genreIdentity, _):
				let genre = self.fetchGenre(at: indexPath)
				var genreDataRequest = self.prefetchingIndexPathOperations[indexPath] ?? mediumLockupCollectionViewCell.dataRequest

				if genreDataRequest == nil && genre == nil {
					genreDataRequest = KService.getDetails(forGenre: genreIdentity) { result in
						switch result {
						case .success(let genres):
							self.genres[indexPath] = genres.first
							self.setItemKindNeedsUpdate(itemKind)
						case .failure: break
						}
					}
				}

				mediumLockupCollectionViewCell.dataRequest = genreDataRequest
				mediumLockupCollectionViewCell.configure(using: genre)
			case .themeIdentity(let themeIdentity, _):
				let theme = self.fetchTheme(at: indexPath)
				var themeDataRequest = self.prefetchingIndexPathOperations[indexPath] ?? mediumLockupCollectionViewCell.dataRequest

				if themeDataRequest == nil && theme == nil {
					themeDataRequest = KService.getDetails(forTheme: themeIdentity) { result in
						switch result {
						case .success(let themes):
							self.themes[indexPath] = themes.first
							self.setItemKindNeedsUpdate(itemKind)
						case .failure: break
						}
					}
				}

				mediumLockupCollectionViewCell.dataRequest = themeDataRequest
				mediumLockupCollectionViewCell.configure(using: theme)
			default: break
			}
		}
	}

	func getConfiguredLargeCell() -> UICollectionView.CellRegistration<LargeLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<LargeLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.largeLockupCollectionViewCell)) { [weak self] largeLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .showIdentity(let showIdentity, _):
				let show = self.fetchShow(at: indexPath)
				var dataRequest = self.prefetchingIndexPathOperations[indexPath] ?? largeLockupCollectionViewCell.dataRequest

				if dataRequest == nil && show == nil {
					dataRequest = KService.getDetails(forShow: showIdentity) { result in
						switch result {
						case .success(let shows):
							self.shows[indexPath] = shows.first
							self.setItemKindNeedsUpdate(itemKind)
						case .failure: break
						}
					}
				}

				largeLockupCollectionViewCell.delegate = self
				largeLockupCollectionViewCell.dataRequest = dataRequest
				largeLockupCollectionViewCell.configure(using: show)
			default: break
			}
		}
	}

	func getConfiguredUpcomingCell() -> UICollectionView.CellRegistration<UpcomingLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<UpcomingLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.upcomingLockupCollectionViewCell)) { [weak self] upcomingLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .showIdentity(let showIdentity, _):
				let show = self.fetchShow(at: indexPath)
				var dataRequest = self.prefetchingIndexPathOperations[indexPath] ?? upcomingLockupCollectionViewCell.dataRequest

				if dataRequest == nil && show == nil {
					dataRequest = KService.getDetails(forShow: showIdentity) { result in
						switch result {
						case .success(let shows):
							self.shows[indexPath] = shows.first
							self.setItemKindNeedsUpdate(itemKind)
						case .failure: break
						}
					}
				}

				upcomingLockupCollectionViewCell.delegate = self
				upcomingLockupCollectionViewCell.dataRequest = dataRequest
				upcomingLockupCollectionViewCell.configure(using: show)
			default: break
			}
		}
	}

	func getConfiguredVideoCell() -> UICollectionView.CellRegistration<VideoLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<VideoLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.videoLockupCollectionViewCell)) { [weak self] videoLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .showIdentity(let showIdentity, _):
				let show = self.fetchShow(at: indexPath)
				var dataRequest = self.prefetchingIndexPathOperations[indexPath] ?? videoLockupCollectionViewCell.dataRequest

				if dataRequest == nil && show == nil {
					dataRequest = KService.getDetails(forShow: showIdentity) { result in
						switch result {
						case .success(let shows):
							self.shows[indexPath] = shows.first
							self.setItemKindNeedsUpdate(itemKind)
						case .failure: break
						}
					}
				}

				videoLockupCollectionViewCell.delegate = self
				videoLockupCollectionViewCell.dataRequest = dataRequest
				videoLockupCollectionViewCell.configure(using: show)
			default: break
			}
		}
	}

	func getConfiguredPersonCell() -> UICollectionView.CellRegistration<PersonLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<PersonLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.personLockupCollectionViewCell)) { [weak self] personLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .personIdentity(let personIdentity, _):
				let person = self.fetchPerson(at: indexPath)
				var dataRequest = self.prefetchingIndexPathOperations[indexPath] ?? personLockupCollectionViewCell.dataRequest

				if dataRequest == nil && person == nil {
					dataRequest = KService.getDetails(forPerson: personIdentity) { result in
						switch result {
						case .success(let persons):
							self.people[indexPath] = persons.first
							self.setItemKindNeedsUpdate(itemKind)
						case .failure: break
						}
					}
				}

				personLockupCollectionViewCell.dataRequest = dataRequest
				personLockupCollectionViewCell.configure(using: person)
			default: return
			}
		}
	}

	func getConfiguredCharacterCell() -> UICollectionView.CellRegistration<CharacterLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<CharacterLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.characterLockupCollectionViewCell)) { [weak self] characterLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .characterIdentity(let characterIdentity, _):
				let character = self.fetchCharacter(at: indexPath)
				var dataRequest = self.prefetchingIndexPathOperations[indexPath] ?? characterLockupCollectionViewCell.dataRequest

				if dataRequest == nil && character == nil {
					dataRequest = KService.getDetails(forCharacter: characterIdentity) { result in
						switch result {
						case .success(let characters):
							self.characters[indexPath] = characters.first
							self.setItemKindNeedsUpdate(itemKind)
						case .failure: break
						}
					}
				}

				characterLockupCollectionViewCell.dataRequest = dataRequest
				characterLockupCollectionViewCell.configure(using: character)
			default: return
			}
		}
	}
}
