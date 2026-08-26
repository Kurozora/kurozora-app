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

	/// The button that toggles the header trailer's sound.
	private lazy var trailerMuteBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "speaker.slash.fill"), style: .plain, target: self, action: #selector(self.toggleTrailerMute))

	/// The button that opens the header trailer fullscreen.
	private lazy var trailerFullscreenBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.up.left.and.arrow.down.right"), style: .plain, target: self, action: #selector(self.enterTrailerFullscreen))

	#if targetEnvironment(macCatalyst)
	/// The Touch Bar item that toggles the active model's favorite status.
	var toggleFavoriteTouchBarItem: NSButtonTouchBarItem?

	/// The Touch Bar item that toggles the active model's reminder status.
	var toggleReminderTouchBarItem: NSButtonTouchBarItem?
	#endif

	// MARK: - Properties
	/// The reviews displayed on the detail screen.
	var reviews: [Review] = [] {
		didSet {
			if #available(iOS 26.4, macCatalyst 26.4, *) {
				TranslationService.shared.prefetch(self.reviews)
			}
		}
	}

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

	/// A Boolean value indicating whether the navigation bar shows the title instead of the header.
	private var isNavigationTitleVisible = false

	/// The trailer button state already applied to the navigation bar.
	private var appliedTrailerBarButtonState: (showsItems: Bool, isMuted: Bool)?

	/// The image displayed in the empty-data view.
	var emptyStateImage: UIImage? { nil }

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

		NotificationCenter.default.addObserver(self, selector: #selector(self.handleReviewDidUpdate(_:)), name: .KReviewDidUpdate, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleReviewVoteDidUpdate(_:)), name: .KReviewVoteDidUpdate, object: nil)

		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleReviewDidDelete(_:)), name: .KReviewDidDelete, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleTranslationDidUpdate(_:)), name: .KTranslationDidUpdate, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleRatingStyleDidChange(_:)), name: .KSRatingStyleDidChange, object: nil)

		self.reconfigureRatingCells()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		NotificationCenter.default.removeObserver(self, name: .KReviewDidDelete, object: nil)
		NotificationCenter.default.removeObserver(self, name: .KTranslationDidUpdate, object: nil)
		NotificationCenter.default.removeObserver(self, name: .KSRatingStyleDidChange, object: nil)
	}

	/// Re-renders the rating cell in the user's new rating style.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers.
	@objc func handleRatingStyleDidChange(_ notification: NSNotification) {
		Task { @MainActor [weak self] in
			self?.reconfigureRatingCells()
		}
	}

	/// Re-renders the rating cell in the user's current rating style.
	@MainActor
	func reconfigureRatingCells() {
		let rating = self.writeAReviewContext()?.rating

		for cell in self.collectionView.visibleCells {
			guard let tapToRateCell = cell as? TapToRateCollectionViewCell else { continue }
			tapToRateCell.configure(using: rating)
		}
	}

	/// Re-renders the visible cells whose translation state changed.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers.
	@objc func handleTranslationDidUpdate(_ notification: NSNotification) {
		Task { @MainActor [weak self] in
			guard let self = self else { return }

			for cell in self.collectionView.visibleCells {
				guard
					let reviewCell = cell as? ReviewCollectionViewCell,
					let indexPath = self.collectionView.indexPath(for: cell),
					let review = self.review(at: indexPath)
				else { continue }

				reviewCell.configureCell(using: review, isElevated: review.attributes.isElevated)
			}
		}
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		let tabBarHeight = self.tabBarController?.tabBar.frame.height ?? 0
		self.collectionView.contentInset.bottom = tabBarHeight

		self.updateFullBleedHeaderInset()

		// The header cell appears after the navigation chrome is first configured, so the trailer's
		// buttons are picked up here once it exists.
		self.updateTrailerBarButtonItems()
	}

	override func viewSafeAreaInsetsDidChange() {
		super.viewSafeAreaInsetsDidChange()
		self.updateFullBleedHeaderInset()

		self.collectionView.collectionViewLayout.invalidateLayout()
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
		if let image = self.emptyStateImage {
			self.emptyBackgroundView.configureImageView(image: image)
		}
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
		let firstCellFrame = self.collectionView.layoutAttributesForItem(at: IndexPath(item: 0, section: 0))?.frame

		if self.navigationItem.titleView === self.navigationTitleView,
		   let firstCellBottomY = firstCellFrame?.maxY {
			let navigationBar = self.navigationController?.navigationBar
			let navBarBottomY = (navigationBar?.frame.maxY ?? 0) + (navigationBar?.superview?.frame.origin.y ?? 0)
			let targetAlpha: CGFloat = (offset + navBarBottomY >= firstCellBottomY) ? 1 : 0
			if self.navigationTitleLabel.alpha != targetAlpha {
				UIView.animate(withDuration: 0.25) {
					self.navigationTitleLabel.alpha = targetAlpha
				}

				// The title appears exactly when the header has scrolled out of sight, so it also
				// marks the point the trailer is no longer worth playing.
				self.isNavigationTitleVisible = targetAlpha == 1
				self.headerTrailerPlayerView?.setPlaybackSuspended(self.isNavigationTitleVisible)
				self.updateTrailerBarButtonItems()
			}
		}

		if let firstCell = self.collectionView.cellForItem(at: [0, 0]), firstCell is any StretchableHeaderCell,
		   let firstCellFrame = firstCellFrame {
			// Grow only past the resting offset.
			let overscroll = min(offset + scrollView.adjustedContentInset.top, 0)
			var newFrame = firstCellFrame
			newFrame.origin.y += overscroll
			newFrame.size.height -= overscroll
			firstCell.frame = newFrame
		}
	}

	/// Extends the collection view's content under the navigation bar.
	private func updateFullBleedHeaderInset() {
		let safeAreaTop = self.collectionView.safeAreaInsets.top

		guard self.collectionView.contentInset.top != -safeAreaTop else { return }

		let isAtRest = self.collectionView.contentOffset.y == -self.collectionView.adjustedContentInset.top

		self.collectionView.contentInset.top = -safeAreaTop
		self.collectionView.verticalScrollIndicatorInsets.top = safeAreaTop

		if isAtRest {
			self.collectionView.contentOffset.y = -self.collectionView.adjustedContentInset.top
		}
	}

	// MARK: Navigation chrome
	/// Installs the custom title view and the "more" bar button on `navigationItem`.
	func configureNavigationItems() {
		self.configureNavigationTitleView()
		self.updateTrailerBarButtonItems()
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
		self.updateTrailerBarButtonItems()
	}

	/// The trailer playing in the header, when the screen shows one.
	private var headerTrailerPlayerView: KTrailerPlayerView? {
		let headerCell = self.collectionView.cellForItem(at: IndexPath(item: 0, section: 0))
		return (headerCell as? BaseDetailHeaderCollectionViewCell)?.hostedTrailerPlayerView
	}

	override var canBecomeFirstResponder: Bool {
		return true
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		// The trailer's keyboard and menu commands resolve through the responder chain.
		self.becomeFirstResponder()
	}

	override var keyCommands: [UIKeyCommand]? {
		var commands = super.keyCommands ?? []

		if self.headerTrailerPlayerView?.hasLoadedTrailer == true {
			let fullscreenCommand = UIKeyCommand(action: #selector(self.toggleTrailerFullscreen), input: "f", modifierFlags: .command)
			fullscreenCommand.wantsPriorityOverSystemBehavior = true
			commands.append(fullscreenCommand)
		}

		return commands
	}

	/// Opens the header trailer fullscreen in response to the fullscreen command.
	@objc func toggleTrailerFullscreen() {
		self.enterTrailerFullscreen()
	}

	/// Plays or pauses the header trailer in response to the playback command.
	@objc func togglePlayPause() {
		guard let headerTrailerPlayerView = self.headerTrailerPlayerView else { return }

		if headerTrailerPlayerView.isTrailerPlaying {
			headerTrailerPlayerView.pauseByReader()
		} else {
			headerTrailerPlayerView.playByReader()
		}
	}

	/// Toggles the header trailer's sound in response to the mute command.
	@objc func muteVolume() {
		self.toggleTrailerMute()
	}

	override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
		switch action {
		// Inline, the trailer answers for fullscreen, sound, and play or pause.
		case #selector(self.toggleTrailerFullscreen), #selector(self.togglePlayPause), #selector(self.muteVolume):
			return self.headerTrailerPlayerView?.hasLoadedTrailer == true
		default:
			return super.canPerformAction(action, withSender: sender)
		}
	}

	/// Groups the trailer's sound and fullscreen buttons beside the more button.
	///
	/// The pair is offered only while the header trailer is in sight; once the title takes over the
	/// navigation bar the trailer is off screen and its controls go with it.
	private func updateTrailerBarButtonItems() {
		let trailerPlayerView = self.headerTrailerPlayerView
		let showsTrailerItems = trailerPlayerView?.hasLoadedTrailer == true && !self.isNavigationTitleVisible
		let isMuted = trailerPlayerView?.isTrailerMuted ?? true

		guard self.appliedTrailerBarButtonState?.showsItems != showsTrailerItems || self.appliedTrailerBarButtonState?.isMuted != isMuted else { return }
		self.appliedTrailerBarButtonState = (showsTrailerItems, isMuted)

		guard showsTrailerItems else {
			self.navigationItem.rightBarButtonItems = [self.moreBarButtonItem]
			return
		}
		self.trailerMuteBarButtonItem.image = UIImage(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
		self.trailerMuteBarButtonItem.accessibilityLabel = isMuted ? L10n.unmute : L10n.mute
		self.trailerFullscreenBarButtonItem.accessibilityLabel = L10n.fullscreen

		if #available(iOS 16.0, macCatalyst 16.0, *) {
			self.navigationItem.trailingItemGroups = [
				UIBarButtonItemGroup.fixedGroup(items: [self.trailerMuteBarButtonItem, self.trailerFullscreenBarButtonItem]),
				UIBarButtonItemGroup.fixedGroup(items: [self.moreBarButtonItem])
			]
		} else {
			self.navigationItem.rightBarButtonItems = [self.moreBarButtonItem, self.trailerFullscreenBarButtonItem, self.trailerMuteBarButtonItem]
		}
	}

	/// Toggles the header trailer's sound.
	@objc private func toggleTrailerMute() {
		self.headerTrailerPlayerView?.toggleMuteByReader()
		self.updateTrailerBarButtonItems()
	}

	/// Opens the header trailer fullscreen.
	@objc private func enterTrailerFullscreen() {
		self.headerTrailerPlayerView?.enterFullscreenByReader()
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

	/// Refreshes the touch-bar heart/bell icons from the current favorite/reminder state.
	func refreshTouchBarLibraryState() {
		#if targetEnvironment(macCatalyst)
		let favorited = self.favoriteTarget?.libraryAttributes?.favoriteStatus == .favorited
		self.toggleFavoriteTouchBarItem?.image = UIImage(systemName: favorited ? "heart.fill" : "heart")

		let reminded = self.reminderTarget?.libraryAttributes?.reminderStatus == .reminded
		self.toggleReminderTouchBarItem?.image = UIImage(systemName: reminded ? "bell.fill" : "bell")
		#endif
	}

	// MARK: Review delete observer
	@objc private func handleReviewDidDelete(_ notification: NSNotification) {
		guard let reviewID = notification.userInfo?["reviewID"] as? KurozoraItemID else { return }

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }

			self.reviews.removeAll { review in
				review.id == reviewID
			}

			self.didDeleteReview()

			// One row leaves; the page keeps its scroll position.
			self.applyReviewRow(nil, for: reviewID)
		}
	}

	// MARK: Review update observer
	/// Applies a helpfulness vote to the review it was cast on.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers.
	@objc private func handleReviewVoteDidUpdate(_ notification: NSNotification) {
		guard let reviewID = notification.userInfo?["reviewID"] as? KurozoraItemID else { return }

		let isHelpful = notification.userInfo?["isHelpful"] as? Bool

		Task { @MainActor [weak self] in
			guard let self = self else { return }
			guard let index = self.reviews.firstIndex(where: { $0.id == reviewID }) else { return }

			// The row carries the review by value, so the vote survives recycling.
			self.reviews[index].attributes.applyVote(isHelpful)
			self.applyReviewRow(self.reviews[index], for: reviewID)
		}
	}

	/// Re-renders the changed review without refetching the section.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers.
	@objc private func handleReviewDidUpdate(_ notification: NSNotification) {
		guard let reviewID = notification.userInfo?["reviewID"] as? KurozoraItemID else { return }

		let affectsElevation = notification.userInfo?["affectsElevation"] as? Bool ?? false

		Task { @MainActor [weak self] in
			guard let self = self else { return }

			// The previous holder renders without its badge.
			if affectsElevation, let demoted = self.reviews.first(where: { $0.attributes.isElevated && $0.id != reviewID }) {
				await self.refreshRow(for: demoted.id)
			}

			await self.refreshRow(for: reviewID)
		}
	}

	/// Refetches one review and swaps it into the section, leaving every other row in place.
	///
	/// - Parameter reviewID: The identifier of the changed review.
	@MainActor
	private func refreshRow(for reviewID: KurozoraItemID) async {
		guard let review = try? await KService.review(ReviewIdentity(id: reviewID)).response().data.first else { return }

		if let index = self.reviews.firstIndex(where: { $0.id == reviewID }) {
			self.reviews[index] = review
			self.applyReviewRow(review, for: reviewID)
			return
		}

		// The section carries only written reviews of the item on screen.
		guard review.attributes.description?.isEmpty == false else { return }
		guard review.relationships?.reviewedID == self.writeAReviewContext()?.kind.modelID else { return }

		self.reviews.insert(review, at: 0)
		self.updateDataSource()
	}

	/// Drops the signed in user's review from the reviews section.
	@MainActor
	private func removeSignedInUserReview() {
		guard let userID = User.current?.id else { return }

		let ownReview = self.reviews.first { review in
			review.relationships?.users?.data.first?.id == userID
		}

		guard let ownReview = ownReview else { return }

		self.reviews.removeAll { review in
			review.id == ownReview.id
		}

		// The row leaves before the server confirms the deletion.
		self.applyReviewRow(nil, for: ownReview.id)
	}

	// MARK: Subclass hooks
	/// Fetches the screen's model and dependent sections.
	func fetchDetails() async {}

	/// Returns the context menu displayed by ``moreBarButtonItem``.
	func makeMoreMenu() -> UIMenu? { nil }

	/// Clears any cached rating or review on the model after a review is deleted.
	func didDeleteReview() {}

	/// Swaps the row rendering the given review, or drops it when the review is gone.
	///
	/// - Parameters:
	///    - review: The refreshed review, or `nil` to drop the row.
	///    - reviewID: The identifier of the review whose row to apply.
	@MainActor
	func applyReviewRow(_ review: Review?, for reviewID: KurozoraItemID) {}

	/// Rates the active model with the given value and optional review.
	///
	/// - Parameters:
	///   - rating: The rating applied by the user.
	///   - description: The review text, or `nil`.
	/// - Returns: The rating recorded on the server, or `nil` if the rating failed.
	func rateItem(using rating: Double, description: String?) async throws(APIError) -> Double? {
		#if DEBUG
		fatalError("\(type(of: self)) must override rateItem(using:description:)")
		#else
		return nil
		#endif
	}

	/// Returns the editor configuration for the active model.
	///
	/// - Returns: The review editor context, or `nil` to disable the review flow.
	func writeAReviewContext() -> ReviewEditorContext? { nil }

	/// Presents the review details screen for the given review.
	///
	/// - Parameter review: The review whose details to present.
	func presentReviewDetails(for review: Review) {
		guard let identifier = self.reviewDetailsSegueIdentifier else { return }
		self.present(identifier, sender: review)
	}

	/// Resolves the review backing a ``ReviewCollectionViewCell`` at the given index path.
	///
	/// The base implementation treats `indexPath.item` as a direct offset into ``reviews``.
	/// Subclasses whose reviews section prepends other items — e.g. an editorial row — override
	/// this to resolve through their diffable data source instead.
	///
	/// - Parameter indexPath: The index path of the review cell.
	/// - Returns: The review backing the cell, or `nil`.
	func review(at indexPath: IndexPath) -> Review? {
		return self.reviews[safe: indexPath.item]
	}

	/// Returns the ``Libraryable`` model backing a lockup cell at the given index path.
	///
	/// - Parameters:
	///   - indexPath: The index path of the lockup cell.
	///   - kind: The library kind of the lockup cell.
	/// - Returns: The model whose library state the cell represents, or `nil`.
	func libraryStatusTarget(at indexPath: IndexPath, kind: LibraryKind) -> (any Libraryable)? {
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
				button?.setTitle(L10n.add.uppercased(with: Locale.current), for: .normal)
			}
		)
	}

	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressReminder button: UIButton) async {
		guard let indexPath = self.collectionView.indexPath(for: cell),
		      let show = self.reminderTarget(at: indexPath) else { return }
		await show.toggleReminder(on: self)
		cell.configureReminderButton(for: show.libraryAttributes?.reminderStatus)
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
			do throws(APIError) {
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

	func tapToRateCollectionViewCellDidRequestDetailedReview(_ cell: TapToRateCollectionViewCell) {
		Task { [weak self] in
			guard let self = self else { return }

			let signedIn = await WorkflowController.shared.isSignedIn(on: self)
			guard signedIn, let context = self.writeAReviewContext() else { return }

			await self.presentReviewEditor(using: context, delegate: self)
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

		let deleteRating = { [weak self, weak cell] in
			guard let self = self, let cell = cell else { return }
			Task {
				do throws(APIError) {
					let didDelete = try await kind.deleteRating()
					if didDelete {
						cell.configure(using: nil)
						self.didDeleteReview()
					} else {
						cell.configure(using: previousRating)
						self.presentAlertController(title: L10n.ratingFailed, message: L10n.notAvailableForType)
					}
				} catch {
					cell.configure(using: previousRating)
					self.showRatingFailureAlert(message: error.message)
				}
			}
		}

		guard context.review?.isEmpty == false else {
			deleteRating()
			return
		}

		self.confirmDeleteRating(onConfirm: deleteRating, onCancel: { [weak cell] in
			cell?.configure(using: previousRating)
		})
	}
}

// MARK: - WriteAReviewCollectionViewCellDelegate
extension DetailsCollectionViewController: WriteAReviewCollectionViewCellDelegate {
	func writeAReviewCollectionViewCell(_ cell: WriteAReviewCollectionViewCell, didPress button: UIButton) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard signedIn, let context = self.writeAReviewContext() else { return }

		await self.presentReviewEditor(using: context, delegate: self)
	}
}

// MARK: - ReviewEditorContextProviding
extension DetailsCollectionViewController: ReviewEditorContextProviding {}

// MARK: - ReviewEditorCollectionViewControllerDelegate
extension DetailsCollectionViewController: ReviewEditorCollectionViewControllerDelegate {
	func reviewEditorCollectionViewControllerDidSubmitReview() {
		self.showRatingSuccessAlert()
	}

	func reviewEditorCollectionViewControllerDidDeleteReview() {
		self.didDeleteReview()
		self.removeSignedInUserReview()
	}
}

// MARK: - ReviewCollectionViewCellDelegate
extension DetailsCollectionViewController: ReviewCollectionViewCellDelegate {
	func reviewCollectionViewCell(_ cell: ReviewCollectionViewCell, didPressUserName sender: AnyObject) {
		guard
			let indexPath = self.collectionView.indexPath(for: cell),
			let review = self.review(at: indexPath)
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
			let review = self.review(at: indexPath)
		else { return }
		self.presentReviewDetails(for: review)
	}

	func reviewCollectionViewCellDidTapTranslation(_ cell: ReviewCollectionViewCell) {
		guard #available(iOS 26.4, macCatalyst 26.4, *) else { return }
		guard
			let indexPath = self.collectionView.indexPath(for: cell),
			let review = self.review(at: indexPath)
		else { return }

		TranslationService.shared.toggleTranslation(for: review)
	}

	func reviewCollectionViewCell(_ cell: ReviewCollectionViewCell, didTapTranslationSettings button: UIButton) {
		guard #available(iOS 26.4, macCatalyst 26.4, *) else { return }
		guard
			let indexPath = self.collectionView.indexPath(for: cell),
			let review = self.review(at: indexPath)
		else { return }

		TranslationSettingsViewController.present(for: review, from: button, in: self)
	}

	func reviewCollectionViewCell(_ cell: ReviewCollectionViewCell, didTapVote vote: ReviewVote) {
		guard
			let indexPath = self.collectionView.indexPath(for: cell),
			let review = self.review(at: indexPath)
		else { return }

		Task {
			await review.castVote(vote)
		}
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

	func scrollThumbnailIntoView(for index: Int, animated: Bool) {
		// Every thumbnail lives in the header cell, so the media index is not an item index.
		let indexPath = IndexPath(item: 0, section: 0)
		self.collectionView.safeScrollToItem(at: indexPath, at: .centeredVertically, animated: animated)

		if !animated {
			self.collectionView.layoutIfNeeded()
		}
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
		libraryKind: LibraryKind,
		currentStatus: LibraryStatus,
		button: UIButton,
		target: any Libraryable,
		didAdd: @escaping @MainActor (_ newStatus: LibraryStatus, _ title: String) -> Void,
		didRemove: @escaping @MainActor (_ previousStatus: LibraryStatus) -> Void
	) {
		let oldLibraryStatus = currentStatus

		let actionSheet = UIAlertController.actionSheetWithItems(
			items: LibraryStatus.alertControllerItems(for: libraryKind),
			currentSelection: oldLibraryStatus,
			action: { title, value in
				Task { [weak self] in
					guard let self = self else { return }
					await target.addToLibrary(status: value)
					didAdd(value, title)
					self.configureNavBarButtons()
				}
			}
		)

		if oldLibraryStatus != .none {
			actionSheet.addAction(UIAlertAction(title: L10n.removeFromLibrary, style: .destructive) { _ in
				Task { [weak self] in
					guard let self = self else { return }
					await target.removeFromLibrary()
					didRemove(oldLibraryStatus)
					self.configureNavBarButtons()
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
