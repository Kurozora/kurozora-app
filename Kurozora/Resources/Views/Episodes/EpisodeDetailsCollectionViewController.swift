//
//  EpisodeDetailsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/04/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class EpisodeDetailsCollectionViewController: KCollectionViewController, RatingAlertPresentable {
	// MARK: Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case castListSegue
		case reviewsSegue
		case showDetailsSegue
		case seasonsListSegue
		case episodeDetailsSegue
		case episodesListSegue
		case personDetailsSegue
		case characterDetailsSegue
	}

	// MARK: - IBOutlets
	@IBOutlet weak var moreBarButtonItem: UIBarButtonItem!
	@IBOutlet weak var navigationTitleView: UIView!
	@IBOutlet weak var navigationTitleLabel: UILabel! {
		didSet {
			self.navigationTitleLabel.theme_textColor = KThemePicker.barTitleTextColor.rawValue
		}
	}

	// MARK: - Properties
	var episodeIdentity: EpisodeIdentity?
	var episode: Episode! {
		didSet {
			self.title = self.episode.attributes.title
			self.navigationTitleLabel.text = self.episode.attributes.title
			self.episodeIdentity = EpisodeIdentity(id: self.episode.id)

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

	var indexPath = IndexPath()

	// Review properties.
	var reviews: [Review] = []

	// Cast properties.
	var cast: [IndexPath: Cast] = [:]
	var castIdentities: [CastIdentity] = []

	// Suggested episodes properties.
	var suggestedEpisodes: [Episode] = []

	/// The first cell's size.
	private var firstCellSize: CGSize = .zero

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

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
	/// Initialize a new instance of EpisodeDetailsCollectionViewController with the given episode id.
	///
	/// - Parameter episodeID: The episode id to use when initializing the view.
	///
	/// - Returns: an initialized instance of EpisodeDetailsCollectionViewController.
	static func `init`(with episodeID: KurozoraItemID) -> EpisodeDetailsCollectionViewController {
		if let episodeDetailsCollectionViewController = R.storyboard.episodes.episodeDetailsCollectionViewController() {
			episodeDetailsCollectionViewController.episodeIdentity = EpisodeIdentity(id: episodeID)
			return episodeDetailsCollectionViewController
		}

		fatalError("Failed to instantiate EpisodeDetailsCollectionViewController with the given show id.")
	}

	/// Initialize a new instance of EpisodeDetailsCollectionViewController with the given episode object.
	///
	/// - Parameter episode: The `Episode` object to use when initializing the view controller.
	///
	/// - Returns: an initialized instance of EpisodeDetailsCollectionViewController.
	static func `init`(with episode: Episode) -> EpisodeDetailsCollectionViewController {
		if let episodeDetailsCollectionViewController = R.storyboard.episodes.episodeDetailsCollectionViewController() {
			episodeDetailsCollectionViewController.episode = episode
			return episodeDetailsCollectionViewController
		}

		fatalError("Failed to instantiate EpisodeDetailsCollectionViewController with the given Show object.")
	}

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		self.handleRefreshControl()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.navigationTitleLabel.alpha = 0

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
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleEpisodeWatchStatusDidUpdate(_:)), name: .KEpisodeWatchStatusDidUpdate, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.deleteReview(_:)), name: .KReviewDidDelete, object: nil)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		NotificationCenter.default.removeObserver(self, name: .KEpisodeWatchStatusDidUpdate, object: nil)
		NotificationCenter.default.removeObserver(self, name: .KReviewDidDelete, object: nil)
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
		emptyBackgroundView.configureImageView(image: .Empty.episodes)
		emptyBackgroundView.configureLabels(title: "No Details", detail: "This episode doesn't have details yet. Please check back again later.")

		collectionView.backgroundView?.alpha = 0
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
		self.moreBarButtonItem.menu = self.episode?.makeContextMenu(in: self, userInfo: [:], sourceView: nil, barButtonItem: self.moreBarButtonItem)
	}

	func fetchDetails() async {
		guard let episodeIdentity = self.episodeIdentity else { return }

		if self.episode == nil {
			do {
				let episodeResponse = try await KService.getDetails(forEpisode: episodeIdentity).value
				self.episode = episodeResponse.data.first
			} catch {
				print("-----", error.localizedDescription)
			}

			self.configureNavBarButtons()
		} else {
			self.updateDataSource()
			self.configureNavBarButtons()
		}

		do {
			let reviewIdentityResponse = try await KService.getReviews(forEpisode: episodeIdentity, next: nil, limit: 10).value
			self.reviews = reviewIdentityResponse.data
			self.updateDataSource()
		} catch {
			print("-----", error.localizedDescription)
		}

		do {
			let episodeResponse = try await KService.getSuggestions(forEpisode: episodeIdentity).value
			self.suggestedEpisodes = episodeResponse.data
			self.updateDataSource()
		} catch {
			print("-----", error.localizedDescription)
		}
	}

	/// Handles the episode watch status update notification.
	///
	/// - Parameters:
	///    - notification: An object containing information broadcast to registered observers that bridges to Notification.
	@objc func handleEpisodeWatchStatusDidUpdate(_ notification: NSNotification) {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }

			if let indexPath = notification.userInfo?["indexPath"] as? IndexPath, let selectedEpisode = self.dataSource.itemIdentifier(for: indexPath) {
				var newSnapshot = self.dataSource.snapshot()
				newSnapshot.reloadItems([selectedEpisode])
				self.dataSource.apply(newSnapshot)
			} else {
				self.snapshot.reloadSections([.header])
			}

			self.configureNavBarButtons()
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

			self.episode.attributes.givenRating = nil
			self.episode.attributes.givenReview = nil
		}
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
			reviewsCollectionViewController.listType = .episode(self.episode)
		case .showDetailsSegue:
			// Segue to show details
			guard let showDetailsCollectionViewController = segue.destination as? ShowDetailsCollectionViewController else { return }
			if let showIdentity = sender as? ShowIdentity {
				showDetailsCollectionViewController.showIdentity = showIdentity
			} else if let show = sender as? Show {
				showDetailsCollectionViewController.show = show
			}
		case .seasonsListSegue:
			// Segue to seasons list
			guard let seasonsListCollectionViewController = segue.destination as? SeasonsListCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			seasonsListCollectionViewController.showIdentity = ShowIdentity(id: show.id)
		case .episodeDetailsSegue:
			// Segue to episode details
			guard let episodeDetailsCollectionViewController = segue.destination as? EpisodeDetailsCollectionViewController else { return }
			episodeDetailsCollectionViewController.episode = sender as? Episode
		case .episodesListSegue:
			// Segue to episode details
			guard let episodesListCollectionViewController = segue.destination as? EpisodesListCollectionViewController else { return }
			guard let seasonIdentity = sender as? SeasonIdentity else { return }
			episodesListCollectionViewController.seasonIdentity = seasonIdentity
			episodesListCollectionViewController.episodesListFetchType = .season
		default: break
		}
	}
}

// MARK: - CastCollectionViewCellDelegate
extension EpisodeDetailsCollectionViewController: CastCollectionViewCellDelegate {
	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressPersonButton button: UIButton) {
		self.performSegue(withIdentifier: SegueIdentifiers.personDetailsSegue, sender: cell)
	}

	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressCharacterButton button: UIButton) {
		self.performSegue(withIdentifier: SegueIdentifiers.characterDetailsSegue, sender: cell)
	}
}

// MARK: - EpisodeLockupCollectionViewCellDelegate
extension EpisodeDetailsCollectionViewController: EpisodeLockupCollectionViewCellDelegate {
	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressWatchStatusButton button: UIButton) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard signedIn else { return }
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }

		cell.watchStatusButton.isEnabled = false
		let suggestedEpisode = self.suggestedEpisodes[indexPath.item]
		await suggestedEpisode.updateWatchStatus(userInfo: ["indexPath": indexPath])
		cell.watchStatusButton.isEnabled = true

		// Update the nav bar buttons if the suggested episode is the same as the current episode.
		if suggestedEpisode.id == self.episode.id {
			self.configureNavBarButtons()
		}
	}

	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressShowButton button: UIButton) async {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		guard let showIdentity = self.suggestedEpisodes[indexPath.item].relationships?.shows?.data.first else { return }

		self.performSegue(withIdentifier: SegueIdentifiers.showDetailsSegue, sender: showIdentity)
	}

	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressSeasonButton button: UIButton) async {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		guard let seasonIdentity = self.suggestedEpisodes[indexPath.item].relationships?.seasons?.data.first else { return }

		self.performSegue(withIdentifier: SegueIdentifiers.episodesListSegue, sender: seasonIdentity)
	}
}

// MARK: - TextViewCollectionViewCellDelegate
extension EpisodeDetailsCollectionViewController: TextViewCollectionViewCellDelegate {
	func textViewCollectionViewCell(_ cell: TextViewCollectionViewCell, didPressButton button: UIButton) {
		if let synopsisKNavigationController = R.storyboard.synopsis.instantiateInitialViewController() {
			if let synopsisViewController = synopsisKNavigationController.viewControllers.first as? SynopsisViewController {
				synopsisViewController.title = cell.textViewCollectionViewCellType.stringValue
				synopsisViewController.synopsis = self.episode.attributes.synopsis
			}
			synopsisKNavigationController.modalPresentationStyle = .fullScreen
			self.present(synopsisKNavigationController, animated: true)
		}
	}
}

// MARK: - TitleHeaderCollectionReusableViewDelegate
extension EpisodeDetailsCollectionViewController: TitleHeaderCollectionReusableViewDelegate {
	func titleHeaderCollectionReusableView(_ reusableView: TitleHeaderCollectionReusableView, didPress button: UIButton) {
		guard let segueID = reusableView.segueID else { return }
		self.performSegue(withIdentifier: segueID, sender: reusableView.indexPath)
	}
}

// MARK: - UIScrollViewDelegate
extension EpisodeDetailsCollectionViewController {
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
		if let episodeHeaderCell = firstCell as? EpisodeDetailHeaderCollectionViewCell {
			var newFrame = episodeHeaderCell.frame

			if self.firstCellSize.width != episodeHeaderCell.frame.size.width {
				self.firstCellSize = episodeHeaderCell.frame.size
			}

			if offset < 0 {
				newFrame.origin.y = offset
				newFrame.size.height = self.firstCellSize.height - offset
				episodeHeaderCell.frame = newFrame
			} else {
				newFrame.origin.y = 0
				newFrame.size.height = self.firstCellSize.height
				episodeHeaderCell.frame = newFrame
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

// MARK: - ReviewCollectionViewCellDelegate
extension EpisodeDetailsCollectionViewController: ReviewCollectionViewCellDelegate {
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
extension EpisodeDetailsCollectionViewController: TapToRateCollectionViewCellDelegate {
	func tapToRateCollectionViewCell(_ cell: TapToRateCollectionViewCell, rateWith rating: Double) {
		Task { [weak self] in
			guard let self = self else { return }

			do throws(KKAPIError) {
				let rating = try await self.episode.rate(using: rating, description: nil)
				cell.configure(using: rating)

				if rating != nil {
					self.showRatingSuccessAlert()
				}
			} catch {
				cell.configure(using: nil)
				self.showRatingFailureAlert(message: error.message)
			}
		}
	}
}

// MARK: - WriteAReviewCollectionViewCellDelegate
extension EpisodeDetailsCollectionViewController: WriteAReviewCollectionViewCellDelegate {
	func writeAReviewCollectionViewCell(_ cell: WriteAReviewCollectionViewCell, didPress button: UIButton) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard signedIn else { return }

		let reviewTextEditorViewController = ReviewTextEditorViewController()
		reviewTextEditorViewController.delegate = self
		reviewTextEditorViewController.router?.dataStore?.kind = .episode(self.episode)
		reviewTextEditorViewController.router?.dataStore?.rating = self.episode.attributes.givenRating
		reviewTextEditorViewController.router?.dataStore?.review = nil

		let navigationController = KNavigationController(rootViewController: reviewTextEditorViewController)
		navigationController.presentationController?.delegate = reviewTextEditorViewController
		self.present(navigationController, animated: true)
	}
}

// MARK: - ReviewTextEditorViewControllerDelegate
extension EpisodeDetailsCollectionViewController: ReviewTextEditorViewControllerDelegate {
	func reviewTextEditorViewControllerDidSubmitReview() {
		self.showRatingSuccessAlert()
	}
}

extension EpisodeDetailsCollectionViewController: MediaTransitionDelegate {
	func imageViewForMedia(at index: Int) -> UIImageView? {
		// TODO: Refactor
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
extension EpisodeDetailsCollectionViewController: BaseDetailHeaderCollectionViewCellDelegate {
	func baseDetailHeaderCollectionViewCell(_ cell: BaseDetailHeaderCollectionViewCell, didTapImage imageView: UIImageView, at index: Int) {
		let posterURL = URL(string: self.episode.attributes.poster?.url ?? "")
		let bannerURL = URL(string: self.episode.attributes.banner?.url ?? "")
		var items: [MediaItemV2] = []

		if let posterURL = posterURL {
			items.append(MediaItemV2(
				url: posterURL,
				type: .image,
				title: self.episode.attributes.title,
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
				title: self.episode.attributes.title,
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
		guard await WorkflowController.shared.isSignedIn() else { return }

		button.isEnabled = false
		await self.episode?.updateWatchStatus(userInfo: ["indexPath": self.indexPath])
		button.isEnabled = true
	}
}

extension EpisodeDetailsCollectionViewController {
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
		case suggestedEpisodes
		case sosumi

		// MARK: - Properties
		/// The string value of a section type.
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
			case .suggestedEpisodes:
				return Trans.seeAlso
			case .sosumi:
				return Trans.copyright
			}
		}

		/// The string value of a section type segue identifier.
		var segueIdentifier: SegueIdentifiers? {
			switch self {
			case .header, .badge, .synopsis, .rateAndReview, .reviews, .information, .suggestedEpisodes, .sosumi:
				return nil
			case .rating:
				return .reviewsSegue
			case .cast:
				return .castListSegue
			}
		}
	}

	/// List of available Item Kind types.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `Episode` object.
		case episode(_: Episode, id: UUID = UUID())

		/// Indicates the item kind contains a `Review` object.
		case review(_: Review, id: UUID = UUID())

		/// Indicates the item kind contains a `CastIdentity` object.
		case castIdentity(_: CastIdentity, id: UUID = UUID())

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .episode(let episode, let id):
				hasher.combine(episode)
				hasher.combine(id)
			case .review(let review, let id):
				hasher.combine(review)
				hasher.combine(id)
			case .castIdentity(let castIdentity, let id):
				hasher.combine(castIdentity)
				hasher.combine(id)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.episode(let episode1, let id1), .episode(let episode2, let id2)):
				return episode1 == episode2 && id1 == id2
			case (.review(let review1, let id1), .review(let review2, let id2)):
				return review1 == review2 && id1 == id2
			case (.castIdentity(let castIdentity1, let id1), .castIdentity(let castIdentity2, let id2)):
				return castIdentity1 == castIdentity2 && id1 == id2
			default:
				return false
			}
		}
	}
}
