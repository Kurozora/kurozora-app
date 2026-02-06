//
//  StudioDetailsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/06/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class StudioDetailsCollectionViewController: KCollectionViewController, RatingAlertPresentable, SectionFetchable {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case reviewsSegue
		case showDetailsSegue
		case showsListSegue
		case literatureDetailsSegue
		case literaturesListSegue
		case gameDetailsSegue
		case gamesListSegue
		case studioDetailsSegue
	}

	// MARK: - Properties
	var studioIdentity: StudioIdentity?
	var studio: Studio! {
		didSet {
			self.title = self.studio.attributes.name
			self.studioIdentity = StudioIdentity(id: self.studio.id)

			self._prefersActivityIndicatorHidden = true

			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
			#endif
		}
	}

	/// Review properties.
	var reviews: [Review] = []

	/// Show properties.
	var showIdentities: [ShowIdentity] = []

	/// Literature properties.
	var literatureIdentities: [LiteratureIdentity] = []

	/// Game properties.
	var gameIdentities: [GameIdentity] = []

	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>! = nil
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>! = nil

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
		return _prefersActivityIndicatorHidden
	}

	// MARK: - Initializers
	/// Initialize a new instance of StudioDetailsCollectionViewController with the given studio id.
	///
	/// - Parameter studioID: The studio id to use when initializing the view.
	///
	/// - Returns: an initialized instance of StudioDetailsCollectionViewController.
	func callAsFunction(with studioID: KurozoraItemID) -> StudioDetailsCollectionViewController {
		let studioDetailsCollectionViewController = StudioDetailsCollectionViewController()
		studioDetailsCollectionViewController.studioIdentity = StudioIdentity(id: studioID)
		return studioDetailsCollectionViewController
	}

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		self.handleRefreshControl()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		self.configureDataSource()

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchDetails()
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(self, selector: #selector(self.deleteReview(_:)), name: .KReviewDidDelete, object: nil)
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		NotificationCenter.default.removeObserver(self, name: .KReviewDidDelete, object: nil)
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchDetails()
		}
	}

	override func configureEmptyDataView() {
		emptyBackgroundView.configureImageView(image: .Empty.cast)
		emptyBackgroundView.configureLabels(title: "No Details", detail: "This studio doesn't have details yet. Please check back again later.")

		collectionView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of rows.
	func toggleEmptyDataView() {
		if self.collectionView.numberOfItems == 0 {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	/// Fetches the currently viewed studio's details.
	func fetchDetails() async {
		guard let studioIdentity = self.studioIdentity else { return }

		if self.studio == nil {
			do {
				let studioResponse = try await KService.getDetails(forStudio: studioIdentity).value
				self.studio = studioResponse.data.first
			} catch {
				print(error.localizedDescription)
			}
		} else {
			self.updateDataSource()
		}

		do {
			let reviewIdentityResponse = try await KService.getReviews(forStudio: studioIdentity, next: nil, limit: 10).value
			self.reviews = reviewIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let showIdentityResponse = try await KService.getShows(forStudio: studioIdentity, limit: 10).value
			self.showIdentities = showIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let literatureIdentityResponse = try await KService.getLiteratures(forStudio: studioIdentity, limit: 10).value
			self.literatureIdentities = literatureIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let gameIdentityResponse = try await KService.getGames(forStudio: studioIdentity, limit: 10).value
			self.gameIdentities = gameIdentityResponse.data
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

			self.studio.attributes.library?.rating = nil
			self.studio.attributes.library?.review = nil

			self.updateDataSource()
		}
	}

	// MARK: - SectionFetchable
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .gameIdentity(let id, _): return id as? Element
		case .literatureIdentity(let id, _): return id as? Element
		case .showIdentity(let id, _): return id as? Element
		default: return nil
		}
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .reviewsSegue: return ReviewsCollectionViewController()
		case .showsListSegue: return ShowsListCollectionViewController()
		case .literaturesListSegue: return LiteraturesListCollectionViewController()
		case .gamesListSegue: return GamesListCollectionViewController()
		case .showDetailsSegue: return ShowDetailsCollectionViewController()
		case .literatureDetailsSegue: return LiteratureDetailsCollectionViewController()
		case .gameDetailsSegue: return GameDetailsCollectionViewController()
		case .studioDetailsSegue: return StudioDetailsCollectionViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .reviewsSegue:
			// Segue to reviews list
			guard let reviewsCollectionViewController = destination as? ReviewsCollectionViewController else { return }
			reviewsCollectionViewController.listType = .studio(self.studio)
		case .showDetailsSegue:
			guard let showDetailsCollectionViewController = destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailsCollectionViewController.show = show
		case .showsListSegue:
			guard let showsListCollectionViewController = destination as? ShowsListCollectionViewController else { return }
			showsListCollectionViewController.studioIdentity = self.studioIdentity
			showsListCollectionViewController.showsListFetchType = .studio
		case .literatureDetailsSegue:
			guard let literatureDetailCollectionViewController = destination as? LiteratureDetailsCollectionViewController else { return }
			guard let literature = sender as? Literature else { return }
			literatureDetailCollectionViewController.literature = literature
		case .literaturesListSegue:
			guard let literaturesListCollectionViewController = destination as? LiteraturesListCollectionViewController else { return }
			literaturesListCollectionViewController.studioIdentity = self.studioIdentity
			literaturesListCollectionViewController.literaturesListFetchType = .studio
		case .gameDetailsSegue:
			guard let gameDetailCollectionViewController = destination as? GameDetailsCollectionViewController else { return }
			guard let game = sender as? Game else { return }
			gameDetailCollectionViewController.game = game
		case .gamesListSegue:
			guard let gamesListCollectionViewController = destination as? GamesListCollectionViewController else { return }
			gamesListCollectionViewController.studioIdentity = self.studioIdentity
			gamesListCollectionViewController.gamesListFetchType = .studio
		case .studioDetailsSegue:
			return
		}
	}
}

// MARK: - UICollectionViewDataSource
extension StudioDetailsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let studioDetailSection = self.snapshot.sectionIdentifiers[indexPath.section]
		let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
		titleHeaderCollectionReusableView.delegate = self
		titleHeaderCollectionReusableView.configure(withTitle: studioDetailSection.stringValue, indexPath: indexPath, segueID: studioDetailSection.segueIdentifier)
		return titleHeaderCollectionReusableView
	}
}

// MARK: - TextViewCollectionViewCellDelegate
extension StudioDetailsCollectionViewController: TextViewCollectionViewCellDelegate {
	func textViewCollectionViewCell(_ cell: TextViewCollectionViewCell, didPressButton button: UIButton) {
		let synopsisViewController = SynopsisViewController()
		synopsisViewController.title = cell.textViewCollectionViewCellType.stringValue
		synopsisViewController.synopsis = self.studio.attributes.about

		let kNavigationController = KNavigationController(rootViewController: synopsisViewController)
		kNavigationController.modalPresentationStyle = .formSheet

		self.present(kNavigationController, animated: true)
	}
}

// MARK: - TitleHeaderCollectionReusableViewDelegate
extension StudioDetailsCollectionViewController: TitleHeaderCollectionReusableViewDelegate {
	func titleHeaderCollectionReusableView(_ reusableView: TitleHeaderCollectionReusableView, didPress button: UIButton) {
		guard let segueID = reusableView.segueID else { return }
		self.show(segueID, sender: reusableView.indexPath)
	}
}

// MARK: - BaseLockupCollectionViewCellDelegate
extension StudioDetailsCollectionViewController: BaseLockupCollectionViewCellDelegate {
	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressStatus button: UIButton) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard signedIn else { return }
		guard
			let indexPath = self.collectionView.indexPath(for: cell),
			let model = self.cache[indexPath]
		else { return }
		let modelID: KurozoraItemID = model.id

		let oldLibraryStatus = cell.libraryStatus
		let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: KKLibrary.Status.alertControllerItems(for: cell.libraryKind), currentSelection: oldLibraryStatus, action: { title, value  in
			Task {
				do {
					let libraryUpdateResponse = try await KService.addToLibrary(cell.libraryKind, withLibraryStatus: value, modelID: modelID).value

					switch cell.libraryKind {
					case .shows:
						guard let show = self.cache[indexPath] as? Show else { return }
						show.attributes.library?.update(using: libraryUpdateResponse.data)
					case .literatures:
						guard let literature = self.cache[indexPath] as? Literature else { return }
						literature.attributes.library?.update(using: libraryUpdateResponse.data)
					case .games:
						guard let game = self.cache[indexPath] as? Game else { return }
						game.attributes.library?.update(using: libraryUpdateResponse.data)
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
			actionSheetAlertController.addAction(UIAlertAction(title: Trans.removeFromLibrary, style: .destructive) { _ in
				Task {
					do {
						let libraryUpdateResponse = try await KService.removeFromLibrary(cell.libraryKind, modelID: modelID).value

						switch cell.libraryKind {
						case .shows:
							guard let show = self.cache[indexPath] as? Show else { return }
							show.attributes.library?.update(using: libraryUpdateResponse.data)
						case .literatures:
							guard let literature = self.cache[indexPath] as? Literature else { return }
							literature.attributes.library?.update(using: libraryUpdateResponse.data)
						case .games:
							guard let game = self.cache[indexPath] as? Game else { return }
							game.attributes.library?.update(using: libraryUpdateResponse.data)
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
			})
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
		guard
			let indexPath = self.collectionView.indexPath(for: cell),
			let show = self.cache[indexPath] as? Show
		else { return }
		await show.toggleReminder(on: self)
		cell.configureReminderButton(for: show.attributes.library?.reminderStatus)
	}
}

// MARK: - ReviewCollectionViewCellDelegate
extension StudioDetailsCollectionViewController: ReviewCollectionViewCellDelegate {
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
extension StudioDetailsCollectionViewController: TapToRateCollectionViewCellDelegate {
	func tapToRateCollectionViewCell(_ cell: TapToRateCollectionViewCell, rateWith rating: Double) {
		Task { [weak self] in
			guard let self = self else { return }

			do throws(KKAPIError) {
				let rating = try await self.studio.rate(using: rating, description: nil)
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
extension StudioDetailsCollectionViewController: WriteAReviewCollectionViewCellDelegate {
	func writeAReviewCollectionViewCell(_ cell: WriteAReviewCollectionViewCell, didPress button: UIButton) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard signedIn else { return }

		let reviewTextEditorViewController = ReviewTextEditorViewController()
		reviewTextEditorViewController.delegate = self
		reviewTextEditorViewController.router?.dataStore?.kind = .studio(self.studio)
		reviewTextEditorViewController.router?.dataStore?.rating = self.studio.attributes.library?.rating
		reviewTextEditorViewController.router?.dataStore?.review = self.studio.attributes.library?.review

		let navigationController = KNavigationController(rootViewController: reviewTextEditorViewController)
		navigationController.presentationController?.delegate = reviewTextEditorViewController
		self.present(navigationController, animated: true)
	}
}

// MARK: - ReviewTextEditorViewControllerDelegate
extension StudioDetailsCollectionViewController: ReviewTextEditorViewControllerDelegate {
	func reviewTextEditorViewControllerDidSubmitReview() {
		self.showRatingSuccessAlert()
	}
}

extension StudioDetailsCollectionViewController {
	enum SectionLayoutKind: Int, CaseIterable {
		// MARK: - Cases
		/// Indicates a header section layout type.
		case header = 0

		/// Indicates badges section layout type.
		case badges

		/// Indicates an about section layout type.
		case about

		/// Indicates rating section layout type.
		case rating

		/// Indicates rate and review section layout type.
		case rateAndReview

		/// Indicates reviews section layout type.
		case reviews

		/// Indicates an information section layout type.
		case information

		/// Indicates shows section layout type.
		case shows

		/// Indicates literatures section layout type.
		case literatures

		/// Indicates games section layout type.
		case games

		// MARK: - Properties
		/// The string value of a studio section type.
		var stringValue: String {
			switch self {
			case .header:
				return Trans.header
			case .badges:
				return Trans.badges
			case .about:
				return Trans.about
			case .rating:
				return Trans.ratingsAndReviews
			case .rateAndReview:
				return ""
			case .reviews:
				return ""
			case .information:
				return Trans.information
			case .shows:
				return Trans.shows
			case .literatures:
				return Trans.literatures
			case .games:
				return Trans.games
			}
		}

		/// The string value of a studio section type segue identifier.
		var segueIdentifier: SegueIdentifiers? {
			switch self {
			case .header, .badges, .about, .rateAndReview, .reviews, .information:
				return nil
			case .rating:
				return .reviewsSegue
			case .shows:
				return .showsListSegue
			case .literatures:
				return .literaturesListSegue
			case .games:
				return .gamesListSegue
			}
		}
	}

	/// List of available Item Kind types.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `Studio` object.
		case studio(_: Studio, id: UUID = UUID())

		/// Indicates the item kind contains a `Review` object.
		case review(_: Review, id: UUID = UUID())

		/// Indicates the item kind contains a `ShowIdentity` object.
		case showIdentity(_: ShowIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `LiteratureIdentity` object.
		case literatureIdentity(_: LiteratureIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `GameIdentity` object.
		case gameIdentity(_: GameIdentity, id: UUID = UUID())

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .studio(let studio, let id):
				hasher.combine(studio)
				hasher.combine(id)
			case .review(let review, let id):
				hasher.combine(review)
				hasher.combine(id)
			case .showIdentity(let showIdentity, let id):
				hasher.combine(showIdentity)
				hasher.combine(id)
			case .literatureIdentity(let literatureIdentity, let id):
				hasher.combine(literatureIdentity)
				hasher.combine(id)
			case .gameIdentity(let gameIdentity, let id):
				hasher.combine(gameIdentity)
				hasher.combine(id)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.studio(let studio1, let id1), .studio(let studio2, let id2)):
				return studio1 == studio2 && id1 == id2
			case (.review(let review1, let id1), .review(let review2, let id2)):
				return review1 == review2 && id1 == id2
			case (.showIdentity(let showIdentity1, let id1), .showIdentity(let showIdentity2, let id2)):
				return showIdentity1 == showIdentity2 && id1 == id2
			case (.literatureIdentity(let literatureIdentity1, let id1), .literatureIdentity(let literatureIdentity2, let id2)):
				return literatureIdentity1 == literatureIdentity2 && id1 == id2
			case (.gameIdentity(let gameIdentity1, let id1), .gameIdentity(let gameIdentity2, let id2)):
				return gameIdentity1 == gameIdentity2 && id1 == id2
			default:
				return false
			}
		}
	}
}

// MARK: - Cell Configuration
extension StudioDetailsCollectionViewController {
	func getConfiguredSmallCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind> {
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
			case .literatureIdentity:
				let literature: Literature? = self.fetchModel(at: indexPath)

				if literature == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
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
}
