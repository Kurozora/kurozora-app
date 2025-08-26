//
//  EpisodeDetailsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/04/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class EpisodeDetailsCollectionViewController: KCollectionViewController, RatingAlertPresentable {
	@IBOutlet weak var moreBarButtonItem: UIBarButtonItem!
	@IBOutlet weak var navigationTitleView: UIView!
	@IBOutlet weak var navigationTitleLabel: UILabel! {
		didSet {
			self.navigationTitleLabel.theme_textColor = KThemePicker.barTitleTextColor.rawValue
		}
	}

	// MARK: - Properties
	var episodeIdentity: EpisodeIdentity? = nil
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
	/// Initialize a new instance of EpisodeDetailsCollectionViewController with the given episode id.
	///
	/// - Parameter episodeID: The episode id to use when initializing the view.
	///
	/// - Returns: an initialized instance of EpisodeDetailsCollectionViewController.
	static func `init`(with episodeID: String) -> EpisodeDetailsCollectionViewController {
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

	// MARK: - Functions
	override func handleRefreshControl() {
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchDetails()
		}
	}

	override func configureEmptyDataView() {
		emptyBackgroundView.configureImageView(image: R.image.empty.episodes()!)
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
		self.moreBarButtonItem.menu = self.episode?.makeContextMenu(in: self, userInfo: [:])
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

	/// Opens the share sheet of the episode.
	@objc func shareEpisode() {
		self.episode?.openShareSheet(on: self)
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
		switch segue.identifier {
		case R.segue.episodeDetailsCollectionViewController.reviewsSegue.identifier:
			// Segue to reviews list
			guard let reviewsCollectionViewController = segue.destination as? ReviewsCollectionViewController else { return }
			reviewsCollectionViewController.listType = .episode(self.episode)
		case R.segue.episodeDetailsCollectionViewController.showDetailsSegue.identifier:
			// Segue to show details
			guard let showDetailsCollectionViewController = segue.destination as? ShowDetailsCollectionViewController else { return }
			if let showIdentity = sender as? ShowIdentity {
				showDetailsCollectionViewController.showIdentity = showIdentity
			} else if let show = sender as? Show {
				showDetailsCollectionViewController.show = show
			}
		case R.segue.episodeDetailsCollectionViewController.seasonsListSegue.identifier:
			// Segue to seasons list
			guard let seasonsListCollectionViewController = segue.destination as? SeasonsListCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			seasonsListCollectionViewController.showIdentity = ShowIdentity(id: show.id)
		case R.segue.episodeDetailsCollectionViewController.episodeDetailsSegue.identifier:
			// Segue to episode details
			guard let episodeDetailsCollectionViewController = segue.destination as? EpisodeDetailsCollectionViewController else { return }
			episodeDetailsCollectionViewController.episode = sender as? Episode
		case R.segue.episodeDetailsCollectionViewController.episodesListSegue.identifier:
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
		self.performSegue(withIdentifier: R.segue.episodeDetailsCollectionViewController.personDetailsSegue.identifier, sender: cell)
	}

	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressCharacterButton button: UIButton) {
		self.performSegue(withIdentifier: R.segue.episodeDetailsCollectionViewController.characterDetailsSegue.identifier, sender: cell)
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

		self.performSegue(withIdentifier: R.segue.episodeDetailsCollectionViewController.showDetailsSegue, sender: showIdentity)
	}

	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressSeasonButton button: UIButton) async {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		guard let seasonIdentity = self.suggestedEpisodes[indexPath.item].relationships?.seasons?.data.first else { return }

		self.performSegue(withIdentifier: R.segue.episodeDetailsCollectionViewController.episodesListSegue, sender: seasonIdentity)
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
		self.performSegue(withIdentifier: reusableView.segueID, sender: reusableView.indexPath)
	}
}

// MARK: - UIScrollViewDelegate
extension EpisodeDetailsCollectionViewController {
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
			case .suggestedEpisodes:
				return ""
			case .sosumi:
				return ""
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
