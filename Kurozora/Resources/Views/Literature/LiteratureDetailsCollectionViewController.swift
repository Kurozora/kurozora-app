//
//  LiteratureDetailsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/02/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import AVFoundation
import Intents
import IntentsUI
import KurozoraKit
import UIKit

class LiteratureDetailsCollectionViewController: KCollectionViewController, RatingAlertPresentable, StoryboardInstantiable {
	static var storyboardName: String = "Literatures"

	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case reviewsSegue
		case castListSegue
		case literaturesListSegue
		case showsListSegue
		case gamesListSegue
		case studiosListSegue
		case literatureDetailsSegue
		case showDetailsSegue
		case gameDetailsSegue
		case studioDetailsSegue
		case characterDetailsSegue
		case personDetailsSegue
	}

	// MARK: - IBOutlets
	@IBOutlet var moreBarButtonItem: UIBarButtonItem!
	@IBOutlet var navigationTitleView: UIView!
	@IBOutlet var navigationTitleLabel: UILabel! {
		didSet {
			self.navigationTitleLabel.theme_textColor = KThemePicker.barTitleTextColor.rawValue
		}
	}

	// MARK: - Properties
	var literatureIdentity: LiteratureIdentity?
	var literature: Literature! {
		didSet {
			self.title = self.literature.attributes.title
			self.navigationTitleLabel.text = self.literature.attributes.title
			self.literatureIdentity = LiteratureIdentity(id: self.literature.id)

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

	/// Related Literature properties.
	var relatedLiteratures: [RelatedLiterature] = []

	/// Related Show properties.
	var relatedShows: [RelatedShow] = []

	/// Related Game properties.
	var relatedGames: [RelatedGame] = []

	/// Cast properties.
	var castIdentities: [CastIdentity] = []

	/// Studio properties.
	var studioIdentities: [StudioIdentity] = []
//	var studio: Studio!
	var studioLiteratureIdentities: [LiteratureIdentity] = []

	var cache: [IndexPath: KurozoraItem] = [:]
	private var isFetchingSection: Set<SectionLayoutKind> = []

	/// The first cell's size.
	private var firstCellSize: CGSize = .zero

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	// Touch Bar
	#if targetEnvironment(macCatalyst)
	var toggleLiteratureIsFavoriteTouchBarItem: NSButtonTouchBarItem?
	var toggleLiteratureIsRemindedTouchBarItem: NSButtonTouchBarItem?
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
	/// Initialize a new instance of LiteratureDetailsCollectionViewController with the given literature id.
	///
	/// - Parameter literatureID: The literature id to use when initializing the view.
	///
	/// - Returns: an initialized instance of LiteratureDetailsCollectionViewController.
	func callAsFunction(with literatureID: KurozoraItemID) -> LiteratureDetailsCollectionViewController {
		let literatureDetailsCollectionViewController = LiteratureDetailsCollectionViewController.instantiate()
		literatureDetailsCollectionViewController.literatureIdentity = LiteratureIdentity(id: literatureID)
		return literatureDetailsCollectionViewController
	}

	/// Initialize a new instance of LiteratureDetailsCollectionViewController with the given literature object.
	///
	/// - Parameter literature: The `Literature` object to use when initializing the view controller.
	///
	/// - Returns: an initialized instance of LiteratureDetailsCollectionViewController.
	func callAsFunction(with literature: Literature) -> LiteratureDetailsCollectionViewController {
		let literatureDetailsCollectionViewController = LiteratureDetailsCollectionViewController.instantiate()
		literatureDetailsCollectionViewController.literature = literature
		return literatureDetailsCollectionViewController
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

		// Fetch literature details.
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
		self.emptyBackgroundView.configureImageView(image: .Empty.mangaLibrary)
		self.emptyBackgroundView.configureLabels(title: "No Details", detail: "This literature doesn't have details yet. Please check back again later.")

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
		self.moreBarButtonItem.menu = self.literature?.makeContextMenu(in: self, userInfo: [:], sourceView: nil, barButtonItem: self.moreBarButtonItem)
	}

	/// Fetches details for the given literature identity. If none given then the currently viewed literature's details are fetched.
	func fetchDetails() async {
		guard let literatureIdentity = self.literatureIdentity else { return }

		if self.literature == nil {
			do {
				let literatureResponse = try await KService.getDetails(forLiterature: literatureIdentity).value
				self.literature = literatureResponse.data.first

				// Donate suggestion to Siri
				self.userActivity = self.literature.openDetailUserActivity
			} catch {
				print(error.localizedDescription)
			}

			self.configureNavBarButtons()
		} else {
			// Donate suggestion to Siri
			self.userActivity = self.literature.openDetailUserActivity

			self.updateDataSource()
			self.configureNavBarButtons()
		}

		do {
			let reviewIdentityResponse = try await KService.getReviews(forLiterature: literatureIdentity, next: nil, limit: 10).value
			self.reviews = reviewIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let castIdentityResponse = try await KService.getCast(forLiterature: literatureIdentity, limit: 10).value
			self.castIdentities = castIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let studioIdentityResponse = try await KService.getStudios(forLiterature: literatureIdentity, limit: 10).value
			self.studioIdentities = studioIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let literatureIdentityResponse = try await KService.getMoreByStudio(forLiterature: literatureIdentity, limit: 10).value
			self.studioLiteratureIdentities = literatureIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let relatedLiteratureResponse = try await KService.getRelatedLiteratures(forLiterature: literatureIdentity, limit: 10).value
			self.relatedLiteratures = relatedLiteratureResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let relatedShowResponse = try await KService.getRelatedShows(forLiterature: literatureIdentity, limit: 10).value
			self.relatedShows = relatedShowResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let relatedGameResponse = try await KService.getRelatedGames(forLiterature: literatureIdentity, limit: 10).value
			self.relatedGames = relatedGameResponse.data
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

			self.literature.attributes.library?.rating = nil
			self.literature.attributes.library?.review = nil

			self.updateDataSource()
		}
	}

	@objc func toggleFavorite() {
		Task {
			await self.literature?.toggleFavorite()
		}
	}

	@objc func toggleReminder() {
//		self.literature?.toggleReminder()
	}

	@objc func handleFavoriteToggle(_ notification: NSNotification) {
		#if targetEnvironment(macCatalyst)
		let name = self.literature.attributes.library?.favoriteStatus == .favorited ? "heart.fill" : "heart"
		self.toggleLiteratureIsFavoriteTouchBarItem?.image = UIImage(systemName: name)
		#endif
	}

	@objc func handleReminderToggle(_ notification: NSNotification) {
		#if targetEnvironment(macCatalyst)
		let name = self.literature.attributes.library?.reminderStatus == .reminded ? "bell.fill" : "bell"
		self.toggleLiteratureIsRemindedTouchBarItem?.image = UIImage(systemName: name)
		#endif
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard
			let segueIdentifier = segue.identifier,
			let segueID = SegueIdentifiers(rawValue: segueIdentifier)
		else { return }

		switch segueID {
		case .reviewsSegue:
			// Segue to reviews list
			guard let reviewsCollectionViewController = segue.destination as? ReviewsCollectionViewController else { return }
			reviewsCollectionViewController.listType = .literature(self.literature)
		case .castListSegue:
			// Segue to cast list
			guard let castListCollectionViewController = segue.destination as? CastListCollectionViewController else { return }
			castListCollectionViewController.castKind = .literature
			castListCollectionViewController.literatureIdentity = self.literatureIdentity
		case .literaturesListSegue:
			// Segue to literatures list
			guard let literaturesListCollectionViewController = segue.destination as? LiteraturesListCollectionViewController else { return }
			guard let indexPath = sender as? IndexPath else { return }

			if self.snapshot.sectionIdentifiers[indexPath.section] == .moreByStudio {
				literaturesListCollectionViewController.title = "\(Trans.moreBy) \(self.literature.attributes.studio ?? Trans.studio)"
				literaturesListCollectionViewController.literatureIdentity = self.literatureIdentity
				literaturesListCollectionViewController.literaturesListFetchType = .moreByStudio
			} else {
				literaturesListCollectionViewController.title = Trans.relatedLiteratures
				literaturesListCollectionViewController.literatureIdentity = self.literatureIdentity
				literaturesListCollectionViewController.literaturesListFetchType = .relatedLiterature
			}
		case .showsListSegue:
			// Segue to shows list
			guard let showsListCollectionViewController = segue.destination as? ShowsListCollectionViewController else { return }
			showsListCollectionViewController.title = Trans.relatedShows
			showsListCollectionViewController.literatureIdentity = self.literatureIdentity
			showsListCollectionViewController.showsListFetchType = .literature
		case .gamesListSegue:
			// Segue to games list
			guard let gamesListCollectionViewController = segue.destination as? GamesListCollectionViewController else { return }
			gamesListCollectionViewController.title = Trans.relatedGames
			gamesListCollectionViewController.literatureIdentity = self.literatureIdentity
			gamesListCollectionViewController.gamesListFetchType = .literature
		case .studiosListSegue:
			// Segue to studios list
			guard let studiosListCollectionViewController = segue.destination as? StudiosListCollectionViewController else { return }
			studiosListCollectionViewController.literatureIdentity = self.literatureIdentity
			studiosListCollectionViewController.studiosListFetchType = .literature
		case .literatureDetailsSegue:
			// Segue to literature details
			guard let literatureDetailsCollectionViewController = segue.destination as? LiteratureDetailsCollectionViewController else { return }
			guard let literature = sender as? Literature else { return }
			literatureDetailsCollectionViewController.literature = literature
		case .showDetailsSegue:
			// Segue to show details
			guard let showDetailsCollectionViewController = segue.destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailsCollectionViewController.show = show
		case .gameDetailsSegue:
			// Segue to game details
			guard let gameDetailsCollectionViewController = segue.destination as? GameDetailsCollectionViewController else { return }
			guard let game = sender as? Game else { return }
			gameDetailsCollectionViewController.game = game
		case .studioDetailsSegue:
			// Segue to studio details
			guard let studioDetailsCollectionViewController = segue.destination as? StudioDetailsCollectionViewController else { return }
			guard let studio = sender as? Studio else { return }
			studioDetailsCollectionViewController.studio = studio
		case .characterDetailsSegue:
			// Segue to character details
			guard let characterDetailsCollectionViewController = segue.destination as? CharacterDetailsCollectionViewController else { return }
			guard let character = sender as? Character else { return }
			characterDetailsCollectionViewController.character = character
		case .personDetailsSegue:
			// Segue to person details
			guard let personDetailsCollectionViewController = segue.destination as? PersonDetailsCollectionViewController else { return }
			guard let person = sender as? Person else { return }
			personDetailsCollectionViewController.person = person
		}
	}
}

// MARK: - CastCollectionViewCellDelegate
extension LiteratureDetailsCollectionViewController: CastCollectionViewCellDelegate {
	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressPersonButton button: UIButton) {
		self.performSegue(withIdentifier: SegueIdentifiers.personDetailsSegue, sender: cell)
	}

	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressCharacterButton button: UIButton) {
		self.performSegue(withIdentifier: SegueIdentifiers.characterDetailsSegue, sender: cell)
	}
}

// MARK: - TextViewCollectionViewCellDelegate
extension LiteratureDetailsCollectionViewController: TextViewCollectionViewCellDelegate {
	func textViewCollectionViewCell(_ cell: TextViewCollectionViewCell, didPressButton button: UIButton) {
		let synopsisViewController = SynopsisViewController.instantiate()
		synopsisViewController.title = cell.textViewCollectionViewCellType.stringValue
		synopsisViewController.synopsis = self.literature.attributes.synopsis

		let kNavigationController = KNavigationController(rootViewController: synopsisViewController)
		kNavigationController.modalPresentationStyle = .fullScreen

		self.present(kNavigationController, animated: true)
	}
}

// MARK: - TitleHeaderCollectionReusableViewDelegate
extension LiteratureDetailsCollectionViewController: TitleHeaderCollectionReusableViewDelegate {
	func titleHeaderCollectionReusableView(_ reusableView: TitleHeaderCollectionReusableView, didPress button: UIButton) {
		guard let segueID = reusableView.segueID else { return }
		self.performSegue(withIdentifier: segueID, sender: reusableView.indexPath)
	}
}

// MARK: - UIScrollViewDelegate
extension LiteratureDetailsCollectionViewController {
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
extension LiteratureDetailsCollectionViewController: BaseLockupCollectionViewCellDelegate {
	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressReminder button: UIButton) {}

	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressStatus button: UIButton) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard signedIn else { return }
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		let modelID: KurozoraItemID

		switch cell.libraryKind {
		case .shows:
			guard let show = self.relatedShows[safe: indexPath.item]?.show else { return }
			modelID = show.id
		case .literatures:
			switch self.dataSource.sectionIdentifier(for: indexPath.section) {
			case .moreByStudio:
				guard let literature = self.cache[indexPath] as? Literature else { return }
				modelID = literature.id
			case .relatedLiteratures:
				guard let literature = self.relatedLiteratures[safe: indexPath.item]?.literature else { return }
				modelID = literature.id
			default:
				return
			}
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
extension LiteratureDetailsCollectionViewController: ReviewCollectionViewCellDelegate {
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
extension LiteratureDetailsCollectionViewController: TapToRateCollectionViewCellDelegate {
	func tapToRateCollectionViewCell(_ cell: TapToRateCollectionViewCell, rateWith rating: Double) {
		Task { [weak self] in
			guard let self = self else { return }

			do throws(KKAPIError) {
				let rating = try await self.literature.rate(using: rating, description: nil)
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
extension LiteratureDetailsCollectionViewController: WriteAReviewCollectionViewCellDelegate {
	func writeAReviewCollectionViewCell(_ cell: WriteAReviewCollectionViewCell, didPress button: UIButton) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard signedIn else { return }

		let reviewTextEditorViewController = ReviewTextEditorViewController()
		reviewTextEditorViewController.delegate = self
		reviewTextEditorViewController.router?.dataStore?.kind = .literature(self.literature)
		reviewTextEditorViewController.router?.dataStore?.rating = self.literature.attributes.library?.rating
		reviewTextEditorViewController.router?.dataStore?.review = nil

		let navigationController = KNavigationController(rootViewController: reviewTextEditorViewController)
		navigationController.presentationController?.delegate = reviewTextEditorViewController
		self.present(navigationController, animated: true)
	}
}

// MARK: - ReviewTextEditorViewControllerDelegate
extension LiteratureDetailsCollectionViewController: ReviewTextEditorViewControllerDelegate {
	func reviewTextEditorViewControllerDidSubmitReview() {
		self.showRatingSuccessAlert()
	}
}

extension LiteratureDetailsCollectionViewController: MediaTransitionDelegate {
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
extension LiteratureDetailsCollectionViewController: BaseDetailHeaderCollectionViewCellDelegate {
	func baseDetailHeaderCollectionViewCell(_ cell: BaseDetailHeaderCollectionViewCell, didTapImage imageView: UIImageView, at index: Int) {
		let posterURL = URL(string: self.literature.attributes.poster?.url ?? "")
		let bannerURL = URL(string: self.literature.attributes.banner?.url ?? "")
		var items: [MediaItemV2] = []

		if let posterURL = posterURL {
			items.append(MediaItemV2(
				url: posterURL,
				type: .image,
				title: self.literature.attributes.title,
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
				title: self.literature.attributes.title,
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

extension LiteratureDetailsCollectionViewController {
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
		case relatedLiteratures
		case relatedShows
		case relatedGames
		case sosumi

		// MARK: - Properties
		/// The string value of a literature section type.
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
			case .relatedLiteratures:
				return Trans.relatedLiteratures
			case .relatedShows:
				return Trans.relatedShows
			case .relatedGames:
				return Trans.relatedGames
			case .sosumi:
				return Trans.copyright
			}
		}

		/// The string value of a literature section type segue identifier.
		var segueIdentifier: SegueIdentifiers? {
			switch self {
			case .header, .badge, .synopsis, .rateAndReview, .reviews, .information, .sosumi:
				return nil
			case .rating:
				return .reviewsSegue
			case .cast:
				return .castListSegue
			case .studios:
				return .studiosListSegue
			case .moreByStudio:
				return .literaturesListSegue
			case .relatedLiteratures:
				return .literaturesListSegue
			case .relatedShows:
				return .showsListSegue
			case .relatedGames:
				return .gamesListSegue
			}
		}
	}

	/// List of available Item Kind types.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `Literature` object.
		case literature(_: Literature, id: UUID = UUID())

		/// Indicates the item kind contains a `Review` object.
		case review(_: Review, id: UUID = UUID())

		/// Indicates the item kind contains a `LiteratureIdentity` object.
		case literatureIdentity(_: LiteratureIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `RelatedLiterature` object.
		case relatedLiterature(_: RelatedLiterature, id: UUID = UUID())

		/// Indicates the item kind contains a `RelatedShow` object.
		case relatedShow(_: RelatedShow, id: UUID = UUID())

		/// Indicates the item kind contains a `RelatedGame` object.
		case relatedGame(_: RelatedGame, id: UUID = UUID())

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
			case .literature(let literature, let id):
				hasher.combine(literature)
				hasher.combine(id)
			case .review(let review, let id):
				hasher.combine(review)
				hasher.combine(id)
			case .literatureIdentity(let literatureIdentity, let id):
				hasher.combine(literatureIdentity)
				hasher.combine(id)
			case .relatedLiterature(let relatedLiterature, let id):
				hasher.combine(relatedLiterature)
				hasher.combine(id)
			case .relatedShow(let relatedShow, let id):
				hasher.combine(relatedShow)
				hasher.combine(id)
			case .relatedGame(let relatedGame, let id):
				hasher.combine(relatedGame)
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
			case (.literature(let literature1, let id1), .literature(let literature2, let id2)):
				return literature1 == literature2 && id1 == id2
			case (.review(let review1, let id1), .review(let review2, let id2)):
				return review1 == review2 && id1 == id2
			case (.literatureIdentity(let literatureIdentity1, let id1), .literatureIdentity(let literatureIdentity2, let id2)):
				return literatureIdentity1 == literatureIdentity2 && id1 == id2
			case (.relatedLiterature(let relatedLiterature1, let id1), .relatedLiterature(let relatedLiterature2, let id2)):
				return relatedLiterature1 == relatedLiterature2 && id1 == id2
			case (.relatedShow(let relatedShow1, let id1), .relatedShow(let relatedShow2, let id2)):
				return relatedShow1 == relatedShow2 && id1 == id2
			case (.relatedGame(let relatedGame1, let id1), .relatedGame(let relatedGame2, let id2)):
				return relatedGame1 == relatedGame2 && id1 == id2
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
extension LiteratureDetailsCollectionViewController {
	func getConfiguredCastCell() -> UICollectionView.CellRegistration<CharacterLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<CharacterLockupCollectionViewCell, ItemKind>(cellNib: CharacterLockupCollectionViewCell.nib) { [weak self] characterLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .castIdentity:
				let cast: Cast? = self.fetchModel(at: indexPath)

				if cast == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(CastResponse.self, CastIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				characterLockupCollectionViewCell.configure(using: cast?.relationships.characters.data.first, role: cast?.attributes.role)
			default: return
			}
		}
	}

	func getConfiguredStudioLiteratureCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: SmallLockupCollectionViewCell.nib) { [weak self] smallLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .literatureIdentity:
				let literature: Literature? = self.fetchModel(at: indexPath)

				if literature == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(LiteratureResponse.self, LiteratureIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.configure(using: literature)
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

	func getConfiguredRelatedLiteratureCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: SmallLockupCollectionViewCell.nib) { smallLockupCollectionViewCell, _, itemKind in
			smallLockupCollectionViewCell.delegate = self

			switch itemKind {
			case .relatedLiterature(let relatedLiterature, _):
				smallLockupCollectionViewCell.configure(using: relatedLiterature)
			case .relatedShow(let relatedShow, _):
				smallLockupCollectionViewCell.configure(using: relatedShow)
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

	/// Generic helper to fetch all items in a section if not yet cached.
	func fetchSectionIfNeeded<I: KurozoraRequestable, Element: KurozoraItem>(
		_ response: I.Type,
		_ item: Element.Type,
		at indexPath: IndexPath,
		itemKind: ItemKind
	) async {
		guard
			self.cache[indexPath] == nil,
			let section = self.snapshot.sectionIdentifier(containingItem: itemKind),
			!self.isFetchingSection.contains(section)
		else { return }

		self.isFetchingSection.insert(section)

		// Extract all identities in this section
		let identities: [Element] = self.snapshot
			.itemIdentifiers(inSection: section)
			.compactMap {
				switch $0 {
				case .castIdentity(let id, _): return id as? Element
				case .characterIdentity(let id, _): return id as? Element
				case .literatureIdentity(let id, _): return id as? Element
				case .personIdentity(let id, _): return id as? Element
				case .studioIdentity(let id, _): return id as? Element
				default: return nil
				}
			}

		defer { self.isFetchingSection.remove(section) }

		do {
			let data: I = try await KService.getDetails(for: identities).value

			// Maintain order based on identities array
			let orderLookup = Dictionary(uniqueKeysWithValues: identities.enumerated().map { ($1.id, $0) })
			let sorted = data.data.sorted {
				guard
					let lhsIndex = orderLookup[$0.id],
					let rhsIndex = orderLookup[$1.id]
				else { return false }
				return lhsIndex < rhsIndex
			}

			// Cache results in section order
			for (index, model) in sorted.enumerated() {
				let ip = IndexPath(item: index, section: indexPath.section)
				self.cache[ip] = model
			}

			self.setSectionNeedsUpdate(section)
		} catch {
			print("Fetch error for section \(section): \(error)", error.localizedDescription)
		}
	}
}
