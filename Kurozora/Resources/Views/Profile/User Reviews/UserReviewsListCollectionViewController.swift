//
//  UserReviewsListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/03/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import AVFoundation
import Combine

class UserReviewsListCollectionViewController: KCollectionViewController, SectionFetchable, TypedSegueHandling {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case characterDetailsSegue
		case episodeDetailsSegue
		case gameDetailsSegue
		case literatureDetailsSegue
		case personDetailsSegue
		case showDetailsSegue
		case songDetailsSegue
		case studioDetailsSegue
	}

	// MARK: - Properties
	var user: User?
	var reviews: [Review] = []

	var cache: [ItemKind: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []
	var isFetchingType: Set<String> = []
	var fetchGeneration: Int = 0

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>! = nil
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>! = nil

	/// The object that provides the interface to control the player’s transport behavior.
	var player: AVPlayer?

	/// The subscription to playback state changes.
	private var playbackObserver: AnyCancellable?

	/// The index path of the song that's currently playing.
	var currentPlayerIndexPath: IndexPath?

	/// The next page url of the pagination.
	var nextPageCursor: PageCursor?

	/// Whether a fetch request is currently in progress.
	var isRequestInProgress: Bool = false

	/// The chips that filter the list by kind.
	private let chipsView = KChipsView()

	/// The button presenting the sort menu.
	private var sortBarButtonItem: UIBarButtonItem!

	/// The button presenting the filter page.
	var filterBarButtonItem: UIBarButtonItem!

	/// The chips listing the applied filters.
	let filterChipsView = KFilterChipsView()

	/// The chips the applied filters show.
	var appliedFilterChips: [FilterChip] = []

	/// The kind the list is limited to.
	private var selectedKind: ReviewKind?

	/// The filter values applied to the list.
	var filterValues: [FilterKey: FilterValue] = [:]

	/// The sort type applied to the list.
	private var selectedSortType: ReviewSortType?

	/// The sort option refining the sort type.
	private var selectedSortOption: ReviewSortOption?

	/// The filters the list offers.
	var filterDescriptors: [FilterDescriptor] {
		return [
			FilterDescriptor(key: .hasReview, title: L10n.reviewFilterContent, control: .booleanPills(trueTitle: L10n.reviewFilterWithReview, falseTitle: L10n.reviewFilterRatingsOnly)),
			FilterDescriptor(key: .rating, title: L10n.rating, control: .stars)
		]
	}

	/// Whether the list keeps ratings with or without a written review.
	private var hasReviewFilter: Bool? {
		switch self.filterValues[.hasReview] {
		case .boolean(let hasReview):
			return hasReview
		default:
			return nil
		}
	}

	/// The star rating the list is limited to.
	private var ratingFilter: Double? {
		switch self.filterValues[.rating] {
		case .rating(let rating):
			return rating
		default:
			return nil
		}
	}

	/// Whether a filter narrows the list.
	private var isFiltering: Bool {
		return !self.filterValues.isEmpty
	}

	/// Whether a kind, filter, or sort shapes the list.
	private var isNarrowed: Bool {
		return self.selectedKind != nil || self.isFiltering || self.selectedSortType != nil
	}

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

	// MARK: - Views
	override func viewWillReload() {
		super.viewWillReload()

		self.handleRefreshControl()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = L10n.ratingsAndReviews
		self.configureNavigationItems()
		self.configureChipsView()

		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		// Add Refresh Control to Collection View
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshItems(L10n.reviews.lowercased(with: Locale.current)))
		#endif

		self.configureDataSource()
		self.observePlaybackChanges()

		NotificationCenter.default.addObserver(self, selector: #selector(self.handleReviewDidUpdate(_:)), name: .KReviewDidUpdate, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleReviewDidDelete(_:)), name: .KReviewDidDelete, object: nil)

		// Fetch follow list.
		if !self.reviews.isEmpty {
			self.endFetch()
		} else {
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchReviews()
			}
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		self.player?.pause()
	}

	// MARK: - Functions
	/// Configures the sort and filter bar button items.
	private func configureNavigationItems() {
		self.sortBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down.circle"))
		self.sortBarButtonItem.accessibilityLabel = L10n.sort

		self.filterBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle"), style: .plain, target: self, action: #selector(self.handleFilterBarButtonItemPressed(_:)))
		self.filterBarButtonItem.accessibilityLabel = L10n.filter

		self.rebuildSortMenu()

		self.navigationItem.rightBarButtonItems = [self.filterBarButtonItem, self.sortBarButtonItem]
	}

	/// Configures the chips that filter the list by kind and the chips listing the applied filters.
	private func configureChipsView() {
		self.filterChipsView.chipRemovedHandler = { [weak self] index in
			guard let self = self else { return }

			self.removeFilterChip(at: index)
		}

		self.chipsView.titles = [L10n.all] + ReviewKind.listOrder.map { kind in
			kind.title
		}
		self.chipsView.chipSelectedHandler = { [weak self] index in
			guard let self = self else { return }

			self.selectedKind = ReviewKind.listOrder[safe: index - 1]
			self.reloadForQueryChange()
		}

		self.navigationItem.setBottomPalette(contentView: self.chipsView, height: KChipsView.paletteHeight)
	}

	/// Rebuilds the sort menu to reflect the selected sort.
	private func rebuildSortMenu() {
		var menuItems: [UIMenuElement] = ReviewSortType.allCases.map { sortType in
			let sortTypeSelected = self.selectedSortType == sortType
			let subMenuItems = sortType.optionValue.map { option in
				let actionIsOn = sortTypeSelected && self.selectedSortOption == option

				return UIAction(title: option.title, image: option.imageValue, state: actionIsOn ? .on : .off) { [weak self] _ in
					guard let self = self, !actionIsOn else { return }

					self.sort(by: sortType, option: option)
				}
			}

			return UIMenu(title: sortType.title, image: sortType.imageValue, children: subMenuItems)
		}

		if self.selectedSortType != nil {
			let stopSortingAction = UIAction(title: L10n.stopSorting, image: UIImage(systemName: "xmark.circle.fill"), attributes: .destructive) { [weak self] _ in
				guard let self = self else { return }

				self.sort(by: nil, option: nil)
			}
			let stopSortingMenu = UIMenu(title: "", options: .displayInline, children: [stopSortingAction])

			menuItems.append(stopSortingMenu)
		}

		self.sortBarButtonItem.image = UIImage(systemName: self.selectedSortType == nil ? "arrow.up.arrow.down.circle" : "arrow.up.arrow.down.circle.fill")
		self.sortBarButtonItem.menu = UIMenu(title: "", children: menuItems)
	}

	/// Sorts the list by the given type and option.
	///
	/// - Parameters:
	///    - sortType: The sort type to apply.
	///    - option: The sort option refining the sort type.
	private func sort(by sortType: ReviewSortType?, option: ReviewSortOption?) {
		self.selectedSortType = sortType
		self.selectedSortOption = option

		self.rebuildSortMenu()
		self.reloadForQueryChange()
	}

	/// Presents the filter page.
	///
	/// - Parameter sender: The button the page is anchored to.
	@objc private func handleFilterBarButtonItemPressed(_ sender: UIBarButtonItem) {
		let searchFilterCollectionViewController = SearchFilterCollectionViewController()
		searchFilterCollectionViewController.delegate = self
		searchFilterCollectionViewController.descriptors = self.filterDescriptors
		searchFilterCollectionViewController.values = self.filterValues

		let kNavigationController = KNavigationController(rootViewController: searchFilterCollectionViewController)
		kNavigationController.modalPresentationStyle = .popover
		kNavigationController.popoverPresentationController?.barButtonItem = sender
		kNavigationController.navigationBar.prefersLargeTitles = false

		self.present(kNavigationController, animated: true)
	}

	/// Reloads the list from the first page.
	func reloadForQueryChange() {
		self.nextPageCursor = nil
		self.reviews = []
		self.cache.removeAll()
		self.isFetchingType.removeAll()
		self.fetchGeneration += 1
		self.isRequestInProgress = false
		self.updateDataSource()
		self.configureEmptyDataView()
		self._prefersActivityIndicatorHidden = false

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchReviews()
		}
	}

	/// Re-renders the changed review without refetching the list.
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

	/// Refetches one review and swaps it into the loaded list, leaving every other row in place.
	///
	/// - Parameter reviewID: The identifier of the changed review.
	@MainActor
	private func refreshRow(for reviewID: KurozoraItemID) async {
		let index = self.reviews.firstIndex { $0.id == reviewID }

		// An unloaded review joins only the reviewer's own list.
		guard index != nil || self.user?.id == User.current?.id else { return }
		guard let review = try? await KService.review(ReviewIdentity(id: reviewID)).response().data.first else { return }

		guard let index = index else {
			// A narrowed list places the review by its kind, filters, and sort options.
			guard !self.isNarrowed else {
				self.reloadForQueryChange()
				return
			}

			// The list carries only written reviews.
			guard review.attributes.description?.isEmpty == false else { return }

			self.insertRow(for: review)
			return
		}

		self.reviews[index] = review
		self.replaceRow(for: reviewID, with: review)
	}

	/// Inserts a newly written review at the top of the loaded list.
	///
	/// - Parameter review: The review to insert.
	@MainActor
	private func insertRow(for review: Review) {
		self.reviews.insert(review, at: 0)

		// The insert shifts the index paths the model cache is keyed by.
		self.cache.removeAll()

		// An empty list has no section to insert into.
		guard self.snapshot != nil, let firstItem = self.snapshot.itemIdentifiers(inSection: .main).first else {
			self.updateDataSource()
			self.toggleEmptyDataView()
			return
		}

		self.snapshot.insertItems([.review(review)], beforeItem: firstItem)
		self.dataSource.apply(self.snapshot, animatingDifferences: true)
		self.toggleEmptyDataView()
	}

	/// Replaces the row rendering the given review with one rendering its refreshed value.
	///
	/// - Parameters:
	///    - reviewID: The identifier of the review whose row to replace.
	///    - review: The refreshed review.
	@MainActor
	private func replaceRow(for reviewID: KurozoraItemID, with review: Review) {
		guard self.snapshot != nil else { return }

		let items = self.snapshot.itemIdentifiers(inSection: .main)

		guard let index = items.firstIndex(where: { $0.review?.id == reviewID }) else { return }

		// The identifier is the review's identity, so the stale row leaves before its replacement.
		let successor = items.indices.contains(index + 1) ? items[index + 1] : nil
		self.snapshot.deleteItems([items[index]])

		if let successor = successor {
			self.snapshot.insertItems([.review(review)], beforeItem: successor)
		} else {
			self.snapshot.appendItems([.review(review)], toSection: .main)
		}

		self.dataSource.apply(self.snapshot, animatingDifferences: false)
	}

	/// Drops the deleted review from the list.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers.
	@objc private func handleReviewDidDelete(_ notification: NSNotification) {
		Task { @MainActor [weak self] in
			guard let self = self, let reviewID = notification.userInfo?["reviewID"] as? KurozoraItemID else { return }

			self.reviews.removeAll { review in
				review.id == reviewID
			}

			// The removal shifts the index paths the model cache is keyed by.
			self.cache.removeAll()

			// One row leaves; the list keeps its scroll position.
			let staleItem = self.snapshot?.itemIdentifiers.first { $0.review?.id == reviewID }

			if let staleItem = staleItem {
				self.snapshot.deleteItems([staleItem])
				self.dataSource.apply(self.snapshot, animatingDifferences: true)
			}

			self.toggleEmptyDataView()
		}
	}

	/// Subscribes to playback changes so visible song cells reflect the currently playing song.
	private func observePlaybackChanges() {
		self.playbackObserver = Publishers.CombineLatest(MusicManager.shared.currentKKSongPublisher, MusicManager.shared.isPlayingPublisher)
			.receive(on: RunLoop.main)
			.sink { [weak self] _, _ in
				self?.refreshVisibleMusicCells()
			}
	}

	/// Refreshes the play button glyph of every visible song review cell.
	private func refreshVisibleMusicCells() {
		for case let cell as MusicReviewLockupCollectionViewCell in self.collectionView.visibleCells {
			cell.updatePlayButton()
		}
	}

	override func handleRefreshControl() {
		if self.user != nil {
			self.nextPageCursor = nil
			self.cache.removeAll()
			self.isFetchingType.removeAll()
			self.fetchGeneration += 1
			self.isRequestInProgress = false

			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchReviews()
			}
		}
	}

	override func configureEmptyDataView() {
		let username = self.user?.attributes.username
		let titleString: String = if self.selectedKind != nil || self.isFiltering {
			L10n.noReviewsMatchFilterTitle
		} else {
			L10n.noItemsTitle(L10n.reviews)
		}
		let detailString: String = if self.selectedKind != nil || self.isFiltering {
			L10n.noReviewsMatchFilterDetail
		} else if self.user?.id == User.current?.id {
			L10n.reviewsEmptySelfDetail
		} else {
			L10n.reviewsEmptyOtherDetail(username ?? "")
		}

		if let image = UIImage(systemName: "person.3.fill") {
			self.emptyBackgroundView.configureImageView(image: image)
		}
		self.emptyBackgroundView.configureLabels(title: titleString, detail: detailString)

		self.collectionView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of loaded reviews.
	func toggleEmptyDataView() {
		if self.reviews.isEmpty {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	func endFetch() {
		self.isRequestInProgress = false
		self.updateDataSource()
		self._prefersActivityIndicatorHidden = true
		self.toggleEmptyDataView()
		#if DEBUG
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.endRefreshing()
		#endif
		#endif
	}

	/// Fetch the reviews list for the currently viewed profile.
	func fetchReviews() async {
		guard !self.isRequestInProgress else {
			return
		}

		// Set request in progress
		self.isRequestInProgress = true

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.refreshingItems(L10n.reviews.lowercased(with: Locale.current)))
		#endif

		guard let user = self.user else { return }
		let userIdentity = UserIdentity(id: user.id)
		let generation = self.fetchGeneration

		let reviewResponse: ResourceCollection<Review>?
		do {
			reviewResponse = try await KService.reviews(forUser: userIdentity)
				.kind(self.selectedKind)
				.hasReview(self.hasReviewFilter)
				.rating(self.ratingFilter)
				.sorted(by: self.selectedSortType, self.selectedSortOption)
				.cursor(self.nextPageCursor)
				.limit(self.nextPageCursor != nil ? 100 : 25)
				.response()
		} catch {
			print(error.localizedDescription)
			reviewResponse = nil
		}

		// A newer request replaced this one.
		guard generation == self.fetchGeneration else { return }

		if let reviewResponse = reviewResponse {
			// Reset data if necessary
			if self.nextPageCursor == nil {
				self.reviews = []
			}

			// Save next page url and append new data
			self.nextPageCursor = reviewResponse.nextCursor
			self.reviews.append(contentsOf: reviewResponse.data)
			self.reviews.removeDuplicates()
		}

		self.endFetch()

		// Reset refresh controller title
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshItems(L10n.reviews.lowercased(with: Locale.current)))
		#endif
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .characterDetailsSegue: return CharacterDetailsCollectionViewController()
		case .gameDetailsSegue: return GameDetailsCollectionViewController()
		case .episodeDetailsSegue: return EpisodeDetailsCollectionViewController()
		case .literatureDetailsSegue: return LiteratureDetailsCollectionViewController()
		case .personDetailsSegue: return PersonDetailsCollectionViewController()
		case .showDetailsSegue: return ShowDetailsCollectionViewController()
		case .songDetailsSegue: return SongDetailsCollectionViewController()
		case .studioDetailsSegue: return StudioDetailsCollectionViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .characterDetailsSegue:
			guard let characterDetailsCollectionViewController = destination as? CharacterDetailsCollectionViewController else { return }
			guard let character = sender as? Character else { return }
			characterDetailsCollectionViewController.character = character
		case .gameDetailsSegue:
			guard let gameDetailCollectionViewController = destination as? GameDetailsCollectionViewController else { return }
			guard let game = sender as? Game else { return }
			gameDetailCollectionViewController.game = game
		case .episodeDetailsSegue:
			guard let episodeDetailsCollectionViewController = destination as? EpisodeDetailsCollectionViewController else { return }
			guard let episode = sender as? Episode else { return }
			episodeDetailsCollectionViewController.episode = episode
		case .literatureDetailsSegue:
			guard let literatureDetailCollectionViewController = destination as? LiteratureDetailsCollectionViewController else { return }
			guard let literature = sender as? Literature else { return }
			literatureDetailCollectionViewController.literature = literature
		case .personDetailsSegue:
			guard let personDetailsCollectionViewController = destination as? PersonDetailsCollectionViewController else { return }
			guard let person = sender as? Person else { return }
			personDetailsCollectionViewController.person = person
		case .showDetailsSegue:
			guard let showDetailsCollectionViewController = destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailsCollectionViewController.show = show
		case .songDetailsSegue:
			// Segue to song details
			guard let songDetailsCollectionViewController = destination as? SongDetailsCollectionViewController else { return }
			guard let song = sender as? Song else { return }
			songDetailsCollectionViewController.song = song
		case .studioDetailsSegue:
			// Segue to studio details
			guard let studioDetailsCollectionViewController = destination as? StudioDetailsCollectionViewController else { return }
			guard let studio = sender as? Studio else { return }
			studioDetailsCollectionViewController.studio = studio
		}
	}
}

// MARK: - SectionFetchable
extension UserReviewsListCollectionViewController {
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .review(let review):
			if let identity = review.relationships?.shows?.data.first { return identity as? Element }
			if let identity = review.relationships?.games?.data.first { return identity as? Element }
			if let identity = review.relationships?.literatures?.data.first { return identity as? Element }
			if let identity = review.relationships?.episodes?.data.first { return identity as? Element }
			if let identity = review.relationships?.songs?.data.first { return identity as? Element }
			if let identity = review.relationships?.characters?.data.first { return identity as? Element }
			if let identity = review.relationships?.people?.data.first { return identity as? Element }
			if let identity = review.relationships?.studios?.data.first { return identity as? Element }
			return nil
		}
	}

	/// Fetches details for every uncached item of one identity type in the section.
	///
	/// - Parameters:
	///    - response: The response type used to fetch the items.
	///    - identityType: The identity type to fetch.
	///    - itemKind: The item whose details are needed.
	func fetchReviewSectionIfNeeded<I: KurozoraRequestable, Identity: Fetchable>(_ response: I.Type, _ identityType: Identity.Type, for itemKind: ItemKind) async where Identity.Response == I {
		guard self.cache[itemKind] == nil else { return }

		let typeKey = String(describing: Identity.self)
		guard !self.isFetchingType.contains(typeKey) else { return }
		self.isFetchingType.insert(typeKey)
		defer { self.isFetchingType.remove(typeKey) }

		let generation = self.fetchGeneration

		let uncached: [(itemKind: ItemKind, identity: Identity)] = self.snapshot
			.itemIdentifiers(inSection: .main)
			.compactMap { itemKind in
				guard self.cache[itemKind] == nil else { return nil }
				guard let identity: Identity = self.extractIdentity(from: itemKind) else { return nil }

				return (itemKind, identity)
			}

		guard !uncached.isEmpty else { return }

		let chunkSize = 25
		let chunks = uncached.chunked(into: chunkSize)

		do {
			for chunk in chunks {
				let identitiesToFetch = chunk.map { $0.identity }
				let fetchedResponse: I = try await KService.details(identitiesToFetch).response()

				// Bail if the snapshot was rebuilt
				guard generation == self.fetchGeneration else { return }

				// One model can back several reviews.
				var itemKinds: [KurozoraItemID: [ItemKind]] = [:]
				for entry in chunk {
					itemKinds[entry.identity.id, default: []].append(entry.itemKind)
				}

				for model in fetchedResponse.data {
					for itemKind in itemKinds[model.id] ?? [] {
						self.cache[itemKind] = model
					}
				}

				let appleMusicIDs = fetchedResponse.data.compactMap { ($0 as? Song)?.attributes.amID }
				if !appleMusicIDs.isEmpty {
					_ = await MusicManager.shared.getSongs(for: appleMusicIDs)
				}

				self.setSectionNeedsUpdate(.main)
			}
		} catch {
			print("----- Fetch error for \(typeKey): \(error)")
		}
	}
}

// MARK: - MusicReviewLockupCollectionViewCellDelegate
extension UserReviewsListCollectionViewController: MusicReviewLockupCollectionViewCellDelegate {
	func musicReviewLockupCollectionViewCell(_ cell: MusicReviewLockupCollectionViewCell, didTapPlayButtonAt indexPath: IndexPath) {
		let kkSongs: [KKSong?] = self.itemKinds(inSection: indexPath.section).map { itemKind in
			self.cache[itemKind] as? Song
		}

		MusicManager.shared.play(kkSongs: kkSongs, startingAt: indexPath.item)
	}
}

// MARK: - SearchFilterCollectionViewControllerDelegate
extension UserReviewsListCollectionViewController: SearchFilterCollectionViewControllerDelegate {
	func searchFilterCollectionViewController(_ searchFilterCollectionViewController: SearchFilterCollectionViewController, didApply values: [FilterKey: FilterValue]) {
		self.filterValues = values.filter { _, value in
			!value.isEmpty
		}

		self.refreshFilterChips()
		self.refreshFilterBarButtonImage()
		self.reloadForQueryChange()
	}

	func searchFilterCollectionViewControllerDidReset(_ searchFilterCollectionViewController: SearchFilterCollectionViewController) {
		self.filterValues = [:]

		self.refreshFilterChips()
		self.refreshFilterBarButtonImage()
		self.reloadForQueryChange()
	}

	func searchFilterCollectionViewControllerDidCancel(_ searchFilterCollectionViewController: SearchFilterCollectionViewController) {}
}

// MARK: - SectionLayoutKind
extension UserReviewsListCollectionViewController {
	/// List of section layout kind.
	///
	/// ```swift
	/// case main = 0
	/// ```
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}

// MARK: - ItemKind
extension UserReviewsListCollectionViewController {
	/// List of item layout kind.
	enum ItemKind: nonisolated Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `Review` object.
		case review(_: Review)

		// MARK: - Properties
		/// The associated review.
		var review: Review? {
			switch self {
			case .review(let review):
				return review
			}
		}
	}
}
