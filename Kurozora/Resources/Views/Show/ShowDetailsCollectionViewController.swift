//
//  ShowDetailsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import AVFoundation
import Intents
import IntentsUI
import KurozoraKit
import UIKit

class ShowDetailsCollectionViewController: KCollectionViewController, RatingAlertPresentable, SectionFetchable {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case reviewsSegue
		case seasonsListSegue
		case castListSegue
		case songsListSegue
		case showsListSegue
		case literaturesListSegue
		case gamesListSegue
		case studiosListSegue
		case showDetailsSegue
		case literatureDetailsSegue
		case gameDetailsSegue
		case studioDetailsSegue
		case characterDetailsSegue
		case personDetailsSegue
		case episodesListSegue
		case songDetailsSegue
	}

	// MARK: - Views
	private var moreBarButtonItem: UIBarButtonItem!
	private var navigationTitleView: UIView!
	private var navigationTitleLabel: KLabel! = {
		let label = KLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.alpha = 0
		return label
	}()

	// MARK: - Properties
	var showIdentity: ShowIdentity?
	var show: Show! {
		didSet {
			self.title = self.show.attributes.title
			self.navigationTitleLabel.text = self.show.attributes.title
			self.showIdentity = ShowIdentity(id: self.show.id)

			self._prefersActivityIndicatorHidden = true
			#if targetEnvironment(macCatalyst)
			self.touchBar = nil
			#endif

			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
			#endif
		}
	}

	/// Review properties.
	var reviews: [Review] = []

	/// Season properties.
	var seasonIdentities: [SeasonIdentity] = []

	/// Related Show properties.
	var relatedShows: [RelatedShow] = []

	/// Related Literature properties.
	var relatedLiteratures: [RelatedLiterature] = []

	/// Related Game properties.
	var relatedGames: [RelatedGame] = []

	/// Cast properties.
	var castIdentities: [CastIdentity] = []

	/// Studio properties.
	var studioIdentities: [StudioIdentity] = []
//	var studio: Studio!
	var studioShowIdentities: [ShowIdentity] = []

	/// Show Song properties.
	var showSongs: [ShowSong] = []

	/// The object that provides the interface to control the player’s transport behavior.
	var player: AVPlayer?

	/// The index path of the song that's currently playing.
	var currentPlayerIndexPath: IndexPath?

	/// The first cell's size.
	private var firstCellSize: CGSize = .zero

	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	// Touch Bar
	#if targetEnvironment(macCatalyst)
	var toggleShowIsFavoriteTouchBarItem: NSButtonTouchBarItem?
	var toggleShowIsRemindedTouchBarItem: NSButtonTouchBarItem?
	#endif

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
	/// Initialize a new instance of ShowDetailsCollectionViewController with the given show id.
	///
	/// - Parameter showID: The show id to use when initializing the view.
	///
	/// - Returns: an initialized instance of ShowDetailsCollectionViewController.
	func callAsFunction(with showID: KurozoraItemID) -> ShowDetailsCollectionViewController {
		let showDetailsCollectionViewController = ShowDetailsCollectionViewController()
		showDetailsCollectionViewController.showIdentity = ShowIdentity(id: showID)
		return showDetailsCollectionViewController
	}

	/// Initialize a new instance of ShowDetailsCollectionViewController with the given show object.
	///
	/// - Parameter show: The `Show` object to use when initializing the view controller.
	///
	/// - Returns: an initialized instance of ShowDetailsCollectionViewController.
	func callAsFunction(with show: Show) -> ShowDetailsCollectionViewController {
		let showDetailsCollectionViewController = ShowDetailsCollectionViewController()
		showDetailsCollectionViewController.show = show
		return showDetailsCollectionViewController
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleFavoriteToggle(_:)), name: .KModelFavoriteIsToggled, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleReminderToggle(_:)), name: .KModelReminderIsToggled, object: nil)

		// Add refresh control
		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		self.configureDataSource()
		self.configureNavigationItems()

		// Fetch show details.
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchDetails()
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(self, selector: #selector(self.deleteReview(_:)), name: .KReviewDidDelete, object: nil)

		// Make the navigation bar background clear
		self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
		self.navigationController?.navigationBar.shadowImage = UIImage()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		NotificationCenter.default.removeObserver(self, name: .KReviewDidDelete, object: nil)

		// Restore the navigation bar to default
		self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
		self.navigationController?.navigationBar.shadowImage = nil
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		// Add bottom content inset to account for tab bar
		let tabBarHeight = self.tabBarController?.tabBar.frame.height ?? 0
		self.collectionView.contentInset.bottom = tabBarHeight

		// Store the first cell size
		if let firstCell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? ShowDetailHeaderCollectionViewCell, self.firstCellSize.width != firstCell.frame.size.width {
			self.firstCellSize = firstCell.frame.size
		}
	}

	// MARK: - Gesture
	override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		if motion == .motionShake, self.show?.attributes.title.lowercased().contains("log horizon") == true {
			if let url = URL.livingInTheDatabase {
				UIApplication.shared.kOpen(url)
			}
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchDetails()
		}
	}

	override func configureEmptyDataView() {
		self.emptyBackgroundView.configureImageView(image: .Empty.animeLibrary)
		self.emptyBackgroundView.configureLabels(title: "No Details", detail: "This show doesn't have details yet. Please check back again later.")

		self.collectionView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of rows.
	func toggleEmptyDataView() {
		if self.collectionView.numberOfSections == 0 {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	/// Configures the navigation title view.
	private func configureNavigationTitleView() {
		self.navigationTitleView = UIView()

		if #unavailable(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0) {
			self.navigationTitleLabel.theme_textColor = KThemePicker.barTitleTextColor.rawValue
		}

		// Layout
		self.navigationItem.titleView = self.navigationTitleView
		self.navigationTitleView.addSubview(self.navigationTitleLabel)

		NSLayoutConstraint.activate([
			self.navigationTitleLabel.topAnchor.constraint(equalTo: self.navigationTitleView.topAnchor),
			self.navigationTitleLabel.bottomAnchor.constraint(equalTo: self.navigationTitleView.bottomAnchor),
			self.navigationTitleLabel.leadingAnchor.constraint(equalTo: self.navigationTitleView.leadingAnchor),
			self.navigationTitleLabel.trailingAnchor.constraint(equalTo: self.navigationTitleView.trailingAnchor),
			self.navigationTitleLabel.centerXAnchor.constraint(equalTo: self.navigationTitleView.centerXAnchor),
			self.navigationTitleLabel.centerYAnchor.constraint(equalTo: self.navigationTitleView.centerYAnchor)
		])
	}

	/// Configures the more bar button item.
	private func configureMoreBarButtonItem() {
		self.moreBarButtonItem = UIBarButtonItem(title: Trans.more, image: UIImage(systemName: "ellipsis.circle"))
		self.navigationItem.rightBarButtonItem = self.moreBarButtonItem
	}

	/// Configures the navigation items.
	fileprivate func configureNavigationItems() {
		self.configureNavigationTitleView()
		self.configureMoreBarButtonItem()
	}

	func configureNavBarButtons() {
		self.moreBarButtonItem.menu = self.show?.makeContextMenu(in: self, userInfo: [:], sourceView: nil, barButtonItem: self.moreBarButtonItem)
	}

	/// Fetches details for the given show identity. If none given then the currently viewed show's details are fetched.
	func fetchDetails() async {
		guard let showIdentity = self.showIdentity else { return }

		if self.show == nil {
			do {
				let showResponse = try await KService.getDetails(forShow: showIdentity).value
				self.show = showResponse.data.first

				// Donate suggestion to Siri
				self.userActivity = self.show.openDetailUserActivity
			} catch {
				print(error.localizedDescription)
			}

			self.configureNavBarButtons()
		} else {
			// Donate suggestion to Siri
			self.userActivity = self.show.openDetailUserActivity

			self.updateDataSource()
			self.configureNavBarButtons()
		}

		do {
			let reviewIdentityResponse = try await KService.getReviews(forShow: showIdentity, next: nil, limit: 10).value
			self.reviews = reviewIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let seasonIdentityResponse = try await KService.getSeasons(forShow: showIdentity, reversed: true, next: nil, limit: 10).value
			self.seasonIdentities = seasonIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let castIdentityResponse = try await KService.getCast(forShow: showIdentity, limit: 10).value
			self.castIdentities = castIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let showSongResponse = try await KService.getSongs(forShow: showIdentity, limit: 10).value
			self.showSongs = showSongResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let studioIdentityResponse = try await KService.getStudios(forShow: showIdentity, limit: 10).value
			self.studioIdentities = studioIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let showIdentityResponse = try await KService.getMoreByStudio(forShow: showIdentity, limit: 10).value
			self.studioShowIdentities = showIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let relatedShowResponse = try await KService.getRelatedShows(forShow: showIdentity, limit: 10).value
			self.relatedShows = relatedShowResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let relatedLiteraturesResponse = try await KService.getRelatedLiteratures(forShow: showIdentity, limit: 10).value
			self.relatedLiteratures = relatedLiteraturesResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let relatedGamesResponse = try await KService.getRelatedGames(forShow: showIdentity, limit: 10).value
			self.relatedGames = relatedGamesResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}
	}

	/// Deletes the review with the received information.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers.
	@objc func deleteReview(_ notification: NSNotification) {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }

			if let indexPath = notification.userInfo?["indexPath"] as? IndexPath {
				// Start delete process
				self.reviews.remove(at: indexPath.item)
			}

			self.show.attributes.library?.rating = nil
			self.show.attributes.library?.review = nil

			self.updateDataSource()
		}
	}

	@objc func toggleFavorite() {
		Task {
			await self.show?.toggleFavorite()
		}
	}

	@objc func toggleReminder() {
		Task {
			await self.show?.toggleReminder(on: self)
		}
	}

	@objc func handleFavoriteToggle(_ notification: NSNotification) {
		#if targetEnvironment(macCatalyst)
		let name = self.show.attributes.library?.favoriteStatus == .favorited ? "heart.fill" : "heart"
		self.toggleShowIsFavoriteTouchBarItem?.image = UIImage(systemName: name)
		#endif
	}

	@objc func handleReminderToggle(_ notification: NSNotification) {
		#if targetEnvironment(macCatalyst)
		let name = self.show.attributes.library?.reminderStatus == .reminded ? "bell.fill" : "bell"
		self.toggleShowIsRemindedTouchBarItem?.image = UIImage(systemName: name)
		#endif
	}

	// MARK: - SectionFetchable
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .castIdentity(let id, _): return id as? Element
		case .characterIdentity(let id, _): return id as? Element
		case .personIdentity(let id, _): return id as? Element
		case .seasonIdentity(let id, _): return id as? Element
		case .showIdentity(let id, _): return id as? Element
		case .studioIdentity(let id, _): return id as? Element
		default: return nil
		}
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .reviewsSegue: return ReviewsCollectionViewController()
		case .seasonsListSegue: return SeasonsListCollectionViewController()
		case .castListSegue: return CastListCollectionViewController()
		case .songsListSegue: return ShowSongsListCollectionViewController()
		case .showsListSegue: return ShowsListCollectionViewController()
		case .literaturesListSegue: return LiteraturesListCollectionViewController()
		case .gamesListSegue: return GamesListCollectionViewController()
		case .studiosListSegue: return StudiosListCollectionViewController()
		case .showDetailsSegue: return ShowDetailsCollectionViewController()
		case .literatureDetailsSegue: return LiteratureDetailsCollectionViewController()
		case .gameDetailsSegue: return GameDetailsCollectionViewController()
		case .studioDetailsSegue: return StudioDetailsCollectionViewController()
		case .characterDetailsSegue: return CharacterDetailsCollectionViewController()
		case .personDetailsSegue: return PersonDetailsCollectionViewController()
		case .episodesListSegue: return EpisodesListCollectionViewController()
		case .songDetailsSegue: return SongDetailsCollectionViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .reviewsSegue:
			// Segue to reviews list
			guard let reviewsCollectionViewController = destination as? ReviewsCollectionViewController else { return }
			reviewsCollectionViewController.listType = .show(self.show)
		case .seasonsListSegue:
			// Segue to seasons list
			guard let seasonsCollectionViewController = destination as? SeasonsListCollectionViewController else { return }
			seasonsCollectionViewController.showIdentity = self.showIdentity
		case .castListSegue:
			// Segue to cast list
			guard let castListCollectionViewController = destination as? CastListCollectionViewController else { return }
			castListCollectionViewController.castKind = .show
			castListCollectionViewController.showIdentity = self.showIdentity
		case .songsListSegue:
			// Segue to songs list
			guard let showSongsListCollectionViewController = destination as? ShowSongsListCollectionViewController else { return }
			showSongsListCollectionViewController.showIdentity = self.showIdentity
		case .showsListSegue:
			// Segue to shows list
			guard let showsListCollectionViewController = destination as? ShowsListCollectionViewController else { return }
			guard let indexPath = sender as? IndexPath else { return }

			if self.snapshot.sectionIdentifiers[indexPath.section] == .moreByStudio {
				showsListCollectionViewController.title = "\(Trans.moreBy) \(self.show.attributes.studio ?? Trans.studio)"
				showsListCollectionViewController.showIdentity = self.showIdentity
				showsListCollectionViewController.showsListFetchType = .moreByStudio
			} else {
				showsListCollectionViewController.title = Trans.relatedShows
				showsListCollectionViewController.showIdentity = self.showIdentity
				showsListCollectionViewController.showsListFetchType = .relatedShow
			}
		case .literaturesListSegue:
			// Segue to literatures list
			guard let literatureListCollectionViewController = destination as? LiteraturesListCollectionViewController else { return }
			literatureListCollectionViewController.title = Trans.relatedLiteratures
			literatureListCollectionViewController.showIdentity = self.showIdentity
			literatureListCollectionViewController.literaturesListFetchType = .show
		case .gamesListSegue:
			// Segue to games list
			guard let gameListCollectionViewController = destination as? GamesListCollectionViewController else { return }
			gameListCollectionViewController.title = Trans.relatedGames
			gameListCollectionViewController.showIdentity = self.showIdentity
			gameListCollectionViewController.gamesListFetchType = .show
		case .studiosListSegue:
			// Segue to studios list
			guard let studiosListCollectionViewController = destination as? StudiosListCollectionViewController else { return }
			studiosListCollectionViewController.showIdentity = self.showIdentity
			studiosListCollectionViewController.studiosListFetchType = .show
		case .showDetailsSegue:
			// Segue to show details
			guard let showDetailsCollectionViewController = destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailsCollectionViewController.show = show
		case .literatureDetailsSegue:
			// Segue to literature details
			guard let literatureDetailsCollectionViewController = destination as? LiteratureDetailsCollectionViewController else { return }
			guard let literature = sender as? Literature else { return }
			literatureDetailsCollectionViewController.literature = literature
		case .gameDetailsSegue:
			// Segue to game details
			guard let gameDetailsCollectionViewController = destination as? GameDetailsCollectionViewController else { return }
			guard let game = sender as? Game else { return }
			gameDetailsCollectionViewController.game = game
		case .studioDetailsSegue:
			// Segue to studio details
			guard let studioDetailsCollectionViewController = destination as? StudioDetailsCollectionViewController else { return }
			guard let studio = sender as? Studio else { return }
			studioDetailsCollectionViewController.studio = studio
		case .characterDetailsSegue:
			// Segue to character details
			guard
				let characterDetailsCollectionViewController = destination as? CharacterDetailsCollectionViewController,
				let cell = sender as? CastCollectionViewCell,
				let indexPath = self.collectionView.indexPath(for: cell),
				let cast = self.cache[indexPath] as? Cast,
				let character = cast.relationships.characters.data.first
			else { return }
			characterDetailsCollectionViewController.character = character
		case .personDetailsSegue:
			// Segue to person details
			guard
				let personDetailsCollectionViewController = destination as? PersonDetailsCollectionViewController,
				let cell = sender as? CastCollectionViewCell,
				let indexPath = self.collectionView.indexPath(for: cell),
				let cast = self.cache[indexPath] as? Cast,
				let person = cast.relationships.people?.data.first
			else { return }
			personDetailsCollectionViewController.person = person
		case .episodesListSegue:
			// Segue to episodes list
			guard let episodesListCollectionViewController = destination as? EpisodesListCollectionViewController else { return }
			guard let season = sender as? Season else { return }
			episodesListCollectionViewController.seasonIdentity = SeasonIdentity(id: season.id)
			episodesListCollectionViewController.season = season
			episodesListCollectionViewController.episodesListFetchType = .season
		case .songDetailsSegue:
			// Segue to song details
			guard let songDetailsCollectionViewController = destination as? SongDetailsCollectionViewController else { return }
			guard let song = sender as? Song else { return }
			songDetailsCollectionViewController.song = song
		}
	}
}

// MARK: - CastCollectionViewCellDelegate
extension ShowDetailsCollectionViewController: CastCollectionViewCellDelegate {
	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressPersonButton button: UIButton) {
		self.show(SegueIdentifiers.personDetailsSegue, sender: cell)
	}

	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressCharacterButton button: UIButton) {
		self.show(SegueIdentifiers.characterDetailsSegue, sender: cell)
	}
}

// MARK: - TextViewCollectionViewCellDelegate
extension ShowDetailsCollectionViewController: TextViewCollectionViewCellDelegate {
	func textViewCollectionViewCell(_ cell: TextViewCollectionViewCell, didPressButton button: UIButton) {
		let synopsisViewController = SynopsisViewController()
		synopsisViewController.title = cell.textViewCollectionViewCellType.stringValue
		synopsisViewController.synopsis = self.show.attributes.synopsis

		let kNavigationController = KNavigationController(rootViewController: synopsisViewController)
		kNavigationController.modalPresentationStyle = .fullScreen

		self.present(kNavigationController, animated: true)
	}
}

// MARK: - TitleHeaderCollectionReusableViewDelegate
extension ShowDetailsCollectionViewController: TitleHeaderCollectionReusableViewDelegate {
	func titleHeaderCollectionReusableView(_ reusableView: TitleHeaderCollectionReusableView, didPress button: UIButton) {
		guard let segueID = reusableView.segueID else { return }
		self.show(segueID, sender: reusableView.indexPath)
	}
}

// MARK: - UIScrollViewDelegate
extension ShowDetailsCollectionViewController {
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let navigationBar = self.navigationController?.navigationBar
		let firstCell = self.collectionView.cellForItem(at: [0, 0])
		let offset = scrollView.contentOffset.y

		// Fade in/out the navigation title label when the first cell is fully under the navigation bar
		if let firstCellAttributes = self.collectionView.layoutAttributesForItem(at: IndexPath(item: 0, section: 0)) {
			let firstCellBottomY = firstCellAttributes.frame.maxY
			let navBarBottomY = (navigationBar?.frame.maxY ?? 0) +
				(navigationBar?.superview?.frame.origin.y ?? 0)

			if offset + navBarBottomY >= firstCellBottomY {
				if self.navigationTitleLabel.alpha == 0 {
					UIView.animate(withDuration: 0.25) {
						self.navigationTitleLabel.alpha = 1
					}
				}
			} else {
				if self.navigationTitleLabel.alpha == 1 {
					UIView.animate(withDuration: 0.25) {
						self.navigationTitleLabel.alpha = 0
					}
				}
			}
		}

		// Stretch the first cell when pulled down
		if let showHeaderCell = firstCell as? ShowDetailHeaderCollectionViewCell {
			var newFrame = showHeaderCell.frame

			if self.firstCellSize.width != showHeaderCell.frame.size.width {
				self.firstCellSize = showHeaderCell.frame.size
			}

			if offset < 0 {
				newFrame.origin.y = offset
				newFrame.size.height = self.firstCellSize.height - offset
				showHeaderCell.frame = newFrame
			} else {
				newFrame.origin.y = 0
				newFrame.size.height = self.firstCellSize.height
				showHeaderCell.frame = newFrame
			}
		}

		// Adjust the section background decoration view height when scrolled to bottom
		if let layout = self.collectionView.collectionViewLayout as? UICollectionViewCompositionalLayout, let attributes = layout.layoutAttributesForElements(in: self.collectionView.bounds) {
			for attribute in attributes where attribute.representedElementKind == SectionBackgroundDecorationView.elementKindSectionBackground {
				var newFrame = attribute.frame

				let section = attribute.indexPath.section
				let numberOfItemsInSection = self.collectionView.numberOfItems(inSection: section)
				let lastItemIndexPath = IndexPath(item: numberOfItemsInSection - 1, section: section)
				let lastItemAttributes = self.collectionView.layoutAttributesForItem(at: lastItemIndexPath)

				if let lastItemAttributes, offset + scrollView.frame.size.height > (lastItemAttributes.frame.origin.y + lastItemAttributes.frame.size.height) {
					let difference = (offset + scrollView.frame.size.height) - (lastItemAttributes.frame.origin.y + lastItemAttributes.frame.size.height)
					newFrame.size.height += difference
					attribute.frame = newFrame
				} else {
					attribute.frame = newFrame
				}
			}
		}
	}
}

// MARK: - BaseLockupCollectionViewCellDelegate
extension ShowDetailsCollectionViewController: BaseLockupCollectionViewCellDelegate {
	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressReminder button: UIButton) async {}

	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressStatus button: UIButton) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard signedIn else { return }
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		let modelID: KurozoraItemID

		switch cell.libraryKind {
		case .shows:
			switch self.dataSource.sectionIdentifier(for: indexPath.section) {
			case .moreByStudio:
				guard let show = self.cache[indexPath] as? Show else { return }
				modelID = show.id
			case .relatedShows:
				guard let show = self.relatedShows[safe: indexPath.item]?.show else { return }
				modelID = show.id
			default:
				return
			}
		case .literatures:
			guard let literature = self.relatedLiteratures[safe: indexPath.item]?.literature else { return }
			modelID = literature.id
		case .games:
			guard let game = self.relatedGames[safe: indexPath.item]?.game else { return }
			modelID = game.id
		}

		let oldLibraryStatus = cell.libraryStatus
		let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: KKLibrary.Status.alertControllerItems(for: cell.libraryKind), currentSelection: oldLibraryStatus, action: { title, value in
			Task {
				do {
					let libraryUpdateResponse = try await KService.addToLibrary(cell.libraryKind, withLibraryStatus: value, modelID: modelID).value

					switch cell.libraryKind {
					case .shows:
						self.relatedShows[safe: indexPath.item]?.show.attributes.library?.update(using: libraryUpdateResponse.data)
					case .literatures:
						self.relatedLiteratures[safe: indexPath.item]?.literature.attributes.library?.update(using: libraryUpdateResponse.data)
					case .games:
						self.relatedGames[safe: indexPath.item]?.game.attributes.library?.update(using: libraryUpdateResponse.data)
					}

					// Update entry in library
					cell.libraryStatus = value
					button.setTitle("\(title) ▾", for: .normal)

					let libraryAddToNotificationName = Notification.Name("AddTo\(value.sectionValue)Section")
					NotificationCenter.default.post(name: libraryAddToNotificationName, object: nil)
					self.configureNavBarButtons()

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
							self.relatedShows[safe: indexPath.item]?.show.attributes.library?.update(using: libraryUpdateResponse.data)
						case .literatures:
							self.relatedLiteratures[safe: indexPath.item]?.literature.attributes.library?.update(using: libraryUpdateResponse.data)
						case .games:
							self.relatedGames[safe: indexPath.item]?.game.attributes.library?.update(using: libraryUpdateResponse.data)
						}

						// Update entry in library
						cell.libraryStatus = .none
						button.setTitle(Trans.add.uppercased(), for: .normal)

						let libraryRemoveFromNotificationName = Notification.Name("RemoveFrom\(oldLibraryStatus.sectionValue)Section")
						NotificationCenter.default.post(name: libraryRemoveFromNotificationName, object: nil)
						self.configureNavBarButtons()
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

// MARK: - ReviewCollectionViewCellDelegate
extension ShowDetailsCollectionViewController: ReviewCollectionViewCellDelegate {
	func reviewCollectionViewCell(_ cell: ReviewCollectionViewCell, didPressUserName sender: AnyObject) {
		guard let indexPath = collectionView.indexPath(for: cell) else { return }
		self.reviews[indexPath.item].visitOriginalPosterProfile(from: self)
	}

	func reviewCollectionViewCell(_ cell: ReviewCollectionViewCell, didPressProfileBadge button: UIButton, for profileBadge: ProfileBadge) {
		let badgeViewController = BadgeViewController.instantiate()
		badgeViewController.profileBadge = profileBadge
		badgeViewController.popoverPresentationController?.sourceView = button
		badgeViewController.popoverPresentationController?.sourceRect = button.bounds

		self.present(badgeViewController, animated: true, completion: nil)
	}
}

// MARK: - TapToRateCollectionViewCellDelegate
extension ShowDetailsCollectionViewController: TapToRateCollectionViewCellDelegate {
	func tapToRateCollectionViewCell(_ cell: TapToRateCollectionViewCell, rateWith rating: Double) {
		Task { [weak self] in
			guard let self = self else { return }

			do throws(KKAPIError) {
				let rating = try await self.show.rate(using: rating, description: nil)
				cell.configure(using: rating)

				if rating != nil {
					self.showRatingSuccessAlert()
				}
			} catch {
				print(error.localizedDescription)
				self.showRatingFailureAlert(message: error.message)
			}
		}
	}
}

// MARK: - WriteAReviewCollectionViewCellDelegate
extension ShowDetailsCollectionViewController: WriteAReviewCollectionViewCellDelegate {
	func writeAReviewCollectionViewCell(_ cell: WriteAReviewCollectionViewCell, didPress button: UIButton) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard signedIn else { return }

		let reviewTextEditorViewController = ReviewTextEditorViewController()
		reviewTextEditorViewController.delegate = self
		reviewTextEditorViewController.router?.dataStore?.kind = .show(self.show)
		reviewTextEditorViewController.router?.dataStore?.rating = self.show.attributes.library?.rating
		reviewTextEditorViewController.router?.dataStore?.review = self.show.attributes.library?.review

		let navigationController = KNavigationController(rootViewController: reviewTextEditorViewController)
		navigationController.presentationController?.delegate = reviewTextEditorViewController
		self.present(navigationController, animated: true)
	}
}

// MARK: - ReviewTextEditorViewControllerDelegate
extension ShowDetailsCollectionViewController: ReviewTextEditorViewControllerDelegate {
	func reviewTextEditorViewControllerDidSubmitReview() {
		self.showRatingSuccessAlert()
	}
}

// MARK: - MusicLockupCollectionViewCellDelegate
extension ShowDetailsCollectionViewController: MusicLockupCollectionViewCellDelegate {
	func showButtonPressed(_ sender: UIButton, indexPath: IndexPath) {}
}

extension ShowDetailsCollectionViewController: MediaTransitionDelegate {
	func imageViewForMedia(at index: Int) -> UIImageView? {
		// Find the visible cell for the index and return its thumbnail UIImageView.
		// Example (collectionView):
		guard let cell = self.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? ShowDetailHeaderCollectionViewCell else {
			return nil
		}
		return cell.posterImageView
	}

	func scrollThumbnailIntoView(for index: Int) {
		// Scroll the collection view to make sure the cell at the given index is visible.
		let indexPath = IndexPath(item: index, section: 0)
		self.collectionView.safeScrollToItem(at: indexPath, at: .centeredVertically, animated: true)
	}
}

extension ShowDetailsCollectionViewController: BaseDetailHeaderCollectionViewCellDelegate {
	func baseDetailHeaderCollectionViewCell(_ cell: BaseDetailHeaderCollectionViewCell, didTapImage imageView: UIImageView, at index: Int) {
		let posterURL = URL(string: self.show.attributes.poster?.url ?? "")
		let bannerURL = URL(string: self.show.attributes.banner?.url ?? "")
		var items: [MediaItemV2] = []

		if let posterURL = posterURL {
			items.append(MediaItemV2(
				url: posterURL,
				type: .image,
				title: self.show.attributes.title,
				description: nil,
				author: nil,
				provider: nil,
				embedHTML: nil,
				extraInfo: nil
			))
		}
		if let bannerURL = bannerURL {
			items.append(MediaItemV2(
				url: bannerURL,
				type: .image,
				title: self.show.attributes.title,
				description: nil,
				author: nil,
				provider: nil,
				embedHTML: nil,
				extraInfo: nil
			))
		}

		let albumVC = MediaAlbumViewController(items: items, startIndex: index)
		albumVC.transitionDelegateForThumbnail = self

		self.present(albumVC, animated: true)
	}

	func baseDetailHeaderCollectionViewCell(_ cell: BaseDetailHeaderCollectionViewCell, didPressStatus button: UIButton) async {
		guard await WorkflowController.shared.isSignedIn(), let cell = cell as? ShowDetailHeaderCollectionViewCell else { return }
		let oldLibraryStatus = cell.libraryStatus
		let modelID: KurozoraItemID

		switch cell.libraryKind {
		case .shows:
			guard let show = cell.show else { return }
			modelID = show.id
		case .literatures:
			guard let literature = cell.literature else { return }
			modelID = literature.id
		case .games:
			guard let game = cell.game else { return }
			modelID = game.id
		}

		let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: KKLibrary.Status.alertControllerItems(for: cell.libraryKind), currentSelection: oldLibraryStatus, action: { _, value in
			if oldLibraryStatus != value {
				Task {
					do {
						let libraryUpdateResponse = try await KService.addToLibrary(cell.libraryKind, withLibraryStatus: value, modelID: modelID).value

						// Update entry in library
						cell.libraryStatus = value

						switch cell.libraryKind {
						case .shows:
							guard let show = cell.show else { return }
							show.attributes.library?.update(using: libraryUpdateResponse.data)
							cell.updateLibraryActions(using: show, animated: oldLibraryStatus == .none)
						case .literatures:
							guard let literature = cell.literature else { return }
							literature.attributes.library?.update(using: libraryUpdateResponse.data)
							cell.updateLibraryActions(using: literature, animated: oldLibraryStatus == .none)
						case .games:
							guard let game = cell.game else { return }
							game.attributes.library?.update(using: libraryUpdateResponse.data)
							cell.updateLibraryActions(using: game, animated: oldLibraryStatus == .none)
						}

						let libraryRemoveFromNotificationName = Notification.Name("RemoveFrom\(oldLibraryStatus.sectionValue)Section")
						NotificationCenter.default.post(name: libraryRemoveFromNotificationName, object: nil)

						let libraryAddToNotificationName = Notification.Name("AddTo\(value.sectionValue)Section")
						NotificationCenter.default.post(name: libraryAddToNotificationName, object: nil)

						// Request review
						ReviewManager.shared.requestReview(for: .itemAddedToLibrary(status: value))
					} catch let error as KKAPIError {
						//							self.presentAlertController(title: "Can't Add to Your Library 😔", message: error.message)
						print("----- Add to library failed", error.message)
					}
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
							guard let show = cell.show else { return }
							show.attributes.library?.update(using: libraryUpdateResponse.data)
							cell.updateLibraryActions(using: show, animated: true)
						case .literatures:
							guard let literature = cell.literature else { return }
							literature.attributes.library?.update(using: libraryUpdateResponse.data)
							cell.updateLibraryActions(using: literature, animated: true)
						case .games:
							guard let game = cell.game else { return }
							game.attributes.library?.update(using: libraryUpdateResponse.data)
							cell.updateLibraryActions(using: game, animated: true)
						}

						// Update entry in library
						cell.libraryStatus = .none

						let libraryRemoveFromNotificationName = Notification.Name("RemoveFrom\(oldLibraryStatus.sectionValue)Section")
						NotificationCenter.default.post(name: libraryRemoveFromNotificationName, object: nil)
					} catch let error as KKAPIError {
//						self.presentAlertController(title: "Can't Remove From Your Library 😔", message: error.message)
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

extension ShowDetailsCollectionViewController {
	enum SectionLayoutKind: Int, CaseIterable {
		// MARK: - Cases
		/// Indicates a header section layout type.
		case header = 0

		/// Indicates badges section layout type.
		case badges

		/// Indicates a synopsis section layout type.
		case synopsis

		/// Indicates rating section layout type.
		case rating

		/// Indicates rate and review section layout type.
		case rateAndReview

		/// Indicates reviews section layout type.
		case reviews

		/// Indicates information section layout type.
		case information

		/// Indicates seasons section layout type.
		case seasons

		/// Indicates cast section layout type.
		case cast

		/// Indicates songs section layout type.
		case songs

		/// Indicates studios section layout type.
		case studios

		/// Indicates more by studio section layout type.
		case moreByStudio

		/// Indicates related shows section layout type.
		case relatedShows

		/// Indicates related literatures section layout type.
		case relatedLiteratures

		/// Indicates related games section layout
		case relatedGames

		/// Indicates copyright section layout type
		case sosumi

		// MARK: - Properties
		/// The string value of a show section type.
		var stringValue: String {
			switch self {
			case .header:
				return Trans.header
			case .badges:
				return Trans.badges
			case .synopsis:
				return Trans.synopsis
			case .rating:
				return Trans.ratingsAndReviews
			case .rateAndReview:
				return ""
			case .reviews:
				return ""
			case .information:
				return Trans.information
			case .seasons:
				return Trans.seasons
			case .cast:
				return Trans.cast
			case .songs:
				return Trans.songs
			case .studios:
				return Trans.studios
			case .moreByStudio:
				return Trans.moreBy
			case .relatedShows:
				return Trans.relatedShows
			case .relatedLiteratures:
				return Trans.relatedLiteratures
			case .relatedGames:
				return Trans.relatedGames
			case .sosumi:
				return Trans.copyright
			}
		}

		/// The string value of a show section type segue identifier.
		var segueIdentifier: SegueIdentifiers? {
			switch self {
			case .header, .badges, .synopsis, .rateAndReview, .reviews, .information, .sosumi:
				return nil
			case .rating:
				return .reviewsSegue
			case .seasons:
				return .seasonsListSegue
			case .cast:
				return .castListSegue
			case .songs:
				return .songsListSegue
			case .studios:
				return .studiosListSegue
			case .moreByStudio:
				return .showsListSegue
			case .relatedShows:
				return .showsListSegue
			case .relatedLiteratures:
				return .literaturesListSegue
			case .relatedGames:
				return .gamesListSegue
			}
		}
	}

	/// List of available Item Kind types.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `Show` object.
		case show(_: Show, id: UUID = UUID())

		/// Indicates the item kind contains a `Review` object.
		case review(_: Review, id: UUID = UUID())

		/// Indicates the item kind contains a `SeasonIdentity` object.
		case seasonIdentity(_: SeasonIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `ShowIdentity` object.
		case showIdentity(_: ShowIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `RelatedShow` object.
		case relatedShow(_: RelatedShow, id: UUID = UUID())

		/// Indicates the item kind contains a `RelatedLiterature` object.
		case relatedLiterature(_: RelatedLiterature, id: UUID = UUID())

		/// Indicates the item kind contains a `RelatedGame` object.
		case relatedGame(_: RelatedGame, id: UUID = UUID())

		/// Indicates the item kind contains a `ShowSong` object.
		case showSong(_: ShowSong, id: UUID = UUID())

		/// Indicates the item kind contains a `CharacterIdentity` object.
		case characterIdentity(_: CharacterIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `PersonIdentity` object.
		case personIdentity(_: PersonIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `CastIdentity` object.
		case castIdentity(_: CastIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `StudioIdentity` object.
		case studioIdentity(_: StudioIdentity, id: UUID = UUID())

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .show(let show, let id):
				hasher.combine(show)
				hasher.combine(id)
			case .review(let review, let id):
				hasher.combine(review)
				hasher.combine(id)
			case .seasonIdentity(let seasonIdentity, let id):
				hasher.combine(seasonIdentity)
				hasher.combine(id)
			case .showIdentity(let showIdentity, let id):
				hasher.combine(showIdentity)
				hasher.combine(id)
			case .relatedShow(let relatedShow, let id):
				hasher.combine(relatedShow)
				hasher.combine(id)
			case .relatedLiterature(let relatedLiterature, let id):
				hasher.combine(relatedLiterature)
				hasher.combine(id)
			case .relatedGame(let relatedGame, let id):
				hasher.combine(relatedGame)
				hasher.combine(id)
			case .showSong(let showSong, let id):
				hasher.combine(showSong)
				hasher.combine(id)
			case .characterIdentity(let characterIdentity, let id):
				hasher.combine(characterIdentity)
				hasher.combine(id)
			case .personIdentity(let personIdentity, let id):
				hasher.combine(personIdentity)
				hasher.combine(id)
			case .castIdentity(let castIdentity, let id):
				hasher.combine(castIdentity)
				hasher.combine(id)
			case .studioIdentity(let studioIdentity, let id):
				hasher.combine(studioIdentity)
				hasher.combine(id)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.show(let show1, let id1), .show(let show2, let id2)):
				return show1 == show2 && id1 == id2
			case (.review(let review1, let id1), .review(let review2, let id2)):
				return review1 == review2 && id1 == id2
			case (.seasonIdentity(let seasonIdentity1, let id1), .seasonIdentity(let seasonIdentity2, let id2)):
				return seasonIdentity1 == seasonIdentity2 && id1 == id2
			case (.showIdentity(let showIdentity1, let id1), .showIdentity(let showIdentity2, let id2)):
				return showIdentity1 == showIdentity2 && id1 == id2
			case (.relatedShow(let relatedShow1, let id1), .relatedShow(let relatedShow2, let id2)):
				return relatedShow1 == relatedShow2 && id1 == id2
			case (.relatedLiterature(let relatedLiterature1, let id1), .relatedLiterature(let relatedLiterature2, let id2)):
				return relatedLiterature1 == relatedLiterature2 && id1 == id2
			case (.relatedGame(let relatedGame1, let id1), .relatedGame(let relatedGame2, let id2)):
				return relatedGame1 == relatedGame2 && id1 == id2
			case (.showSong(let showSong1, let id1), .showSong(let showSong2, let id2)):
				return showSong1 == showSong2 && id1 == id2
			case (.characterIdentity(let characterIdentity1, let id1), .characterIdentity(let characterIdentity2, let id2)):
				return characterIdentity1 == characterIdentity2 && id1 == id2
			case (.personIdentity(let personIdentity1, let id1), .personIdentity(let personIdentity2, let id2)):
				return personIdentity1 == personIdentity2 && id1 == id2
			case (.castIdentity(let castIdentity1, let id1), .castIdentity(let castIdentity2, let id2)):
				return castIdentity1 == castIdentity2 && id1 == id2
			case (.studioIdentity(let studioIdentity1, let id1), .studioIdentity(let studioIdentity2, let id2)):
				return studioIdentity1 == studioIdentity2 && id1 == id2
			default:
				return false
			}
		}
	}
}

// MARK: - Cell Configuration
extension ShowDetailsCollectionViewController {
	func getConfiguredCastCell() -> UICollectionView.CellRegistration<CastCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<CastCollectionViewCell, ItemKind>(cellNib: CastCollectionViewCell.nib) { [weak self] castCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .castIdentity:
				let cast: Cast? = self.fetchModel(at: indexPath)

				if cast == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(CastResponse.self, CastIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				castCollectionViewCell.delegate = self
				castCollectionViewCell.configure(using: cast)
			default: return
			}
		}
	}

	func getConfiguredStudioShowCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: SmallLockupCollectionViewCell.nib) { [weak self] smallLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .showIdentity:
				let show: Show? = self.fetchModel(at: indexPath)

				if show == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ShowResponse.self, ShowIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.configure(using: show)
			default: return
			}
		}
	}

	func getConfiguredSeasonCell() -> UICollectionView.CellRegistration<SeasonLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SeasonLockupCollectionViewCell, ItemKind>(cellNib: SeasonLockupCollectionViewCell.nib) { [weak self] seasonLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .seasonIdentity:
				let season: Season? = self.fetchModel(at: indexPath)

				if season == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(SeasonResponse.self, SeasonIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				seasonLockupCollectionViewCell.configure(using: season)
			default: return
			}
		}
	}

	func getConfiguredStudioCell() -> UICollectionView.CellRegistration<StudioLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<StudioLockupCollectionViewCell, ItemKind>(cellNib: StudioLockupCollectionViewCell.nib) { [weak self] studioLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .studioIdentity:
				let studio: Studio? = self.fetchModel(at: indexPath)

				if studio == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(StudioResponse.self, StudioIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				studioLockupCollectionViewCell.configure(using: studio)
			default: break
			}
		}
	}

	func getConfiguredMusicCell() -> UICollectionView.CellRegistration<MusicLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<MusicLockupCollectionViewCell, ItemKind>(cellNib: MusicLockupCollectionViewCell.nib) { musicLockupCollectionViewCell, indexPath, itemKind in
			switch itemKind {
			case .showSong(let showSong, _):
				musicLockupCollectionViewCell.delegate = self
				musicLockupCollectionViewCell.configure(using: showSong, at: indexPath)
			default: break
			}
		}
	}

	func getConfiguredRelatedShowCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: SmallLockupCollectionViewCell.nib) { smallLockupCollectionViewCell, _, itemKind in
			smallLockupCollectionViewCell.delegate = self

			switch itemKind {
			case .relatedShow(let relatedShow, _):
				smallLockupCollectionViewCell.configure(using: relatedShow)
			case .relatedLiterature(let relatedLiterature, _):
				smallLockupCollectionViewCell.configure(using: relatedLiterature)
			default: return
			}
		}
	}

	func getConfiguredRelatedGameCell() -> UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind>(cellNib: GameLockupCollectionViewCell.nib) { gameLockupCollectionViewCell, _, itemKind in
			gameLockupCollectionViewCell.delegate = self

			switch itemKind {
			case .relatedGame(let relatedGame, _):
				gameLockupCollectionViewCell.configure(using: relatedGame)
			default: return
			}
		}
	}
}
