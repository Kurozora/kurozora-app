//
//  StudioDetailsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/06/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Alamofire

class StudioDetailsCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var studioIdentity: StudioIdentity? = nil
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
	var shows: [IndexPath: Show] = [:]
	var showIdentities: [ShowIdentity] = []

	/// Literature properties.
	var literatures: [IndexPath: Literature] = [:]
	var literatureIdentities: [LiteratureIdentity] = []

	/// Game properties.
	var games: [IndexPath: Game] = [:]
	var gameIdentities: [GameIdentity] = []

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>! = nil
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>! = nil
	var prefetchingIndexPathOperations: [IndexPath: DataRequest] = [:]

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
	static func `init`(with studioID: String) -> StudioDetailsCollectionViewController {
		if let studioDetailsCollectionViewController = R.storyboard.studios.studioDetailsCollectionViewController() {
			studioDetailsCollectionViewController.studioIdentity = StudioIdentity(id: studioID)
			return studioDetailsCollectionViewController
		}

		fatalError("Failed to instantiate StudioDetailsCollectionViewController with the given studio id.")
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

	// MARK: - Functions
	override func handleRefreshControl() {
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchDetails()
		}
	}

	override func configureEmptyDataView() {
		emptyBackgroundView.configureImageView(image: R.image.empty.cast()!)
		emptyBackgroundView.configureLabels(title: "No Details", detail: "This studio doesn't have details yet. Please check back again later.")

		collectionView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of rows.
	func toggleEmptyDataView() {
		if self.collectionView.numberOfItems() == 0 {
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

	/// Show a success alert thanking the user for rating.
	private func showRatingSuccessAlert() {
		let alertController = UIApplication.topViewController?.presentAlertController(title: Trans.ratingSubmitted, message: Trans.thankYouForRating)

		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
			alertController?.dismiss(animated: true, completion: nil)
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.studioDetailsCollectionViewController.showDetailsSegue.identifier:
			guard let showDetailsCollectionViewController = segue.destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailsCollectionViewController.show = show
		case R.segue.studioDetailsCollectionViewController.showsListSegue.identifier:
			guard let showsListCollectionViewController = segue.destination as? ShowsListCollectionViewController else { return }
			showsListCollectionViewController.studioIdentity = self.studioIdentity
			showsListCollectionViewController.showsListFetchType = .studio
		case R.segue.studioDetailsCollectionViewController.literatureDetailsSegue.identifier:
			guard let literatureDetailCollectionViewController = segue.destination as? LiteratureDetailsCollectionViewController else { return }
			guard let literature = sender as? Literature else { return }
			literatureDetailCollectionViewController.literature = literature
		case R.segue.studioDetailsCollectionViewController.literaturesListSegue.identifier:
			guard let literaturesListCollectionViewController = segue.destination as? LiteraturesListCollectionViewController else { return }
			literaturesListCollectionViewController.studioIdentity = self.studioIdentity
			literaturesListCollectionViewController.literaturesListFetchType = .studio
		case R.segue.studioDetailsCollectionViewController.gameDetailsSegue.identifier:
			guard let gameDetailCollectionViewController = segue.destination as? GameDetailsCollectionViewController else { return }
			guard let game = sender as? Game else { return }
			gameDetailCollectionViewController.game = game
		case R.segue.studioDetailsCollectionViewController.gamesListSegue.identifier:
			guard let gamesListCollectionViewController = segue.destination as? GamesListCollectionViewController else { return }
			gamesListCollectionViewController.studioIdentity = self.studioIdentity
			gamesListCollectionViewController.gamesListFetchType = .studio
		default: break
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
		if let synopsisKNavigationController = R.storyboard.synopsis.instantiateInitialViewController() {
			if let synopsisViewController = synopsisKNavigationController.viewControllers.first as? SynopsisViewController {
				synopsisViewController.title = cell.textViewCollectionViewCellType.stringValue
				synopsisViewController.synopsis = self.studio.attributes.about
			}
			synopsisKNavigationController.modalPresentationStyle = .fullScreen
			self.present(synopsisKNavigationController, animated: true)
		}
	}
}

// MARK: - TitleHeaderCollectionReusableViewDelegate
extension StudioDetailsCollectionViewController: TitleHeaderCollectionReusableViewDelegate {
	func titleHeaderCollectionReusableView(_ reusableView: TitleHeaderCollectionReusableView, didPress button: UIButton) {
		self.performSegue(withIdentifier: reusableView.segueID, sender: reusableView.indexPath)
	}
}

// MARK: - BaseLockupCollectionViewCellDelegate
extension StudioDetailsCollectionViewController: BaseLockupCollectionViewCellDelegate {
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
							self.shows[indexPath]?.attributes.library?.update(using: libraryUpdateResponse.data)
						case .literatures:
							self.literatures[indexPath]?.attributes.library?.update(using: libraryUpdateResponse.data)
						case .games:
							self.games[indexPath]?.attributes.library?.update(using: libraryUpdateResponse.data)
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
								self.shows[indexPath]?.attributes.library?.update(using: libraryUpdateResponse.data)
							case .literatures:
								self.literatures[indexPath]?.attributes.library?.update(using: libraryUpdateResponse.data)
							case .games:
								self.games[indexPath]?.attributes.library?.update(using: libraryUpdateResponse.data)
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
	}

	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressReminder button: UIButton) {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		guard let show = self.shows[indexPath] else { return }
		show.toggleReminder(on: self)
	}
}

// MARK: - ReviewCollectionViewCellDelegate
extension StudioDetailsCollectionViewController: ReviewCollectionViewCellDelegate {
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
extension StudioDetailsCollectionViewController: TapToRateCollectionViewCellDelegate {
	func tapToRateCollectionViewCell(_ cell: TapToRateCollectionViewCell, rateWith rating: Double) {
		Task { [weak self] in
			guard let self = self else { return }
			let rating = await self.studio.rate(using: rating, description: nil)
			cell.configure(using: rating)

			if rating != nil {
				self.showRatingSuccessAlert()
			}
		}
	}
}

// MARK: - WriteAReviewCollectionViewCellDelegate
extension StudioDetailsCollectionViewController: WriteAReviewCollectionViewCellDelegate {
	func writeAReviewCollectionViewCell(_ cell: WriteAReviewCollectionViewCell, didPress button: UIButton) {
		WorkflowController.shared.isSignedIn { [weak self] in
			guard let self = self else { return }

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
		var segueIdentifier: String {
			switch self {
			case .header:
				return ""
			case .badges:
				return ""
			case .about:
				return ""
			case .rating:
				return ""
			case .rateAndReview:
				return ""
			case .reviews:
				return ""
			case .information:
				return ""
			case .shows:
				return R.segue.studioDetailsCollectionViewController.showsListSegue.identifier
			case .literatures:
				return R.segue.studioDetailsCollectionViewController.literaturesListSegue.identifier
			case .games:
				return R.segue.studioDetailsCollectionViewController.gamesListSegue.identifier
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
