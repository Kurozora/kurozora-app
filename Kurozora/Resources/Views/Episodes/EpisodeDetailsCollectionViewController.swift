//
//  EpisodeDetailsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/04/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class EpisodeDetailsCollectionViewController: DetailsCollectionViewController, SectionFetchable, TypedSegueHandling {
	// MARK: Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case castListSegue
		case reviewsListSegue
		case showDetailsSegue
		case seasonsListSegue
		case topChartsSegue
		case episodeDetailsSegue
		case episodesListSegue
		case personDetailsSegue
		case characterDetailsSegue
		case reviewDetailsSegue
	}

	// MARK: - Properties
	var episodeIdentity: EpisodeIdentity?

	/// The authenticated user's rating state for the episode.
	var libraryAttributes: LibraryAttributes?

	/// The entity tag of the last applied reviews overlay.
	var reviewsOverlayETag: String?

	var episode: Episode! {
		didSet {
			self.title = self.episode.attributes.title
			if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
				self.navigationItem.largeTitle = ""
			}
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

	var cast: [IndexPath: Cast] = [:]
	var castIdentities: [CastIdentity] = []

	var suggestedEpisodes: [Episode] = []

	var cache: [ItemKind: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	// MARK: - Overridden Properties
	override var emptyStateImage: UIImage? { .Empty.tvPhoto }
	override var emptyStateDetail: String { L10n.noDetailsYet(L10n.episode.lowercased(with: .current)) }

	override var reviewDetailsSegueIdentifier: (any SegueIdentifier)? { SegueIdentifiers.reviewDetailsSegue }

	override var mediaItems: [MediaItem] {
		guard let episode = self.episode else { return [] }
		var items: [MediaItem] = []
		if let posterURL = URL(string: episode.attributes.poster?.url ?? "") {
			items.append(MediaItem(url: posterURL, type: .image, title: episode.attributes.title, description: nil, author: nil, provider: nil, embedHTML: nil, extraInfo: nil))
		}
		if let bannerURL = URL(string: episode.attributes.banner?.url ?? "") {
			items.append(MediaItem(url: bannerURL, type: .image, title: episode.attributes.title, description: nil, author: nil, provider: nil, embedHTML: nil, extraInfo: nil))
		}
		return items
	}

	// MARK: - Initializers
	func callAsFunction(with episodeID: KurozoraItemID) -> EpisodeDetailsCollectionViewController {
		let episodeDetailsCollectionViewController = EpisodeDetailsCollectionViewController()
		episodeDetailsCollectionViewController.episodeIdentity = EpisodeIdentity(id: episodeID)
		return episodeDetailsCollectionViewController
	}

	func callAsFunction(with episode: Episode) -> EpisodeDetailsCollectionViewController {
		let episodeDetailsCollectionViewController = EpisodeDetailsCollectionViewController()
		episodeDetailsCollectionViewController.episode = episode
		return episodeDetailsCollectionViewController
	}

	// MARK: - View Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		self.configureDataSource()
		self.configureNavigationItems()

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchDetails()
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleEpisodeWatchStatusDidUpdate(_:)), name: .KEpisodeWatchStatusDidUpdate, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleUserStateDidChangeRemotely(_:)), name: .KUserStateDidChangeRemotely, object: nil)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		NotificationCenter.default.removeObserver(self, name: .KEpisodeWatchStatusDidUpdate, object: nil)
		NotificationCenter.default.removeObserver(self, name: .KUserStateDidChangeRemotely, object: nil)
	}

	/// Re-fetches the user overlays when another device or the website changes the user's state.
	@objc func handleUserStateDidChangeRemotely(_ notification: NSNotification) {
		Task { @MainActor [weak self] in
			guard let self = self else { return }
			await self.fetchUserOverlays()
			self.configureNavBarButtons()
		}
	}

	// MARK: - Functions
	override func layoutContainerWidthDidChange() {
		self.remeasureCellHeightsNearViewport()
	}

	override func collectionViewWillLayout() {
		self.measureStaleCellHeightsNearViewport()
	}

	override func cellHeightEnvironmentDidChange() {
		self.remeasureAllCellHeights()
	}

	#if DEBUG
	override func measuredItemWidth(forSectionAt section: Int) -> CGFloat? {
		guard let sectionIdentifier = self.snapshot?.sectionIdentifiers[safe: section] else { return nil }

		return self.measuredItemWidth(forSection: sectionIdentifier)
	}
	#endif

	override func fetchDetails() async {
		guard let episodeIdentity = self.episodeIdentity else { return }

		let reviewIdentityRequest = KService.reviews(for: episodeIdentity).cursor(nil).limit(10)
		let suggestionsRequest = KService.suggestions(for: episodeIdentity)

		async let reviewIdentityResponse = reviewIdentityRequest.response()
		async let suggestionsResponse = suggestionsRequest.response()

		if self.episode == nil {
			do {
				let episodeResponse = try await KService.detail(episodeIdentity).response()
				self.episode = episodeResponse.data.first
			} catch {
				print("-----", error.localizedDescription)
			}

			self.configureNavBarButtons()
		} else {
			self.updateDataSource()
			self.configureNavBarButtons()
		}

		guard self.episode != nil else { return }

		await self.fetchUserOverlays()

		do {
			self.reviews = try await reviewIdentityResponse.data
			self.updateDataSource()
		} catch {
			print("-----", error.localizedDescription)
		}

		do {
			let suggestedIdentities = try await suggestionsResponse.data
			let detailedResponse = try await KService.details(suggestedIdentities).response()
			self.suggestedEpisodes = detailedResponse.data
			self.updateDataSource()
		} catch {
			print("-----", error.localizedDescription)
		}
	}

	/// Fetches the auth user's watched and review overlays for the current episode.
	private func fetchUserOverlays() async {
		guard
			let episodeID = self.episode?.id,
			let userID = User.current?.id
		else { return }
		let userIdentity = UserIdentity(id: userID)

		do {
			let requestedIDs = [episodeID.rawValue]
			let cachedETag = WatchedStore.shared.etag(forRequestedIDs: requestedIDs)
			let overlayResult = try await KService
				.watchedOverlay(forUser: userIdentity, episodes: [episodeID])
				.response(ifNoneMatch: cachedETag)

			if case .modified(let watchedResponse, let etag) = overlayResult {
				WatchedStore.shared.apply(watchedResponse.data, requestedIDs: requestedIDs)
				WatchedStore.shared.setETag(etag, forRequestedIDs: requestedIDs)
			}
		} catch {
			print("watchedOverlay fetch failed: \(error.localizedDescription)")
		}

		do {
			let overlayResult = try await KService
				.reviewsOverlay(forUser: userIdentity, kind: .episodes, itemIDs: [episodeID])
				.response(ifNoneMatch: self.reviewsOverlayETag)

			if case .modified(let response, let etag) = overlayResult {
				let reviewEntry = response.data.first?.attributes
				var libraryAttributes = self.libraryAttributes ?? LibraryAttributes()
				libraryAttributes.rating = reviewEntry?.score
				libraryAttributes.review = reviewEntry?.description
				libraryAttributes.note = try? await KService
					.notesOverlay(forUser: userIdentity, kind: .episodes, itemIDs: [episodeID])
					.response().data.first?.attributes.body
				libraryAttributes.isSpoiler = reviewEntry?.isSpoiler
				libraryAttributes.recommendation = reviewEntry?.recommendation
				self.libraryAttributes = libraryAttributes
				self.reviewsOverlayETag = etag
			}
		} catch {
			print("reviewsOverlay fetch failed: \(error.localizedDescription)")
		}

		await MainActor.run { [weak self] in
			self?.updateDataSource()
		}
	}

	override func makeMoreMenu() -> UIMenu? {
		return self.episode?.makeContextMenu(in: self, userInfo: [:], sourceView: nil, barButtonItem: self.moreBarButtonItem)
	}

	override func rateItem(using rating: Double, description: String?) async throws(APIError) -> Double? {
		guard let episode = self.episode else { return nil }
		return try await episode.rate(using: rating, description: description)
	}

	override func writeAReviewContext() -> ReviewEditorContext? {
		guard let episode = self.episode else { return nil }
		return ReviewEditorContext(kind: .episode(episode), rating: self.libraryAttributes?.rating, review: self.libraryAttributes?.review, note: self.libraryAttributes?.note, isSpoiler: self.libraryAttributes?.isSpoiler ?? false, recommendation: self.libraryAttributes?.recommendation)
	}

	override func baseDetailHeaderCollectionViewCell(_ cell: BaseDetailHeaderCollectionViewCell, didPressStatus button: UIButton) async {
		guard await WorkflowController.shared.isSignedIn() else { return }
		guard let episode = self.episode else { return }

		guard !WatchedStore.shared.isPending(forEpisodeID: episode.id.rawValue) else { return }

		defer { self.setWatchStatusPending(false, for: episode) }

		self.setWatchStatusPending(true, for: episode)

		await episode.updateWatchStatus(userInfo: ["indexPath": self.indexPath])
		await LibraryOutbox.shared.flush()
		await self.fetchUserOverlays()
	}

	@objc func handleEpisodeWatchStatusDidUpdate(_ notification: NSNotification) {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }

			if let indexPath = notification.userInfo?["indexPath"] as? IndexPath, let selectedEpisode = self.dataSource.itemIdentifier(for: indexPath) {
				var newSnapshot = self.dataSource.snapshot()
				newSnapshot.reloadItems([selectedEpisode])
				self.dataSource.apply(newSnapshot)
			} else if let episode = self.episode {
				self.setItemKindNeedsUpdate(.episode(episode))
			}

			self.configureNavBarButtons()
		}
	}

	/// Records whether the given episode's watch status change is still settling and redraws its rows.
	///
	/// - Parameters:
	///    - isPending: Whether the change is still settling.
	///    - episode: The episode whose rows are redrawn.
	func setWatchStatusPending(_ isPending: Bool, for episode: Episode) {
		WatchedStore.shared.setPending(isPending, forEpisodeID: episode.id.rawValue)
		self.setItemKindsNeedUpdate([.episode(episode), .suggestedEpisode(episode)])
	}

	override func didDeleteReview() {
		self.libraryAttributes?.rating = nil
		self.libraryAttributes?.review = nil
	}

	override func applyReviewRow(_ review: Review?, for reviewID: KurozoraItemID) {
		guard self.snapshot != nil else { return }

		let staleItem = self.snapshot.itemIdentifiers.first { item in
			switch item {
			case .review(let candidate):
				return candidate.id == reviewID
			default:
				return false
			}
		}

		guard let staleItem = staleItem else { return }

		if let review = review {
			if let index = self.reviews.firstIndex(where: { $0.id == reviewID }) {
				self.reviews[index] = review
			}

			self.snapshot.reconfigureItems([staleItem])
		} else {
			self.reviews.removeAll { $0.id == reviewID }

			let section = self.snapshot.sectionIdentifier(containingItem: staleItem)
			self.snapshot.deleteItems([staleItem])

			// An emptied section leaves with its row.
			if let section = section, self.snapshot.numberOfItems(inSection: section) == 0 {
				self.snapshot.deleteSections([section])
			}
		}

		if self.snapshot.indexOfSection(.reviews) != nil {
			self.setMeasuredItems(self.snapshot.itemIdentifiers(inSection: .reviews), for: .reviews)
		} else {
			self.removeMeasuredSections(notIn: self.snapshot.sectionIdentifiers)
		}

		if review != nil {
			self.measureCellHeights(of: [staleItem])
		}

		self.dataSource.apply(self.snapshot, animatingDifferences: review == nil)
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .reviewsListSegue: return ReviewsListCollectionViewController()
		case .showDetailsSegue: return ShowDetailsCollectionViewController()
		case .seasonsListSegue: return SeasonsListCollectionViewController()
		case .topChartsSegue: return EpisodesListCollectionViewController()
		case .episodeDetailsSegue: return EpisodeDetailsCollectionViewController()
		case .episodesListSegue: return EpisodesListCollectionViewController()
		case .castListSegue: return CastListCollectionViewController()
		case .characterDetailsSegue: return CharacterDetailsCollectionViewController()
		case .personDetailsSegue: return PersonDetailsCollectionViewController()
		case .reviewDetailsSegue: return KNavigationController(rootViewController: ReviewDetailsCollectionViewController())
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .reviewsListSegue:
			guard let reviewsCollectionViewController = destination as? ReviewsListCollectionViewController else { return }
			reviewsCollectionViewController.listType = .episode(self.episode)
			reviewsCollectionViewController.givenRating = self.libraryAttributes?.rating
			reviewsCollectionViewController.givenReview = self.libraryAttributes?.review
			reviewsCollectionViewController.givenNote = self.libraryAttributes?.note
			reviewsCollectionViewController.givenIsSpoiler = self.libraryAttributes?.isSpoiler ?? false
			reviewsCollectionViewController.givenRecommendation = self.libraryAttributes?.recommendation
		case .showDetailsSegue:
			guard let showDetailsCollectionViewController = destination as? ShowDetailsCollectionViewController else { return }
			if let showIdentity = sender as? ShowIdentity {
				showDetailsCollectionViewController.showIdentity = showIdentity
			} else if let show = sender as? Show {
				showDetailsCollectionViewController.show = show
			}
		case .seasonsListSegue:
			guard let seasonsListCollectionViewController = destination as? SeasonsListCollectionViewController else { return }
			guard let showIdentity = sender as? ShowIdentity else { return }
			seasonsListCollectionViewController.showIdentity = showIdentity
		case .topChartsSegue:
			guard let episodesListCollectionViewController = destination as? EpisodesListCollectionViewController else { return }
			episodesListCollectionViewController.episodesListFetchType = .charts
		case .episodeDetailsSegue:
			guard let episodeDetailsCollectionViewController = destination as? EpisodeDetailsCollectionViewController else { return }
			episodeDetailsCollectionViewController.episode = sender as? Episode
		case .episodesListSegue:
			guard let episodesListCollectionViewController = destination as? EpisodesListCollectionViewController else { return }
			guard let seasonIdentity = sender as? SeasonIdentity else { return }
			episodesListCollectionViewController.seasonIdentity = seasonIdentity
			episodesListCollectionViewController.episodesListFetchType = .season
		case .castListSegue: break
		case .characterDetailsSegue: break
		case .personDetailsSegue: break
		case .reviewDetailsSegue:
			guard
				let navigationController = destination as? KNavigationController,
				let reviewDetailsCollectionViewController = navigationController.viewControllers.first as? ReviewDetailsCollectionViewController,
				let review = sender as? Review
			else { return }
			navigationController.modalPresentationStyle = .formSheet
			reviewDetailsCollectionViewController.review = review
		}
	}
}

// MARK: - Measurement
extension EpisodeDetailsCollectionViewController {
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .castIdentity(let id): return id as? Element
		default: return nil
		}
	}

	func measuredItemWidth(for section: SectionLayoutKind, containerWidth: CGFloat) -> CGFloat? {
		switch section {
		case .reviews, .cast:
			let columns = self.columnCount(forSection: section, width: containerWidth)

			return Layouts.itemWidth(columns: columns, containerWidth: containerWidth, isHorizontal: true)
		default:
			return nil
		}
	}

	func measurableItem(for itemKind: ItemKind, in _: SectionLayoutKind) -> CellHeightMeasurer.Item? {
		switch itemKind {
		case .review(let review):
			return ReviewCollectionViewCell.measurableItem(for: self.reviews.first { $0.id == review.id } ?? review)
		case .castIdentity:
			return self.castMeasurableItem(for: itemKind)
		default:
			return nil
		}
	}

	/// Returns the item that measures the given item's cast cell.
	///
	/// - Parameter itemKind: The item whose cell is measured.
	///
	/// - Returns: The item that measures the cell.
	private func castMeasurableItem(for itemKind: ItemKind) -> CellHeightMeasurer.Item {
		let cast = self.dataSource.indexPath(for: itemKind).flatMap { self.cast[$0] }

		guard let cast = cast else {
			return CellHeightMeasurer.Item(cellType: CastCollectionViewCell.self, isSkeleton: true) { cell in
				cell.configure(using: nil as Cast?)
			}
		}

		return CastCollectionViewCell.measurableItem(for: cast)
	}
}

// MARK: - CastCollectionViewCellDelegate
extension EpisodeDetailsCollectionViewController: CastCollectionViewCellDelegate {
	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressPersonButton button: UIButton) {
		self.show(.personDetailsSegue, sender: cell)
	}

	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressCharacterButton button: UIButton) {
		self.show(.characterDetailsSegue, sender: cell)
	}
}

// MARK: - EpisodeLockupCollectionViewCellDelegate
extension EpisodeDetailsCollectionViewController: EpisodeLockupCollectionViewCellDelegate {
	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressWatchStatusButton button: UIButton) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard signedIn else { return }
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }

		let suggestedEpisode = self.suggestedEpisodes[indexPath.item]
		guard !WatchedStore.shared.isPending(forEpisodeID: suggestedEpisode.id.rawValue) else { return }

		defer { self.setWatchStatusPending(false, for: suggestedEpisode) }

		self.setWatchStatusPending(true, for: suggestedEpisode)

		await suggestedEpisode.updateWatchStatus(userInfo: ["indexPath": indexPath])
		await LibraryOutbox.shared.flush()

		if suggestedEpisode.id == self.episode.id {
			self.configureNavBarButtons()
		}
	}

	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressShowButton button: UIButton) async {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		guard let showIdentity = self.suggestedEpisodes[indexPath.item].relationships?.shows?.data.first else { return }

		self.show(.showDetailsSegue, sender: showIdentity)
	}

	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressSeasonButton button: UIButton) async {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		guard let seasonIdentity = self.suggestedEpisodes[indexPath.item].relationships?.seasons?.data.first else { return }

		self.show(.episodesListSegue, sender: seasonIdentity)
	}
}

// MARK: - TextViewCollectionViewCellDelegate
extension EpisodeDetailsCollectionViewController: TextViewCollectionViewCellDelegate {
	func textViewCollectionViewCell(_ cell: TextViewCollectionViewCell, didPressButton button: UIButton) {
		let synopsisViewController = SynopsisViewController()
		synopsisViewController.title = cell.textViewCollectionViewCellType.stringValue
		synopsisViewController.synopsis = self.episode.attributes.synopsis

		let kNavigationController = KNavigationController(rootViewController: synopsisViewController)
		kNavigationController.modalPresentationStyle = .formSheet

		self.present(kNavigationController, animated: true)
	}
}

extension EpisodeDetailsCollectionViewController {
	enum SectionLayoutKind: Int, CaseIterable {
		// MARK: - Cases
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
				return L10n.header
			case .badge:
				return L10n.badges
			case .synopsis:
				return L10n.synopsis
			case .rating:
				return L10n.ratingsAndReviews
			case .rateAndReview:
				return ""
			case .reviews:
				return ""
			case .information:
				return L10n.information
			case .cast:
				return L10n.cast
			case .suggestedEpisodes:
				return L10n.seeAlso
			case .sosumi:
				return L10n.copyright
			}
		}

		/// The string value of a section type segue identifier.
		var segueIdentifier: SegueIdentifiers? {
			switch self {
			case .header, .badge, .synopsis, .rateAndReview, .reviews, .information, .suggestedEpisodes, .sosumi:
				return nil
			case .rating:
				return .reviewsListSegue
			case .cast:
				return .castListSegue
			}
		}
	}

	/// List of available item kind types.
	enum ItemKind: nonisolated Hashable {
		// MARK: - Cases
		/// An item kind that contains an `Episode` object.
		case episode(_: Episode)

		/// An item kind that contains a badge row.
		case badge(_: EpisodeDetail.Badge)

		/// An item kind that contains the episode's synopsis.
		case synopsis

		/// An item kind that contains a rating row.
		case rating(_: EpisodeDetail.Rating)

		/// An item kind that contains a rate and review row.
		case rateAndReview(_: EpisodeDetail.RateAndReview)

		/// An item kind that contains a `Review` object.
		case review(_: Review)

		/// An item kind that contains an information row.
		case information(_: EpisodeDetail.Information)

		/// An item kind that contains a `CastIdentity` object.
		case castIdentity(_: CastIdentity)

		/// An item kind that contains a suggested `Episode` object.
		case suggestedEpisode(_: Episode)
	}
}
