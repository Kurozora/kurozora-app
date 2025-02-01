//
//  SongDetailsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/11/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Alamofire
import MusicKit

class SongDetailsCollectionViewController: KCollectionViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var moreButton: UIBarButtonItem!

	// MARK: - Properties
	var songIdentity: SongIdentity? = nil
	var song: KKSong! {
		didSet {
			self.title = self.song.attributes.title
			self.songIdentity = SongIdentity(id: self.song.id)

			self._prefersActivityIndicatorHidden = true

			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
			#endif
		}
	}
	var shows: [IndexPath: Show] = [:]
	var showIdentities: [ShowIdentity] = []
	var responseCount: Int = 0 {
		didSet {
			if self.responseCount == 3 {
				self.updateDataSource()
			}
		}
	}

	/// Review properties.
	var reviews: [Review] = []

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
	/// Initialize a new instance of SongDetailsCollectionViewController with the given song id.
	///
	/// - Parameter songID: The song id to use when initializing the view.
	///
	/// - Returns: an initialized instance of SongDetailsCollectionViewController.
	static func `init`(with songID: String) -> SongDetailsCollectionViewController {
		if let songDetailsCollectionViewController = R.storyboard.songs.songDetailsCollectionViewController() {
			songDetailsCollectionViewController.songIdentity = SongIdentity(id: songID)
			return songDetailsCollectionViewController
		}

		fatalError("Failed to instantiate SongDetailsCollectionViewController with the given song id.")
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
		emptyBackgroundView.configureLabels(title: "No Details", detail: "This song doesn't have details yet. Please check back again later.")

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

	/// Fetches the currently viewed song's details.
	func fetchDetails() async {
		guard let songIdentity = self.songIdentity else { return }

		do {
			let songResponse = try await KService.getDetails(forSong: songIdentity).value
			self.song = songResponse.data.first

			self.moreButton.menu = self.song?.makeContextMenu(in: self, userInfo: [:])

			self.responseCount += 1
		} catch {
			print(error.localizedDescription)
		}

		do {
			let showIdentityResponse = try await KService.getShows(forSong: songIdentity, limit: 10).value
			self.showIdentities = showIdentityResponse.data
			self.responseCount += 1
		} catch {
			print(error.localizedDescription)
		}

		do {
			let reviewIdentityResponse = try await KService.getReviews(forSong: songIdentity, next: nil, limit: 10).value
			self.reviews = reviewIdentityResponse.data
			self.responseCount += 1
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
		case R.segue.songDetailsCollectionViewController.showDetailsSegue.identifier:
			guard let showDetailsCollectionViewController = segue.destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailsCollectionViewController.show = show
		default: break
		}
	}
}

// MARK: - UICollectionViewDataSource
extension SongDetailsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let songDetailSection = self.snapshot.sectionIdentifiers[indexPath.section]
		let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
		titleHeaderCollectionReusableView.delegate = self
		titleHeaderCollectionReusableView.configure(withTitle: songDetailSection.stringValue, indexPath: indexPath, segueID: songDetailSection.segueIdentifier)
		return titleHeaderCollectionReusableView
	}
}

// MARK: - TextViewCollectionViewCellDelegate
extension SongDetailsCollectionViewController: TextViewCollectionViewCellDelegate {
	func textViewCollectionViewCell(_ cell: TextViewCollectionViewCell, didPressButton button: UIButton) {
		if let synopsisKNavigationController = R.storyboard.synopsis.instantiateInitialViewController() {
			if let synopsisViewController = synopsisKNavigationController.viewControllers.first as? SynopsisViewController {
				synopsisViewController.title = cell.textViewCollectionViewCellType.stringValue
				synopsisViewController.synopsis = self.song.attributes.originalLyrics
			}
			synopsisKNavigationController.modalPresentationStyle = .formSheet
			self.present(synopsisKNavigationController, animated: true)
		}
	}
}

// MARK: - TitleHeaderCollectionReusableViewDelegate
extension SongDetailsCollectionViewController: TitleHeaderCollectionReusableViewDelegate {
	func titleHeaderCollectionReusableView(_ reusableView: TitleHeaderCollectionReusableView, didPress button: UIButton) {
		self.performSegue(withIdentifier: reusableView.segueID, sender: reusableView.indexPath)
	}
}

// MARK: - BaseLockupCollectionViewCellDelegate
extension SongDetailsCollectionViewController: BaseLockupCollectionViewCellDelegate {
	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressStatus button: UIButton) {
		WorkflowController.shared.isSignedIn { [weak self] in
			guard let self = self else { return }
			guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
			guard let show = self.shows[indexPath] else { return }

			let oldLibraryStatus = cell.libraryStatus
			let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: KKLibrary.Status.alertControllerItems(for: cell.libraryKind), currentSelection: oldLibraryStatus, action: { title, value  in
				Task {
					do {
						let libraryUpdateResponse = try await KService.addToLibrary(cell.libraryKind, withLibraryStatus: value, modelID: show.id).value

						show.attributes.library?.update(using: libraryUpdateResponse.data)

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
							let libraryUpdateResponse = try await KService.removeFromLibrary(cell.libraryKind, modelID: show.id).value

							show.attributes.library?.update(using: libraryUpdateResponse.data)

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
	}

	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressReminder button: UIButton) {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		guard let show = self.shows[indexPath] else { return }
		show.toggleReminder(on: self)
	}
}

// MARK: - SongHeaderCollectionViewCellDelegate
extension SongDetailsCollectionViewController: SongHeaderCollectionViewCellDelegate {
	func playStateChanged(_ song: MKSong?) {
		self.updateMenu(with: song)
	}

	private func updateMenu(with song: MKSong?) {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.moreButton.menu = self.song?.makeContextMenu(in: self, userInfo: [
				"song": song
			])
		}
	}
}

// MARK: - ReviewCollectionViewCellDelegate
extension SongDetailsCollectionViewController: ReviewCollectionViewCellDelegate {
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
extension SongDetailsCollectionViewController: TapToRateCollectionViewCellDelegate {
	func tapToRateCollectionViewCell(_ cell: TapToRateCollectionViewCell, rateWith rating: Double) {
		Task { [weak self] in
			guard let self = self else { return }
			let rating = await self.song.rate(using: rating, description: nil)
			cell.configure(using: rating)

			if rating != nil {
				self.showRatingSuccessAlert()
			}
		}
	}
}

// MARK: - WriteAReviewCollectionViewCellDelegate
extension SongDetailsCollectionViewController: WriteAReviewCollectionViewCellDelegate {
	func writeAReviewCollectionViewCell(_ cell: WriteAReviewCollectionViewCell, didPress button: UIButton) {
		WorkflowController.shared.isSignedIn { [weak self] in
			guard let self = self else { return }

			let reviewTextEditorViewController = ReviewTextEditorViewController()
			reviewTextEditorViewController.delegate = self
			reviewTextEditorViewController.router?.dataStore?.kind = .song(self.song)
			reviewTextEditorViewController.router?.dataStore?.rating = self.song.attributes.library?.rating
			reviewTextEditorViewController.router?.dataStore?.review = self.song.attributes.library?.review

			let navigationController = KNavigationController(rootViewController: reviewTextEditorViewController)
			navigationController.presentationController?.delegate = reviewTextEditorViewController
			self.present(navigationController, animated: true)
		}
	}
}

// MARK: - ReviewTextEditorViewControllerDelegate
extension SongDetailsCollectionViewController: ReviewTextEditorViewControllerDelegate {
	func reviewTextEditorViewControllerDidSubmitReview() {
		self.showRatingSuccessAlert()
	}
}

extension SongDetailsCollectionViewController {
	enum SectionLayoutKind: Int, CaseIterable {
		// MARK: - Cases
		/// Indicates a header section layout type.
		case header = 0

		/// Indicates a lyrics section layout type.
		case lyrics

		/// Indicates a rating section layout type.
		case rating

		/// Indicates a rate and review section layout type.
		case rateAndReview

		/// Indicates a reviews section layout type.
		case reviews

		/// Indicates shows section layout type.
		case shows

		/// Indicates a copyright section layout type.
		case sosumi

		// MARK: - Properties
		/// The string value of a song section type.
		var stringValue: String {
			switch self {
			case .header:
				return Trans.header
			case .lyrics:
				return Trans.lyrics
			case .rating:
				return Trans.ratingsAndReviews
			case .rateAndReview:
				return ""
			case .reviews:
				return ""
			case .shows:
				return Trans.asHeardOn
			case .sosumi:
				return Trans.copyright
			}
		}

		/// The string value of a song section type segue identifier.
		var segueIdentifier: String {
			switch self {
			case .header:
				return ""
			case .lyrics:
				return ""
			case .rating:
				return ""
			case .rateAndReview:
				return ""
			case .reviews:
				return ""
			case .shows:
				return ""
			case .sosumi:
				return ""
			}
		}
	}

	/// List of available Item Kind types.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `Song` object.
		case song(_: KKSong, id: UUID = UUID())

		/// Indicates the item kind contains a `Review` object.
		case review(_: Review, id: UUID = UUID())

		/// Indicates the item kind contains a `ShowIdentity` object.
		case showIdentity(_: ShowIdentity, id: UUID = UUID())

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .song(let song, let id):
				hasher.combine(song)
				hasher.combine(id)
			case .review(let review, let id):
				hasher.combine(review)
				hasher.combine(id)
			case .showIdentity(let showIdentity, let id):
				hasher.combine(showIdentity)
				hasher.combine(id)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.song(let song1, let id1), .song(let song2, let id2)):
				return song1 == song2 && id1 == id2
			case (.review(let review1, let id1), .review(let review2, let id2)):
				return review1 == review2 && id1 == id2
			case (.showIdentity(let showIdentity1, let id1), .showIdentity(let showIdentity2, let id2)):
				return showIdentity1 == showIdentity2 && id1 == id2
			default:
				return false
			}
		}
	}
}
