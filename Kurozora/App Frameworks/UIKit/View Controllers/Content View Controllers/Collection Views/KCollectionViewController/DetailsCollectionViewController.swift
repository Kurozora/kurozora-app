//
//  DetailsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// A cell whose height tracks the collection view's overscroll distance.
protocol StretchableHeaderCell: UICollectionViewCell {}

extension BaseDetailHeaderCollectionViewCell: StretchableHeaderCell {}
extension ProfileHeaderCollectionViewCell: StretchableHeaderCell {}

class DetailsCollectionViewController: KCollectionViewController, RatingAlertPresentable, BaseLockupCollectionViewCellDelegate, BaseDetailHeaderCollectionViewCellDelegate {
	// MARK: - Views
	var navigationTitleView: UIView = UIView()

	var navigationTitleLabel: KLabel = {
		let label = KLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.alpha = 0
		return label
	}()

	var moreBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: L10n.more, image: UIImage(systemName: "ellipsis.circle"))

	#if targetEnvironment(macCatalyst)
	/// The Touch Bar item that toggles the active model's favorite status.
	var toggleFavoriteTouchBarItem: NSButtonTouchBarItem?

	/// The Touch Bar item that toggles the active model's reminder status.
	var toggleReminderTouchBarItem: NSButtonTouchBarItem?
	#endif

	// MARK: - Properties
	/// The reviews displayed on the detail screen.
	var reviews: [Review] = []

	private var firstCellSize: CGSize = .zero

	var _prefersRefreshControlDisabled = false {
		didSet {
			self.setNeedsRefreshControlAppearanceUpdate()
		}
	}

	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}

	/// The image displayed in the empty-data view.
	var emptyStateImage: UIImage { UIImage() }

	/// The title displayed in the empty-data view.
	var emptyStateTitle: String { "No Details" }

	/// The detail text displayed in the empty-data view.
	var emptyStateDetail: String { "" }

	/// The segue identifier presented for the review cell's "more" action.
	var reviewDetailsSegueIdentifier: (any SegueIdentifier)? { nil }

	/// The model backing the Touch Bar's favorite button.
	var favoriteTarget: (any Libraryable)? { nil }

	/// The model backing the Touch Bar's reminder button.
	var reminderTarget: (any Libraryable)? { nil }

	/// The media items presented when the user taps the header's hero image.
	var mediaItems: [MediaItem] { [] }

	// MARK: - Overridden Properties
	override var prefersRefreshControlDisabled: Bool {
		return self._prefersRefreshControlDisabled
	}

	override var prefersActivityIndicatorHidden: Bool {
		return self._prefersActivityIndicatorHidden
	}

	// MARK: - View Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		ProfileHeaderCollectionViewCell.configureTransparentNavigationAppearance(on: self.navigationItem)

		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleReviewDidDelete(_:)), name: .KReviewDidDelete, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleFavoriteToggle(_:)), name: .KModelFavoriteIsToggled, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleReminderToggle(_:)), name: .KModelReminderIsToggled, object: nil)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		NotificationCenter.default.removeObserver(self, name: .KReviewDidDelete, object: nil)
		NotificationCenter.default.removeObserver(self, name: .KModelFavoriteIsToggled, object: nil)
		NotificationCenter.default.removeObserver(self, name: .KModelReminderIsToggled, object: nil)
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		let tabBarHeight = self.tabBarController?.tabBar.frame.height ?? 0
		self.collectionView.contentInset.bottom = tabBarHeight

		if let firstCell = self.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)),
		   self.firstCellSize.width != firstCell.frame.size.width {
			self.firstCellSize = firstCell.frame.size
		}
	}

	override func viewWillReload() {
		super.viewWillReload()
		self.handleRefreshControl()
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchDetails()
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
		}
	}

	override func configureEmptyDataView() {
		self.emptyBackgroundView.configureImageView(image: self.emptyStateImage)
		self.emptyBackgroundView.configureLabels(title: self.emptyStateTitle, detail: self.emptyStateDetail)
		self.collectionView.backgroundView?.alpha = 0
	}

	/// Fades the empty-data view in or out based on whether the collection view has any sections.
	func toggleEmptyDataView() {
		if self.collectionView.numberOfSections == 0 {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let offset = scrollView.contentOffset.y

		if self.navigationItem.titleView === self.navigationTitleView,
		   let firstCellAttributes = self.collectionView.layoutAttributesForItem(at: IndexPath(item: 0, section: 0)) {
			let firstCellBottomY = firstCellAttributes.frame.maxY
			let navigationBar = self.navigationController?.navigationBar
			let navBarBottomY = (navigationBar?.frame.maxY ?? 0) + (navigationBar?.superview?.frame.origin.y ?? 0)
			let targetAlpha: CGFloat = (offset + navBarBottomY >= firstCellBottomY) ? 1 : 0
			if self.navigationTitleLabel.alpha != targetAlpha {
				UIView.animate(withDuration: 0.25) {
					self.navigationTitleLabel.alpha = targetAlpha
				}
			}
		}

		if let firstCell = self.collectionView.cellForItem(at: [0, 0]), firstCell is any StretchableHeaderCell {
			if self.firstCellSize.width != firstCell.frame.size.width {
				self.firstCellSize = firstCell.frame.size
			}
			var newFrame = firstCell.frame
			if offset < 0 {
				newFrame.origin.y = offset
				newFrame.size.height = self.firstCellSize.height - offset
			} else {
				newFrame.origin.y = 0
				newFrame.size.height = self.firstCellSize.height
			}
			firstCell.frame = newFrame
		}

		if let layout = self.collectionView.collectionViewLayout as? UICollectionViewCompositionalLayout,
		   let attributes = layout.layoutAttributesForElements(in: self.collectionView.bounds) {
			for attribute in attributes where attribute.representedElementKind == SectionBackgroundDecorationView.elementKindSectionBackground {
				var newFrame = attribute.frame
				let section = attribute.indexPath.section
				let numberOfItemsInSection = self.collectionView.numberOfItems(inSection: section)
				let lastItemIndexPath = IndexPath(item: numberOfItemsInSection - 1, section: section)
				if let lastItemAttributes = self.collectionView.layoutAttributesForItem(at: lastItemIndexPath),
				   offset + scrollView.frame.size.height > (lastItemAttributes.frame.origin.y + lastItemAttributes.frame.size.height) {
					let difference = (offset + scrollView.frame.size.height) - (lastItemAttributes.frame.origin.y + lastItemAttributes.frame.size.height)
					newFrame.size.height += difference
				}
				attribute.frame = newFrame
			}
		}
	}

	// MARK: Navigation chrome
	/// Installs the custom title view and the "more" bar button on `navigationItem`.
	func configureNavigationItems() {
		self.configureNavigationTitleView()
		self.navigationItem.rightBarButtonItem = self.moreBarButtonItem
	}

	private func configureNavigationTitleView() {
		if #unavailable(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0) {
			self.navigationTitleLabel.theme_textColor = KThemePicker.barTitleTextColor.rawValue
		}

		self.navigationTitleView.addSubview(self.navigationTitleLabel)
		NSLayoutConstraint.activate([
			self.navigationTitleLabel.topAnchor.constraint(equalTo: self.navigationTitleView.topAnchor),
			self.navigationTitleLabel.bottomAnchor.constraint(equalTo: self.navigationTitleView.bottomAnchor),
			self.navigationTitleLabel.leadingAnchor.constraint(equalTo: self.navigationTitleView.leadingAnchor),
			self.navigationTitleLabel.trailingAnchor.constraint(equalTo: self.navigationTitleView.trailingAnchor),
			self.navigationTitleLabel.centerXAnchor.constraint(equalTo: self.navigationTitleView.centerXAnchor),
			self.navigationTitleLabel.centerYAnchor.constraint(equalTo: self.navigationTitleView.centerYAnchor)
		])

		self.navigationItem.titleView = self.navigationTitleView
	}

	/// Applies the menu returned by ``makeMoreMenu()`` to ``moreBarButtonItem``.
	func configureNavBarButtons() {
		self.moreBarButtonItem.menu = self.makeMoreMenu()
	}

	// MARK: Favorite / reminder
	/// Toggles the favorite status of ``favoriteTarget``.
	@objc func toggleFavorite() {
		Task { [weak self] in
			guard let self = self else { return }
			await self.favoriteTarget?.toggleFavorite(on: self)
		}
	}

	/// Toggles the reminder status of ``reminderTarget``.
	@objc func toggleReminder() {
		Task { [weak self] in
			guard let self = self else { return }
			await self.reminderTarget?.toggleReminder(on: self)
		}
	}

	@objc private func handleFavoriteToggle(_ notification: NSNotification) {
		#if targetEnvironment(macCatalyst)
		let favorited = self.favoriteTarget?.libraryAttributes?.favoriteStatus == .favorited
		self.toggleFavoriteTouchBarItem?.image = UIImage(systemName: favorited ? "heart.fill" : "heart")
		#endif
	}

	@objc private func handleReminderToggle(_ notification: NSNotification) {
		#if targetEnvironment(macCatalyst)
		let reminded = self.reminderTarget?.libraryAttributes?.reminderStatus == .reminded
		self.toggleReminderTouchBarItem?.image = UIImage(systemName: reminded ? "bell.fill" : "bell")
		#endif
	}

	// MARK: Review delete observer
	@objc private func handleReviewDidDelete(_ notification: NSNotification) {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			let indexPath = notification.userInfo?["indexPath"] as? IndexPath
			if let indexPath, self.reviews.indices.contains(indexPath.item) {
				self.reviews.remove(at: indexPath.item)
			}
			self.didDeleteReview(at: indexPath)
			self.updateDataSource()
		}
	}

	// MARK: Subclass hooks
	/// Fetches the screen's model and dependent sections.
	func fetchDetails() async {}

	/// Returns the context menu displayed by ``moreBarButtonItem``.
	func makeMoreMenu() -> UIMenu? { nil }

	/// Clears any cached rating or review on the model after a review is deleted.
	///
	/// - Parameter indexPath: The index path of the removed review, or `nil` if unavailable.
	func didDeleteReview(at indexPath: IndexPath?) {}

	/// Rates the active model with the given value and optional review.
	///
	/// - Parameters:
	///   - rating: The rating applied by the user.
	///   - description: The review text, or `nil`.
	/// - Returns: The rating recorded on the server, or `nil` if the rating failed.
	func rateItem(using rating: Double, description: String?) async throws(KKAPIError) -> Double? {
		#if DEBUG
		fatalError("\(type(of: self)) must override rateItem(using:description:)")
		#else
		return nil
		#endif
	}

	/// Returns the editor configuration for the active model.
	///
	/// - Returns: A tuple containing the editor kind, the existing rating, and the existing review, or `nil` to disable the review flow.
	func writeAReviewContext() -> (kind: ReviewTextEditor.Kind, rating: Double?, review: String?)? { nil }

	/// Presents the review details screen for the given review.
	///
	/// - Parameter review: The review whose details to present.
	func presentReviewDetails(for review: Review) {
		guard let identifier = self.reviewDetailsSegueIdentifier else { return }
		self.present(identifier, sender: review)
	}

	/// Returns the ``Libraryable`` model backing a lockup cell at the given index path.
	///
	/// - Parameters:
	///   - indexPath: The index path of the lockup cell.
	///   - kind: The library kind of the lockup cell.
	/// - Returns: The model whose library state the cell represents, or `nil`.
	func libraryStatusTarget(at indexPath: IndexPath, kind: KKLibrary.Kind) -> (any Libraryable)? {
		return nil
	}

	/// Returns the ``Libraryable`` model backing the header cell's library status button.
	///
	/// - Parameter cell: The header cell whose library model to resolve.
	/// - Returns: The model whose library state the header represents, or `nil`.
	func libraryStatusTargetForHeader(_ cell: BaseDetailHeaderCollectionViewCell) -> (any Libraryable)? {
		guard let cell = cell as? ShowDetailHeaderCollectionViewCell else { return nil }
		switch cell.libraryKind {
		case .shows: return cell.show
		case .literatures: return cell.literature
		case .games: return cell.game
		}
	}

	/// Returns the show whose reminder status the lockup cell at the given index path represents.
	///
	/// - Parameter indexPath: The index path of the lockup cell.
	/// - Returns: The show represented by the cell, or `nil`.
	func reminderTarget(at indexPath: IndexPath) -> Show? {
		return nil
	}

	// MARK: BaseLockupCollectionViewCellDelegate
	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressStatus button: UIButton) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard signedIn else { return }
		guard let indexPath = self.collectionView.indexPath(for: cell),
		      let target = self.libraryStatusTarget(at: indexPath, kind: cell.libraryKind) else { return }

		self.presentLibraryActionSheet(
			libraryKind: cell.libraryKind,
			currentStatus: cell.libraryStatus,
			button: button,
			target: target,
			didAdd: { [weak cell, weak button] newStatus, title in
				cell?.libraryStatus = newStatus
				button?.setTitle("\(title) ▾", for: .normal)
			},
			didRemove: { [weak cell, weak button] _ in
				cell?.libraryStatus = .none
				button?.setTitle(L10n.add.uppercased(), for: .normal)
			}
		)
	}

	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressReminder button: UIButton) async {
		guard let indexPath = self.collectionView.indexPath(for: cell),
		      let show = self.reminderTarget(at: indexPath) else { return }
		await show.toggleReminder(on: self)
		cell.configureReminderButton(for: show.attributes.library?.reminderStatus)
	}

	// MARK: BaseDetailHeaderCollectionViewCellDelegate
	func baseDetailHeaderCollectionViewCell(_ cell: BaseDetailHeaderCollectionViewCell, didPressStatus button: UIButton) async {
		guard await WorkflowController.shared.isSignedIn() else { return }
		guard let showHeaderCell = cell as? ShowDetailHeaderCollectionViewCell,
		      let target = self.libraryStatusTargetForHeader(cell) else { return }

		let oldLibraryStatus = showHeaderCell.libraryStatus

		self.presentLibraryActionSheet(
			libraryKind: showHeaderCell.libraryKind,
			currentStatus: showHeaderCell.libraryStatus,
			button: button,
			target: target,
			didAdd: { [weak showHeaderCell] newStatus, _ in
				guard let showHeaderCell else { return }
				showHeaderCell.libraryStatus = newStatus
				DetailsCollectionViewController.updateHeaderLibraryActions(cell: showHeaderCell, target: target, animated: oldLibraryStatus == .none)
			},
			didRemove: { [weak showHeaderCell] _ in
				guard let showHeaderCell else { return }
				showHeaderCell.libraryStatus = .none
				DetailsCollectionViewController.updateHeaderLibraryActions(cell: showHeaderCell, target: target, animated: true)
			}
		)
	}

	private static func updateHeaderLibraryActions(cell: ShowDetailHeaderCollectionViewCell, target: any Libraryable, animated: Bool) {
		switch target {
		case let show as Show: cell.updateLibraryActions(using: show, animated: animated)
		case let literature as Literature: cell.updateLibraryActions(using: literature, animated: animated)
		case let game as Game: cell.updateLibraryActions(using: game, animated: animated)
		default: break
		}
	}
}

// MARK: - TapToRateCollectionViewCellDelegate
extension DetailsCollectionViewController: TapToRateCollectionViewCellDelegate {
	func tapToRateCollectionViewCell(_ cell: TapToRateCollectionViewCell, rateWith rating: Double) {
		if rating == 0 {
			self.handleTapToRateDeletion(on: cell)
			return
		}

		Task { [weak self] in
			guard let self = self else { return }
			do throws(KKAPIError) {
				let newRating = try await self.rateItem(using: rating, description: nil)
				cell.configure(using: newRating)
				if newRating != nil {
					self.showRatingSuccessAlert()
				}
			} catch {
				cell.configure(using: nil)
				self.showRatingFailureAlert(message: error.message)
			}
		}
	}

	private func handleTapToRateDeletion(on cell: TapToRateCollectionViewCell) {
		guard let context = self.writeAReviewContext() else {
			// No context means no existing rating to clear; snap the cell back to empty.
			cell.configure(using: nil)
			return
		}
		let previousRating = context.rating
		let kind = context.kind

		self.confirmDeleteRating(onConfirm: { [weak self, weak cell] in
			guard let self = self, let cell = cell else { return }
			Task {
				do throws(KKAPIError) {
					let didDelete = try await kind.deleteRating()
					if didDelete {
						cell.configure(using: nil)
						self.didDeleteReview(at: nil)
					} else {
						cell.configure(using: previousRating)
						self.presentAlertController(title: L10n.ratingFailed, message: "Not available yet for this type.")
					}
				} catch {
					cell.configure(using: previousRating)
					self.showRatingFailureAlert(message: error.message)
				}
			}
		}, onCancel: { [weak cell] in
			cell?.configure(using: previousRating)
		})
	}
}

// MARK: - WriteAReviewCollectionViewCellDelegate
extension DetailsCollectionViewController: WriteAReviewCollectionViewCellDelegate {
	func writeAReviewCollectionViewCell(_ cell: WriteAReviewCollectionViewCell, didPress button: UIButton) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard signedIn, let context = self.writeAReviewContext() else { return }

		let reviewTextEditorViewController = ReviewTextEditorViewController()
		reviewTextEditorViewController.delegate = self
		reviewTextEditorViewController.router?.dataStore?.kind = context.kind
		reviewTextEditorViewController.router?.dataStore?.rating = context.rating
		reviewTextEditorViewController.router?.dataStore?.review = context.review

		let navigationController = KNavigationController(rootViewController: reviewTextEditorViewController)
		navigationController.presentationController?.delegate = reviewTextEditorViewController
		self.present(navigationController, animated: true)
	}
}

// MARK: - ReviewTextEditorViewControllerDelegate
extension DetailsCollectionViewController: ReviewTextEditorViewControllerDelegate {
	func reviewTextEditorViewControllerDidSubmitReview() {
		self.showRatingSuccessAlert()
	}

	func reviewTextEditorViewControllerDidDeleteReview() {
		self.didDeleteReview(at: nil)
	}
}

// MARK: - ReviewCollectionViewCellDelegate
extension DetailsCollectionViewController: ReviewCollectionViewCellDelegate {
	func reviewCollectionViewCell(_ cell: ReviewCollectionViewCell, didPressUserName sender: AnyObject) {
		guard
			let indexPath = self.collectionView.indexPath(for: cell),
			let review = self.reviews[safe: indexPath.item]
		else { return }
		review.visitOriginalPosterProfile(from: self)
	}

	func reviewCollectionViewCell(_ cell: ReviewCollectionViewCell, didPressProfileBadge button: UIButton, for profileBadge: ProfileBadge) {
		let badgeViewController = BadgeViewController()
		badgeViewController.profileBadge = profileBadge
		badgeViewController.popoverPresentationController?.sourceView = button
		badgeViewController.popoverPresentationController?.sourceRect = button.bounds
		self.present(badgeViewController, animated: true, completion: nil)
	}

	func reviewCollectionViewCell(_ cell: ReviewCollectionViewCell, didPressMoreButton button: UIButton) {
		guard
			let indexPath = self.collectionView.indexPath(for: cell),
			let review = self.reviews[safe: indexPath.item]
		else { return }
		self.presentReviewDetails(for: review)
	}
}

// MARK: - TitleHeaderCollectionReusableViewDelegate
extension DetailsCollectionViewController: TitleHeaderCollectionReusableViewDelegate {
	func titleHeaderCollectionReusableView(_ reusableView: TitleHeaderCollectionReusableView, didPress button: UIButton) {
		guard let segueID = reusableView.segueID else { return }
		self.show(segueID, sender: reusableView.indexPath)
	}
}

// MARK: - MediaTransitionDelegate
extension DetailsCollectionViewController: MediaTransitionDelegate {
	func imageViewForMedia(at index: Int) -> UIImageView? {
		guard let cell = self.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? any MediaViewerHeaderCell else {
			return nil
		}
		return cell.imageView(at: index)
	}

	func scrollThumbnailIntoView(for index: Int) {
		let indexPath = IndexPath(item: index, section: 0)
		self.collectionView.safeScrollToItem(at: indexPath, at: .centeredVertically, animated: true)
	}
}

// MARK: - MediaViewerViewDelegate
extension DetailsCollectionViewController: MediaViewerViewDelegate {
	func mediaViewerViewDelegate(_ view: UIView, didTapImage imageView: UIImageView, at index: Int) {
		let items = self.mediaItems
		guard items.indices.contains(index) else { return }
		let albumVC = MediaAlbumViewController(items: items, startIndex: index)
		albumVC.transitionDelegateForThumbnail = self
		self.present(albumVC, animated: true)
	}
}

// MARK: - Touch Bar (Mac Catalyst)
#if targetEnvironment(macCatalyst)
extension DetailsCollectionViewController: NSTouchBarDelegate {
	override func makeTouchBar() -> NSTouchBar? {
		var identifiers: [NSTouchBarItem.Identifier] = []
		if self.reminderTarget != nil {
			identifiers.append(.toggleModelIsReminded)
		}
		if self.favoriteTarget != nil {
			identifiers.append(.toggleModelIsFavorite)
		}
		guard !identifiers.isEmpty else { return nil }

		let touchBar = NSTouchBar()
		touchBar.delegate = self
		touchBar.defaultItemIdentifiers = identifiers
		return touchBar
	}

	func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
		switch identifier {
		case .toggleModelIsFavorite:
			guard let target = self.favoriteTarget else { return nil }
			let favorited = target.libraryAttributes?.favoriteStatus == .favorited
			guard let image = UIImage(systemName: favorited ? "heart.fill" : "heart") else { return nil }
			let item = NSButtonTouchBarItem(identifier: identifier, image: image, target: self, action: #selector(self.toggleFavorite))
			self.toggleFavoriteTouchBarItem = item
			return item
		case .toggleModelIsReminded:
			guard let target = self.reminderTarget else { return nil }
			let reminded = target.libraryAttributes?.reminderStatus == .reminded
			guard let image = UIImage(systemName: reminded ? "bell.fill" : "bell") else { return nil }
			let item = NSButtonTouchBarItem(identifier: identifier, image: image, target: self, action: #selector(self.toggleReminder))
			self.toggleReminderTouchBarItem = item
			return item
		default:
			return nil
		}
	}
}
#endif

// MARK: - Library action sheet helper
extension DetailsCollectionViewController {
	/// Presents an action sheet for adding, changing, or removing the target's library status.
	///
	/// - Parameters:
	///   - libraryKind: The library category to update.
	///   - currentStatus: The current library status.
	///   - button: The source button used for popover presentation.
	///   - target: The model whose library state to update.
	///   - didAdd: Invoked on successful add with the new status and the action title.
	///   - didRemove: Invoked on successful remove with the previous status.
	fileprivate func presentLibraryActionSheet(
		libraryKind: KKLibrary.Kind,
		currentStatus: KKLibrary.Status,
		button: UIButton,
		target: any Libraryable,
		didAdd: @escaping @MainActor (_ newStatus: KKLibrary.Status, _ title: String) -> Void,
		didRemove: @escaping @MainActor (_ previousStatus: KKLibrary.Status) -> Void
	) {
		let oldLibraryStatus = currentStatus
		let modelID = target.id

		let actionSheet = UIAlertController.actionSheetWithItems(
			items: KKLibrary.Status.alertControllerItems(for: libraryKind),
			currentSelection: oldLibraryStatus,
			action: { title, value in
				Task { [weak self] in
					guard let self = self else { return }
					do {
						let response = try await KService.addToLibrary(libraryKind, withLibraryStatus: value, modelID: modelID)
						target.updateLibrary(using: response.data)
						didAdd(value, title)
						NotificationCenter.default.post(name: Notification.Name("AddTo\(value.sectionValue)Section"), object: nil)
						self.configureNavBarButtons()
						ReviewManager.shared.requestReview(for: .itemAddedToLibrary(status: value))
					} catch let error as KKAPIError {
						self.presentAlertController(title: "Can't Add to Your Library 😔", message: error.message)
						print("----- Add to library failed", error.message)
					}
				}
			}
		)

		if oldLibraryStatus != .none {
			actionSheet.addAction(UIAlertAction(title: L10n.removeFromLibrary, style: .destructive) { _ in
				Task { [weak self] in
					guard let self = self else { return }
					do {
						let response = try await KService.removeFromLibrary(libraryKind, modelID: modelID)
						target.updateLibrary(using: response.data)
						didRemove(oldLibraryStatus)
						NotificationCenter.default.post(name: Notification.Name("RemoveFrom\(oldLibraryStatus.sectionValue)Section"), object: nil)
						self.configureNavBarButtons()
					} catch let error as KKAPIError {
						self.presentAlertController(title: "Can't Remove From Your Library 😔", message: error.message)
						print("----- Remove from library failed", error.message)
					}
				}
			})
		}

		if let popoverController = actionSheet.popoverPresentationController {
			popoverController.sourceView = button
			popoverController.sourceRect = button.bounds
		}

		if (self.navigationController?.visibleViewController as? UIAlertController) == nil {
			self.present(actionSheet, animated: true, completion: nil)
		}
	}
}
