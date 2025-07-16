//
//  ShowDetailsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Alamofire
import AVFoundation
import Intents
import IntentsUI

class ShowDetailsCollectionViewController: KCollectionViewController, RatingAlertPresentable {
	// MARK: - IBOutlets
	@IBOutlet weak var moreBarButtonItem: UIBarButtonItem!
	@IBOutlet weak var navigationTitleView: UIView!
	@IBOutlet weak var navigationTitleLabel: UILabel! {
		didSet {
			self.navigationTitleLabel.theme_textColor = KThemePicker.barTitleTextColor.rawValue
		}
	}

	// MARK: - Properties
	var showIdentity: ShowIdentity? = nil
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
	var seasons: [IndexPath: Season] = [:]
	var seasonIdentities: [SeasonIdentity] = []

	/// Related Show properties.
	var relatedShows: [RelatedShow] = []

	/// Related Literature properties.
	var relatedLiteratures: [RelatedLiterature] = []

	/// Related Game properties.
	var relatedGames: [RelatedGame] = []

	/// Cast properties.
	var cast: [IndexPath: Cast] = [:]
	var castIdentities: [CastIdentity] = []

	/// Studio properties.
	var studios: [IndexPath: Studio] = [:]
	var studioIdentities: [StudioIdentity] = []
//	var studio: Studio!
	var studioShows: [IndexPath: Show] = [:]
	var studioShowIdentities: [ShowIdentity] = []

	/// Show Song properties.
	var showSongs: [ShowSong] = []

	/// The object that provides the interface to control the player’s transport behavior.
	var player: AVPlayer?

	/// The index path of the song that's currently playing.
	var currentPlayerIndexPath: IndexPath?

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>! = nil
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>! = nil
	var prefetchingIndexPathOperations: [IndexPath: DataRequest] = [:]

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
	static func `init`(with showID: String) -> ShowDetailsCollectionViewController {
		if let showDetailsCollectionViewController = R.storyboard.shows.showDetailsCollectionViewController() {
			showDetailsCollectionViewController.showIdentity = ShowIdentity(id: showID)
			return showDetailsCollectionViewController
		}

		fatalError("Failed to instantiate ShowDetailsCollectionViewController with the given show id.")
	}

	/// Initialize a new instance of ShowDetailsCollectionViewController with the given show object.
	///
	/// - Parameter show: The `Show` object to use when initializing the view controller.
	///
	/// - Returns: an initialized instance of ShowDetailsCollectionViewController.
	static func `init`(with show: Show) -> ShowDetailsCollectionViewController {
		if let showDetailsCollectionViewController = R.storyboard.shows.showDetailsCollectionViewController() {
			showDetailsCollectionViewController.show = show
			return showDetailsCollectionViewController
		}

		fatalError("Failed to instantiate ShowDetailsCollectionViewController with the given Show object.")
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		NotificationCenter.default.addObserver(self, selector: #selector(handleFavoriteToggle(_:)), name: .KModelFavoriteIsToggled, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(handleReminderToggle(_:)), name: .KModelReminderIsToggled, object: nil)

		self.navigationTitleLabel.alpha = 0

		// Add refresh control
		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		self.configureDataSource()

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

	// MARK: - Functions
	override func handleRefreshControl() {
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchDetails()
		}
	}

	override func configureEmptyDataView() {
		self.emptyBackgroundView.configureImageView(image: R.image.empty.animeLibrary()!)
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

	func configureNavBarButtons() {
		self.moreBarButtonItem.menu = self.show?.makeContextMenu(in: self, userInfo: [:])
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
		self.show?.toggleFavorite()
	}

	@objc func toggleReminder() {
		self.show?.toggleReminder(on: self)
	}

	@objc func shareShow() {
		self.show?.openShareSheet(on: self)
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

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.showDetailsCollectionViewController.reviewsSegue.identifier:
			// Segue to reviews list
			guard let reviewsCollectionViewController = segue.destination as? ReviewsCollectionViewController else { return }
			reviewsCollectionViewController.listType = .show(self.show)
		case R.segue.showDetailsCollectionViewController.seasonsListSegue.identifier:
			// Segue to seasons list
			guard let seasonsCollectionViewController = segue.destination as? SeasonsListCollectionViewController else { return }
			seasonsCollectionViewController.showIdentity = self.showIdentity
		case R.segue.showDetailsCollectionViewController.castListSegue.identifier:
			// Segue to cast list
			guard let castListCollectionViewController = segue.destination as? CastListCollectionViewController else { return }
			castListCollectionViewController.castKind = .show
			castListCollectionViewController.showIdentity = self.showIdentity
		case R.segue.showDetailsCollectionViewController.songsListSegue.identifier:
			// Segue to songs list
			guard let showSongsListCollectionViewController = segue.destination as? ShowSongsListCollectionViewController else { return }
			showSongsListCollectionViewController.showIdentity = self.showIdentity
		case R.segue.showDetailsCollectionViewController.showsListSegue.identifier:
			// Segue to shows list
			guard let showsListCollectionViewController = segue.destination as? ShowsListCollectionViewController else { return }
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
		case R.segue.showDetailsCollectionViewController.literaturesListSegue.identifier:
			// Segue to literatures list
			guard let literatureListCollectionViewController = segue.destination as? LiteraturesListCollectionViewController else { return }
			literatureListCollectionViewController.title = Trans.relatedLiteratures
			literatureListCollectionViewController.showIdentity = self.showIdentity
			literatureListCollectionViewController.literaturesListFetchType = .show
		case R.segue.showDetailsCollectionViewController.gamesListSegue.identifier:
			// Segue to games list
			guard let gameListCollectionViewController = segue.destination as? GamesListCollectionViewController else { return }
			gameListCollectionViewController.title = Trans.relatedGames
			gameListCollectionViewController.showIdentity = self.showIdentity
			gameListCollectionViewController.gamesListFetchType = .show
		case R.segue.showDetailsCollectionViewController.studiosListSegue.identifier:
			// Segue to studios list
			guard let studiosListCollectionViewController = segue.destination as? StudiosListCollectionViewController else { return }
			studiosListCollectionViewController.showIdentity = self.showIdentity
			studiosListCollectionViewController.studiosListFetchType = .show
		case R.segue.showDetailsCollectionViewController.showDetailsSegue.identifier:
			// Segue to show details
			guard let showDetailsCollectionViewController = segue.destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailsCollectionViewController.show = show
		case R.segue.showDetailsCollectionViewController.literatureDetailsSegue.identifier:
			// Segue to literature details
			guard let literatureDetailsCollectionViewController = segue.destination as? LiteratureDetailsCollectionViewController else { return }
			guard let literature = sender as? Literature else { return }
			literatureDetailsCollectionViewController.literature = literature
		case R.segue.showDetailsCollectionViewController.gameDetailsSegue.identifier:
			// Segue to game details
			guard let gameDetailsCollectionViewController = segue.destination as? GameDetailsCollectionViewController else { return }
			guard let game = sender as? Game else { return }
			gameDetailsCollectionViewController.game = game
		case R.segue.showDetailsCollectionViewController.studioDetailsSegue.identifier:
			// Segue to studio details
			guard let studioDetailsCollectionViewController = segue.destination as? StudioDetailsCollectionViewController else { return }
			guard let studio = sender as? Studio else { return }
			studioDetailsCollectionViewController.studio = studio
		case R.segue.showDetailsCollectionViewController.characterDetailsSegue.identifier:
			// Segue to character details
			guard let characterDetailsCollectionViewController = segue.destination as? CharacterDetailsCollectionViewController else { return }
			guard let cell = sender as? CastCollectionViewCell else { return }
			guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
			guard let character = self.cast[indexPath]?.relationships.characters.data.first else { return }
			characterDetailsCollectionViewController.character = character
		case R.segue.showDetailsCollectionViewController.personDetailsSegue.identifier:
			// Segue to person details
			guard let personDetailsCollectionViewController = segue.destination as? PersonDetailsCollectionViewController else { return }
			guard let cell = sender as? CastCollectionViewCell else { return }
			guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
			guard let person = self.cast[indexPath]?.relationships.people?.data.first else { return }
			personDetailsCollectionViewController.person = person
		case R.segue.showDetailsCollectionViewController.episodesListSegue.identifier:
			// Segue to episodes list
			guard let episodesListCollectionViewController = segue.destination as? EpisodesListCollectionViewController else { return }
			guard let season = sender as? Season else { return }
			episodesListCollectionViewController.seasonIdentity = SeasonIdentity(id: season.id)
			episodesListCollectionViewController.season = season
			episodesListCollectionViewController.episodesListFetchType = .season
		case R.segue.homeCollectionViewController.songDetailsSegue.identifier:
			// Segue to song details
			guard let songDetailsCollectionViewController = segue.destination as? SongDetailsCollectionViewController else { return }
			guard let song = sender as? Song else { return }
			songDetailsCollectionViewController.song = song
		default: break
		}
	}
}

// MARK: - CastCollectionViewCellDelegate
extension ShowDetailsCollectionViewController: CastCollectionViewCellDelegate {
	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressPersonButton button: UIButton) {
		self.performSegue(withIdentifier: R.segue.showDetailsCollectionViewController.personDetailsSegue.identifier, sender: cell)
	}

	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressCharacterButton button: UIButton) {
		self.performSegue(withIdentifier: R.segue.showDetailsCollectionViewController.characterDetailsSegue.identifier, sender: cell)
	}
}

// MARK: - TextViewCollectionViewCellDelegate
extension ShowDetailsCollectionViewController: TextViewCollectionViewCellDelegate {
	func textViewCollectionViewCell(_ cell: TextViewCollectionViewCell, didPressButton button: UIButton) {
		if let synopsisKNavigationController = R.storyboard.synopsis.instantiateInitialViewController() {
			if let synopsisViewController = synopsisKNavigationController.viewControllers.first as? SynopsisViewController {
				synopsisViewController.title = cell.textViewCollectionViewCellType.stringValue
				synopsisViewController.synopsis = self.show.attributes.synopsis
			}
			synopsisKNavigationController.modalPresentationStyle = .fullScreen
			self.present(synopsisKNavigationController, animated: true)
		}
	}
}

// MARK: - TitleHeaderCollectionReusableViewDelegate
extension ShowDetailsCollectionViewController: TitleHeaderCollectionReusableViewDelegate {
	func titleHeaderCollectionReusableView(_ reusableView: TitleHeaderCollectionReusableView, didPress button: UIButton) {
		self.performSegue(withIdentifier: reusableView.segueID, sender: reusableView.indexPath)
	}
}

// MARK: - UIScrollViewDelegate
extension ShowDetailsCollectionViewController {
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let navigationBar = self.navigationController?.navigationBar
		let firstCell = self.collectionView.cellForItem(at: [0, 0])

		let globalNavigationBarPositionY = navigationBar?.superview?.convert(navigationBar?.frame.origin ?? CGPoint(x: 0, y: 0), to: nil).y ?? .zero
		let offset = scrollView.contentOffset.y
		let firstCellHeight = firstCell?.frame.size.height ?? .zero

		let percentage = offset / (firstCellHeight - globalNavigationBarPositionY)

		if percentage.isFinite, percentage >= 0 {
			self.navigationTitleLabel.alpha = percentage
		}
	}
}

// MARK: - BaseLockupCollectionViewCellDelegate
extension ShowDetailsCollectionViewController: BaseLockupCollectionViewCellDelegate {
	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressReminder button: UIButton) { }

	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressStatus button: UIButton) {
		WorkflowController.shared.isSignedIn { [weak self] in
			guard let self = self else { return }
			guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
			let modelID: String

			switch cell.libraryKind {
			case .shows:
				switch self.dataSource.sectionIdentifier(for: indexPath.section) {
				case .moreByStudio:
					guard let show = self.studioShows[indexPath] else { return }
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
			let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: KKLibrary.Status.alertControllerItems(for: cell.libraryKind), currentSelection: oldLibraryStatus, action: { title, value  in
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
}

// MARK: - ReviewCollectionViewCellDelegate
extension ShowDetailsCollectionViewController: ReviewCollectionViewCellDelegate {
	func reviewCollectionViewCell(_ cell: ReviewCollectionViewCell, didPressUserName sender: AnyObject) {
		guard let indexPath = collectionView.indexPath(for: cell) else { return }
		self.reviews[indexPath.item].visitOriginalPosterProfile(from: self)
	}

	func reviewCollectionViewCell(_ cell: ReviewCollectionViewCell, didPressProfileBadge button: UIButton, for profileBadge: ProfileBadge) {
		if let badgeViewController = R.storyboard.badge.instantiateInitialViewController() {
			badgeViewController.profileBadge = profileBadge
			badgeViewController.popoverPresentationController?.sourceView = button
			badgeViewController.popoverPresentationController?.sourceRect = button.bounds

			self.present(badgeViewController, animated: true, completion: nil)
		}
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
	func writeAReviewCollectionViewCell(_ cell: WriteAReviewCollectionViewCell, didPress button: UIButton) {
		WorkflowController.shared.isSignedIn { [weak self] in
			guard let self = self else { return }

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
		var segueIdentifier: String {
			switch self {
			case .header:
				return ""
			case .badges:
				return ""
			case .synopsis:
				return ""
			case .rating:
				return R.segue.showDetailsCollectionViewController.reviewsSegue.identifier
			case .rateAndReview:
				return ""
			case .reviews:
				return ""
			case .information:
				return ""
			case .seasons:
				return R.segue.showDetailsCollectionViewController.seasonsListSegue.identifier
			case .cast:
				return R.segue.showDetailsCollectionViewController.castListSegue.identifier
			case .songs:
				return R.segue.showDetailsCollectionViewController.songsListSegue.identifier
			case .studios:
				return R.segue.showDetailsCollectionViewController.studiosListSegue.identifier
			case .moreByStudio:
				return R.segue.showDetailsCollectionViewController.showsListSegue.identifier
			case .relatedShows:
				return R.segue.showDetailsCollectionViewController.showsListSegue.identifier
			case .relatedLiteratures:
				return R.segue.showDetailsCollectionViewController.literaturesListSegue.identifier
			case .relatedGames:
				return R.segue.showDetailsCollectionViewController.gamesListSegue.identifier
			case .sosumi:
				return ""
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
