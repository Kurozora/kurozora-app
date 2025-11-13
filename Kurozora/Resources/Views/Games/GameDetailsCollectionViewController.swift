//
//  GameDetailsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/03/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import Alamofire
import AVFoundation
import Intents
import IntentsUI
import KurozoraKit
import UIKit

class GameDetailsCollectionViewController: KCollectionViewController, RatingAlertPresentable {
	// MARK: - IBOutlets
	@IBOutlet weak var moreBarButtonItem: UIBarButtonItem!
	@IBOutlet weak var navigationTitleView: UIView!
	@IBOutlet weak var navigationTitleLabel: UILabel! {
		didSet {
			self.navigationTitleLabel.theme_textColor = KThemePicker.barTitleTextColor.rawValue
		}
	}

	// MARK: - Properties
	var gameIdentity: GameIdentity?
	var game: Game! {
		didSet {
			self.title = self.game.attributes.title
			self.navigationTitleLabel.text = self.game.attributes.title
			self.gameIdentity = GameIdentity(id: self.game.id)

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

	// Review properties.
	var reviews: [Review] = []

	// Related Game properties.
	var relatedGames: [RelatedGame] = []

	// Related Show properties.
	var relatedShows: [RelatedShow] = []

	// Related Literature properties.
	var relatedLiteratures: [RelatedLiterature] = []

	// Cast properties.
	var cast: [IndexPath: Cast] = [:]
	var castIdentities: [CastIdentity] = []

	// Studio properties.
	var studios: [IndexPath: Studio] = [:]
	var studioIdentities: [StudioIdentity] = []
//	var studio: Studio!
	var studioGames: [IndexPath: Game] = [:]
	var studioGameIdentities: [GameIdentity] = []

	/// The first cell's size.
	private var firstCellSize: CGSize = .zero

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!
	var prefetchingIndexPathOperations: [IndexPath: DataRequest] = [:]

	// Touch Bar
	#if targetEnvironment(macCatalyst)
	var toggleGameIsFavoriteTouchBarItem: NSButtonTouchBarItem?
	var toggleGameIsRemindedTouchBarItem: NSButtonTouchBarItem?
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
	/// Initialize a new instance of GameDetailsCollectionViewController with the given game id.
	///
	/// - Parameter gameID: The game id to use when initializing the view.
	///
	/// - Returns: an initialized instance of GameDetailsCollectionViewController.
	static func `init`(with gameID: String) -> GameDetailsCollectionViewController {
		if let gameDetailsCollectionViewController = R.storyboard.games.gameDetailsCollectionViewController() {
			gameDetailsCollectionViewController.gameIdentity = GameIdentity(id: gameID)
			return gameDetailsCollectionViewController
		}

		fatalError("Failed to instantiate GameDetailsCollectionViewController with the given game id.")
	}

	/// Initialize a new instance of GameDetailsCollectionViewController with the given game object.
	///
	/// - Parameter game: The `Game` object to use when initializing the view controller.
	///
	/// - Returns: an initialized instance of GameDetailsCollectionViewController.
	static func `init`(with game: Game) -> GameDetailsCollectionViewController {
		if let gameDetailsCollectionViewController = R.storyboard.games.gameDetailsCollectionViewController() {
			gameDetailsCollectionViewController.game = game
			return gameDetailsCollectionViewController
		}

		fatalError("Failed to instantiate GameDetailsCollectionViewController with the given Game object.")
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleFavoriteToggle(_:)), name: .KModelFavoriteIsToggled, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleReminderToggle(_:)), name: .KModelReminderIsToggled, object: nil)

		self.navigationTitleLabel.alpha = 0

		// Add refresh control
		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		self.configureDataSource()

		// Fetch game details.
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

	// MARK: - Functions
	override func handleRefreshControl() {
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchDetails()
		}
	}

	override func configureEmptyDataView() {
		DispatchQueue.main.async {
			self.emptyBackgroundView.configureImageView(image: .Empty.gameLibrary)
			self.emptyBackgroundView.configureLabels(title: "No Details", detail: "This game doesn't have details yet. Please check back again later.")

			self.collectionView.backgroundView?.alpha = 0
		}
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
		self.moreBarButtonItem.menu = self.game?.makeContextMenu(in: self, userInfo: [:], sourceView: nil, barButtonItem: self.moreBarButtonItem)
	}

	/// Fetches details for the given game identity. If none given then the currently viewed game's details are fetched.
	func fetchDetails() async {
		guard let gameIdentity = self.gameIdentity else { return }

		if self.game == nil {
			do {
				let gameResponse = try await KService.getDetails(forGame: gameIdentity).value
				self.game = gameResponse.data.first

				// Donate suggestion to Siri
				self.userActivity = self.game.openDetailUserActivity
			} catch {
				print(error.localizedDescription)
			}

			self.configureNavBarButtons()
		} else {
			// Donate suggestion to Siri
			self.userActivity = self.game.openDetailUserActivity

			self.updateDataSource()
			self.configureNavBarButtons()
		}

		do {
			let reviewIdentityResponse = try await KService.getReviews(forGame: gameIdentity, next: nil, limit: 10).value
			self.reviews = reviewIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let castIdentityResponse = try await KService.getCast(forGame: gameIdentity, limit: 10).value
			self.castIdentities = castIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let studioIdentityResponse = try await KService.getStudios(forGame: gameIdentity, limit: 10).value
			self.studioIdentities = studioIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let gameIdentityResponse = try await KService.getMoreByStudio(forGame: gameIdentity, limit: 10).value
			self.studioGameIdentities = gameIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let relatedGameResponse = try await KService.getRelatedGames(forGame: gameIdentity, limit: 10).value
			self.relatedGames = relatedGameResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let relatedShowResponse = try await KService.getRelatedShows(forGame: gameIdentity, limit: 10).value
			self.relatedShows = relatedShowResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let relatedLiteratureResponse = try await KService.getRelatedLiteratures(forGame: gameIdentity, limit: 10).value
			self.relatedLiteratures = relatedLiteratureResponse.data
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

			self.game.attributes.library?.rating = nil
			self.game.attributes.library?.review = nil

			self.updateDataSource()
		}
	}

	@objc func toggleFavorite() {
		Task {
			await self.game?.toggleFavorite()
		}
	}

	@objc func toggleReminder() {
//		self.game?.toggleReminder()
	}

	@objc func handleFavoriteToggle(_ notification: NSNotification) {
		#if targetEnvironment(macCatalyst)
		let name = self.game.attributes.library?.favoriteStatus == .favorited ? "heart.fill" : "heart"
		self.toggleGameIsFavoriteTouchBarItem?.image = UIImage(systemName: name)
		#endif
	}

	@objc func handleReminderToggle(_ notification: NSNotification) {
		#if targetEnvironment(macCatalyst)
		let name = self.game.attributes.library?.reminderStatus == .reminded ? "bell.fill" : "bell"
		self.toggleGameIsRemindedTouchBarItem?.image = UIImage(systemName: name)
		#endif
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.gameDetailsCollectionViewController.reviewsSegue.identifier:
			// Segue to reviews list
			guard let reviewsCollectionViewController = segue.destination as? ReviewsCollectionViewController else { return }
			reviewsCollectionViewController.listType = .game(self.game)
		case R.segue.gameDetailsCollectionViewController.castListSegue.identifier:
			// Segue to cast list
			guard let castListCollectionViewController = segue.destination as? CastListCollectionViewController else { return }
			castListCollectionViewController.castKind = .game
			castListCollectionViewController.gameIdentity = self.gameIdentity
		case R.segue.gameDetailsCollectionViewController.gamesListSegue.identifier:
			// Segue to games list
			guard let gamesListCollectionViewController = segue.destination as? GamesListCollectionViewController else { return }
			guard let indexPath = sender as? IndexPath else { return }

			if self.snapshot.sectionIdentifiers[indexPath.section] == .moreByStudio {
				gamesListCollectionViewController.title = "\(Trans.moreBy) \(self.game.attributes.studio ?? Trans.studio)"
				gamesListCollectionViewController.gameIdentity = self.gameIdentity
				gamesListCollectionViewController.gamesListFetchType = .moreByStudio
			} else {
				gamesListCollectionViewController.title = Trans.relatedGames
				gamesListCollectionViewController.gameIdentity = self.gameIdentity
				gamesListCollectionViewController.gamesListFetchType = .relatedGame
			}
		case R.segue.gameDetailsCollectionViewController.showsListSegue.identifier:
			// Segue to shows list
			guard let showsListCollectionViewController = segue.destination as? ShowsListCollectionViewController else { return }
			showsListCollectionViewController.title = Trans.relatedShows
			showsListCollectionViewController.gameIdentity = self.gameIdentity
			showsListCollectionViewController.showsListFetchType = .game
		case R.segue.gameDetailsCollectionViewController.literaturesListSegue.identifier:
			// Segue to literatures list
			guard let literaturesListCollectionViewController = segue.destination as? LiteraturesListCollectionViewController else { return }
			literaturesListCollectionViewController.title = Trans.relatedLiteratures
			literaturesListCollectionViewController.gameIdentity = self.gameIdentity
			literaturesListCollectionViewController.literaturesListFetchType = .game
		case R.segue.gameDetailsCollectionViewController.studiosListSegue.identifier:
			// Segue to studios list
			guard let studiosListCollectionViewController = segue.destination as? StudiosListCollectionViewController else { return }
			studiosListCollectionViewController.gameIdentity = self.gameIdentity
			studiosListCollectionViewController.studiosListFetchType = .game
		case R.segue.gameDetailsCollectionViewController.gameDetailsSegue.identifier:
			// Segue to game details
			guard let gameDetailsCollectionViewController = segue.destination as? GameDetailsCollectionViewController else { return }
			guard let game = sender as? Game else { return }
			gameDetailsCollectionViewController.game = game
		case R.segue.gameDetailsCollectionViewController.showDetailsSegue.identifier:
			// Segue to show details
			guard let showDetailsCollectionViewController = segue.destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailsCollectionViewController.show = show
		case R.segue.gameDetailsCollectionViewController.literatureDetailsSegue.identifier:
			// Segue to literature details
			guard let literatureDetailsCollectionViewController = segue.destination as? LiteratureDetailsCollectionViewController else { return }
			guard let literature = sender as? Literature else { return }
			literatureDetailsCollectionViewController.literature = literature
		case R.segue.gameDetailsCollectionViewController.studioDetailsSegue.identifier:
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
		default: break
		}
	}
}

// MARK: - CastCollectionViewCellDelegate
extension GameDetailsCollectionViewController: CastCollectionViewCellDelegate {
	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressPersonButton button: UIButton) {
		self.performSegue(withIdentifier: R.segue.gameDetailsCollectionViewController.personDetailsSegue.identifier, sender: cell)
	}

	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressCharacterButton button: UIButton) {
		self.performSegue(withIdentifier: R.segue.gameDetailsCollectionViewController.characterDetailsSegue.identifier, sender: cell)
	}
}

// MARK: - TextViewCollectionViewCellDelegate
extension GameDetailsCollectionViewController: TextViewCollectionViewCellDelegate {
	func textViewCollectionViewCell(_ cell: TextViewCollectionViewCell, didPressButton button: UIButton) {
		if let synopsisKNavigationController = R.storyboard.synopsis.instantiateInitialViewController() {
			if let synopsisViewController = synopsisKNavigationController.viewControllers.first as? SynopsisViewController {
				synopsisViewController.title = cell.textViewCollectionViewCellType.stringValue
				synopsisViewController.synopsis = self.game.attributes.synopsis
			}
			synopsisKNavigationController.modalPresentationStyle = .fullScreen
			self.present(synopsisKNavigationController, animated: true)
		}
	}
}

// MARK: - TitleHeaderCollectionReusableViewDelegate
extension GameDetailsCollectionViewController: TitleHeaderCollectionReusableViewDelegate {
	func titleHeaderCollectionReusableView(_ reusableView: TitleHeaderCollectionReusableView, didPress button: UIButton) {
		self.performSegue(withIdentifier: reusableView.segueID, sender: reusableView.indexPath)
	}
}

// MARK: - UIScrollViewDelegate
extension GameDetailsCollectionViewController {
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
extension GameDetailsCollectionViewController: BaseLockupCollectionViewCellDelegate {
	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressReminder button: UIButton) async {}

	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressStatus button: UIButton) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard signedIn else { return }
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		let modelID: String

		switch cell.libraryKind {
		case .shows:
			guard let show = self.relatedShows[safe: indexPath.item]?.show else { return }
			modelID = show.id
		case .literatures:
			guard let literature = self.relatedLiteratures[safe: indexPath.item]?.literature else { return }
			modelID = literature.id
		case .games:
			switch self.dataSource.sectionIdentifier(for: indexPath.section) {
			case .moreByStudio:
				guard let game = self.studioGames[indexPath] else { return }
				modelID = game.id
			case .relatedGames:
				guard let game = self.relatedGames[safe: indexPath.item]?.game else { return }
				modelID = game.id
			default:
				return
			}
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
extension GameDetailsCollectionViewController: ReviewCollectionViewCellDelegate {
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
extension GameDetailsCollectionViewController: TapToRateCollectionViewCellDelegate {
	func tapToRateCollectionViewCell(_ cell: TapToRateCollectionViewCell, rateWith rating: Double) {
		Task { [weak self] in
			guard let self = self else { return }

			do throws(KKAPIError) {
				let rating = try await self.game.rate(using: rating, description: nil)
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
extension GameDetailsCollectionViewController: WriteAReviewCollectionViewCellDelegate {
	func writeAReviewCollectionViewCell(_ cell: WriteAReviewCollectionViewCell, didPress button: UIButton) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard signedIn else { return }

		let reviewTextEditorViewController = ReviewTextEditorViewController()
		reviewTextEditorViewController.delegate = self
		reviewTextEditorViewController.router?.dataStore?.kind = .game(self.game)
		reviewTextEditorViewController.router?.dataStore?.rating = self.game.attributes.library?.rating
		reviewTextEditorViewController.router?.dataStore?.review = nil

		let navigationController = KNavigationController(rootViewController: reviewTextEditorViewController)
		navigationController.presentationController?.delegate = reviewTextEditorViewController
		self.present(navigationController, animated: true)
	}
}

// MARK: - ReviewTextEditorViewControllerDelegate
extension GameDetailsCollectionViewController: ReviewTextEditorViewControllerDelegate {
	func reviewTextEditorViewControllerDidSubmitReview() {
		self.showRatingSuccessAlert()
	}
}

extension GameDetailsCollectionViewController: MediaTransitionDelegate {
	func imageViewForMedia(at index: Int) -> UIImageView? {
		// Find the visible cell for the index and return its thumbnail UIImageView.
		// Example (collectionView):
		guard let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? ShowDetailHeaderCollectionViewCell else {
			return nil
		}
		return cell.posterImageView
	}

	func scrollThumbnailIntoView(for index: Int) {
		// Scroll the collection view to make sure the cell at the given index is visible.
		let indexPath = IndexPath(item: index, section: 0)
		collectionView.safeScrollToItem(at: indexPath, at: .centeredVertically, animated: true)
	}
}

// MARK: - BaseDetailHeaderCollectionViewCellDelegate
extension GameDetailsCollectionViewController: BaseDetailHeaderCollectionViewCellDelegate {
	func baseDetailHeaderCollectionViewCell(_ cell: BaseDetailHeaderCollectionViewCell, didTapImage imageView: UIImageView, at index: Int) {
		let posterURL = URL(string: self.game.attributes.poster?.url ?? "")
		let bannerURL = URL(string: self.game.attributes.banner?.url ?? "")
		var items: [MediaItemV2] = []

		if let posterURL = posterURL {
			items.append(MediaItemV2(
				url: posterURL,
				type: .image,
				title: self.game.attributes.title,
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
				title: self.game.attributes.title,
				description: nil,
				author: nil,
				provider: nil,
				embedHTML: nil,
				extraInfo: nil
			))
		}

		let albumVC = MediaAlbumViewController(items: items, startIndex: index)
		albumVC.transitionDelegateForThumbnail = self

		present(albumVC, animated: true)
	}

	func baseDetailHeaderCollectionViewCell(_ cell: BaseDetailHeaderCollectionViewCell, didPressStatus button: UIButton) async {
		guard await WorkflowController.shared.isSignedIn(), let cell = cell as? ShowDetailHeaderCollectionViewCell else { return }
		let oldLibraryStatus = cell.libraryStatus
		let modelID: String

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

extension GameDetailsCollectionViewController {
	enum SectionLayoutKind: Int, CaseIterable {
		// MARK: - Cases
		/// Indicates a header section layout type.
		case header = 0
		case badge
		case synopsis
		case rating
		case rateAndReview
		case reviews
		case information
		case cast
		case studios
		case moreByStudio
		case relatedGames
		case relatedShows
		case relatedLiteratures
		case sosumi

		// MARK: - Properties
		/// The string value of a game section type.
		var stringValue: String {
			switch self {
			case .header:
				return Trans.header
			case .badge:
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
			case .cast:
				return Trans.cast
			case .studios:
				return Trans.studios
			case .moreByStudio:
				return Trans.moreBy
			case .relatedGames:
				return Trans.relatedGames
			case .relatedShows:
				return Trans.relatedShows
			case .relatedLiteratures:
				return Trans.relatedLiteratures
			case .sosumi:
				return Trans.copyright
			}
		}

		/// The string value of a game section type segue identifier.
		var segueIdentifier: String {
			switch self {
			case .header:
				return ""
			case .badge:
				return ""
			case .synopsis:
				return ""
			case .rating:
				return R.segue.gameDetailsCollectionViewController.reviewsSegue.identifier
			case .rateAndReview:
				return ""
			case .reviews:
				return ""
			case .information:
				return ""
			case .cast:
				return R.segue.gameDetailsCollectionViewController.castListSegue.identifier
			case .studios:
				return R.segue.gameDetailsCollectionViewController.studiosListSegue.identifier
			case .moreByStudio:
				return R.segue.gameDetailsCollectionViewController.gamesListSegue.identifier
			case .relatedGames:
				return R.segue.gameDetailsCollectionViewController.gamesListSegue.identifier
			case .relatedShows:
				return R.segue.gameDetailsCollectionViewController.showsListSegue.identifier
			case .relatedLiteratures:
				return R.segue.gameDetailsCollectionViewController.literaturesListSegue.identifier
			case .sosumi:
				return ""
			}
		}
	}

	/// List of available Item Kind types.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `Game` object.
		case game(_: Game, id: UUID = UUID())

		/// Indicates the item kind contains a `Review` object.
		case review(_: Review, id: UUID = UUID())

		/// Indicates the item kind contains a `GameIdentity` object.
		case gameIdentity(_: GameIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `RelatedGame` object.
		case relatedGame(_: RelatedGame, id: UUID = UUID())

		/// Indicates the item kind contains a `RelatedShow` object.
		case relatedShow(_: RelatedShow, id: UUID = UUID())

		/// Indicates the item kind contains a `RelatedLiterature` object.
		case relatedLiterature(_: RelatedLiterature, id: UUID = UUID())

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
			case .game(let game, let id):
				hasher.combine(game)
				hasher.combine(id)
			case .review(let review, let id):
				hasher.combine(review)
				hasher.combine(id)
			case .gameIdentity(let gameIdentity, let id):
				hasher.combine(gameIdentity)
				hasher.combine(id)
			case .relatedGame(let relatedGame, let id):
				hasher.combine(relatedGame)
				hasher.combine(id)
			case .relatedShow(let relatedShow, let id):
				hasher.combine(relatedShow)
				hasher.combine(id)
			case .relatedLiterature(let relatedLiterature, let id):
				hasher.combine(relatedLiterature)
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
			case (.game(let game1, let id1), .game(let game2, let id2)):
				return game1 == game2 && id1 == id2
			case (.review(let review1, let id1), .review(let review2, let id2)):
				return review1 == review2 && id1 == id2
			case (.gameIdentity(let gameIdentity1, let id1), .gameIdentity(let gameIdentity2, let id2)):
				return gameIdentity1 == gameIdentity2 && id1 == id2
			case (.relatedGame(let relatedGame1, let id1), .relatedGame(let relatedGame2, let id2)):
				return relatedGame1 == relatedGame2 && id1 == id2
			case (.relatedShow(let relatedShow1, let id1), .relatedShow(let relatedShow2, let id2)):
				return relatedShow1 == relatedShow2 && id1 == id2
			case (.relatedLiterature(let relatedLiterature1, let id1), .relatedLiterature(let relatedLiterature2, let id2)):
				return relatedLiterature1 == relatedLiterature2 && id1 == id2
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
