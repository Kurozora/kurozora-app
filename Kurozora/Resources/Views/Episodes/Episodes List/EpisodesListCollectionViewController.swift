//
//  EpisodesListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// A source of episodes for ``EpisodesListCollectionViewController``.
enum EpisodesListFetchType: Equatable {
	case charts
	case season
	case search
	case upNext(exploreCategory: ExploreCategory)

	static func == (_ lhs: EpisodesListFetchType, _ rhs: EpisodesListFetchType) -> Bool {
		switch (lhs, rhs) {
		case (.charts, .charts),
			 (.season, .season),
			 (.search, .search):
			return true
		case (.upNext(let exploreCategory1), .upNext(exploreCategory: let exploreCategory2)):
			return exploreCategory1 == exploreCategory2
		default:
			return false
		}
	}
}

/// An edge of the list the go-to menu can jump to.
private enum GoToEdge {
	case first
	case last

	/// The name of the system image pointing towards the edge.
	var systemImageName: String {
		switch self {
		case .first: return "chevron.up.circle"
		case .last: return "chevron.down.circle"
		}
	}

	/// The title of the menu action jumping to the edge.
	var actionTitle: String {
		switch self {
		case .first: return L10n.goToFirstEpisode
		case .last: return L10n.goToLastEpisode
		}
	}
}

/// A paginated list of episodes.
class EpisodesListCollectionViewController: ListCollectionViewController, SectionFetchable, TypedSegueHandling {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case showDetailsSegue
		case episodeDetailsSegue
		case episodesListSegue
	}

	/// The section identifier.
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}

	/// An item displayed in the list.
	enum ItemKind: Hashable {
		case episodeIdentity(_: EpisodeIdentity)
	}

	// MARK: - Views
	private var moreBarButtonItem: UIBarButtonItem!
	private var fillerBarButtonItem: UIBarButtonItem!
	private var goToBarButtonItem: UIBarButtonItem!

	// MARK: - Properties
	var season: Season? {
		didSet {
			guard let season = self.season else {
				self.seasonIdentity = nil
				return
			}
			self.seasonIdentity = SeasonIdentity(id: season.id)
		}
	}
	var seasonIdentity: SeasonIdentity?
	var episodeIdentities: [EpisodeIdentity] = []
	var searchQuery: String = ""
	var episodesListFetchType: EpisodesListFetchType = .search

	/// A Boolean value that indicates whether filler episodes are hidden.
	var shouldHideFillers: Bool = false

	/// The edge currently reflected by ``goToBarButtonItem``'s image.
	private var displayedGoToEdge: GoToEdge?

	/// The edge the go-to menu offers.
	private var goToEdge: GoToEdge? {
		let visibleIndexPaths = self.collectionView.indexPathsForVisibleItems

		guard !visibleIndexPaths.isEmpty else {
			return nil
		}

		guard visibleIndexPaths.contains(IndexPath(item: 0, section: 0)) else {
			return .first
		}

		let lastItem = self.dataSource.snapshot().numberOfItems - 1

		guard self.nextPageCursor == nil, visibleIndexPaths.contains(IndexPath(item: lastItem, section: 0)) else {
			return .last
		}

		return nil
	}

	// MARK: - SectionFetchable
	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	override var emptyStateImage: UIImage? { .Empty.tvPhoto }
	override var emptyStateTitle: String {
		switch self.episodesListFetchType {
		case .charts: return L10n.noItemsTitle(L10n.topCharts)
		default: return L10n.noItemsTitle(L10n.episodes)
		}
	}
	override var emptyStateDetail: String {
		switch self.episodesListFetchType {
		case .charts: return L10n.cantGetListDetail(L10n.topCharts.lowercased(with: .current))
		default: return L10n.noItemsYet(L10n.season.lowercased(with: .current), L10n.episodes.lowercased(with: .current))
		}
	}

	override var hasLoadedInitialData: Bool {
		!self.episodeIdentities.isEmpty
	}

	// MARK: - Initializers
	/// Creates a controller configured for the given season.
	///
	/// - Parameter seasonID: The identifier of the season.
	/// - Returns: A new ``EpisodesListCollectionViewController``.
	func callAsFunction(with seasonID: KurozoraItemID) -> EpisodesListCollectionViewController {
		let episodesListCollectionViewController = EpisodesListCollectionViewController()
		episodesListCollectionViewController.seasonIdentity = SeasonIdentity(id: seasonID)
		episodesListCollectionViewController.episodesListFetchType = .season
		return episodesListCollectionViewController
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		NotificationCenter.default.addObserver(self, selector: #selector(self.handleSeasonWatchStatusDidUpdate(_:)), name: .KSeasonWatchStatusDidUpdate, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleEpisodeWatchStatusDidUpdate(_:)), name: .KEpisodeWatchStatusDidUpdate, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleUserStateDidChangeRemotely(_:)), name: .KUserStateDidChangeRemotely, object: nil)

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshItems(L10n.episodes.lowercased(with: Locale.current)))
		#endif

		switch self.episodesListFetchType {
		case .charts:
			self.title = L10n.xTopCharts(L10n.episodes)
		case .season:
			self.title = self.season?.attributes.title
		case .search:
			self.title = self.searchQuery
		case .upNext:
			self.title = L10n.upNext
		}

		self.configureNavigationItems()

		if self.season == nil {
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchSeason()
			}
		} else {
			self.configureNavBarButtons()
		}
	}

	// MARK: - Functions
	/// Creates the more bar-button item.
	private func configureMoreBarButtonItem() {
		self.moreBarButtonItem = UIBarButtonItem(title: L10n.more, image: UIImage(systemName: "ellipsis.circle"))
		self.navigationItem.rightBarButtonItem = self.moreBarButtonItem
	}

	/// Creates the filler bar-button item.
	private func configureFillerBarButtonItem() {
		self.fillerBarButtonItem = UIBarButtonItem(title: L10n.filters, image: UIImage(systemName: "line.3.horizontal.decrease.circle"))
		self.navigationItem.rightBarButtonItems?.append(self.fillerBarButtonItem)
	}

	/// Creates the go-to bar-button item.
	private func configureGoToBarButtonItem() {
		self.displayedGoToEdge = .last
		self.goToBarButtonItem = UIBarButtonItem(title: L10n.goTo, image: UIImage(systemName: GoToEdge.last.systemImageName))
		self.navigationItem.rightBarButtonItems?.append(self.goToBarButtonItem)
	}

	fileprivate func configureNavigationItems() {
		self.configureMoreBarButtonItem()
		self.configureFillerBarButtonItem()
		self.configureGoToBarButtonItem()

		if #available(iOS 16.0, *) {
			self.moreBarButtonItem.isHidden = self.episodesListFetchType != .season
			self.fillerBarButtonItem.isHidden = self.episodesListFetchType != .season
			self.goToBarButtonItem.isHidden = self.episodesListFetchType != .season
		} else if self.episodesListFetchType != .season {
			self.navigationItem.rightBarButtonItems = []
		}
	}

	func configureNavBarButtons() {
		self.moreBarButtonItem.menu = self.season?.makeContextMenu(in: self, userInfo: [:], sourceView: nil, barButtonItem: self.moreBarButtonItem)
		self.goToBarButtonItem.menu = self.createGoToEpisodeMenu()
		self.fillerBarButtonItem.menu = self.createShowFillersMenu()

		self.updateGoToBarButtonItemImage()
	}

	// MARK: - Fetch
	func fetchSeason() async {
		do {
			guard let seasonIdentity = self.seasonIdentity else { return }

			let seasonResponse = try await KService.detail(seasonIdentity).response()
			self.season = seasonResponse.data.first
		} catch {
			print(error.localizedDescription)
		}

		self.configureNavBarButtons()
	}

	override func fetchItems() async {
		guard !self.isRequestInProgress else { return }
		self.isRequestInProgress = true

		defer {
			self.endFetch()

			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshItems(L10n.episodes.lowercased(with: Locale.current)))
			#endif
		}

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.refreshingItems(L10n.episodes.lowercased(with: Locale.current)))
		#endif

		do {
			switch self.episodesListFetchType {
			case .charts:
				let response = try await KService.topEpisodes().cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.episodeIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.episodeIdentities.append(contentsOf: response.data)
				self.episodeIdentities.removeDuplicates()
			case .season:
				guard let seasonIdentity = self.seasonIdentity else { return }
				let response = try await KService.episodes(for: seasonIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.episodeIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.episodeIdentities.append(contentsOf: response.data)
				self.episodeIdentities.removeDuplicates()

				// Fetch the auth user's per-episode watched overlay in parallel with episode hydration.
				await self.fetchWatchedOverlay()
			case .search:
				let searchResponse = try await KService.search(.kurozora, types: [.episodes], query: self.searchQuery).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).filter(nil).response()

				if self.nextPageCursor == nil {
					self.episodeIdentities = []
				}

				self.nextPageCursor = searchResponse.data.episodes?.nextCursor
				self.episodeIdentities.append(contentsOf: searchResponse.data.episodes?.data ?? [])
				self.episodeIdentities.removeDuplicates()
			case .upNext(let exploreCategory):
				let exploreCategoryIdentity = ExploreCategoryIdentity(id: exploreCategory.id)
				let upNextResponse = try await KService.exploreCategory(exploreCategoryIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.episodeIdentities = []
				}

				let episodeResponse = upNextResponse.data.first { exploreCategory in
					exploreCategory.relationships.episodes != nil
				}
				self.nextPageCursor = episodeResponse?.relationships.episodes?.nextCursor
				self.episodeIdentities.append(contentsOf: episodeResponse?.relationships.episodes?.data ?? [])
				self.episodeIdentities.removeDuplicates()
			}
		} catch {
			print(error.localizedDescription)
		}
	}

	/// Fetches the auth user's per-episode watched overlay for the current `episodeIdentities`.
	private func fetchWatchedOverlay() async {
		guard let userID = User.current?.id, !self.episodeIdentities.isEmpty else { return }
		let userIdentity = UserIdentity(id: userID)
		let episodeIDs = self.episodeIdentities.map(\.id)

		do {
			let requestedIDs = episodeIDs.map(\.rawValue)
			let cachedETag = await WatchedStore.shared.etag(forRequestedIDs: requestedIDs)
			let overlayResult = try await KService
				.watchedOverlay(forUser: userIdentity, episodes: episodeIDs)
				.response(ifNoneMatch: cachedETag)

			// A 304 means the cache already reflects the current state.
			guard case .modified(let response, let etag) = overlayResult else { return }

			// Record the overlay in the cache.
			await WatchedStore.shared.apply(response.data, requestedIDs: requestedIDs)
			await WatchedStore.shared.setETag(etag, forRequestedIDs: requestedIDs)

			// `apply(unchanged-snapshot)` is a no-op; mark every item for reconfiguration explicitly.
			await MainActor.run { [weak self] in
				guard let self = self else { return }
				var newSnapshot = self.dataSource.snapshot()
				newSnapshot.reconfigureItems(newSnapshot.itemIdentifiers)
				self.dataSource.apply(newSnapshot)
			}
		} catch {
			print("watchedOverlay fetch failed: \(error.localizedDescription)")
		}
	}

	// MARK: - Watch status observers
	/// Re-fetches the watched overlay when another device or the website changes the user's state.
	@objc func handleUserStateDidChangeRemotely(_ notification: NSNotification) {
		Task { @MainActor [weak self] in
			guard let self = self else { return }

			switch self.episodesListFetchType {
			case .charts, .season, .search:
				await self.fetchWatchedOverlay()
			case .upNext:
				self.nextPageCursor = nil
				await self.fetchItems()
			}
		}
	}

	@objc func handleSeasonWatchStatusDidUpdate(_ notification: NSNotification) {
		Task { @MainActor [weak self] in
			guard let self = self else { return }
			self.configureNavBarButtons()
		}
	}

	@objc func handleEpisodeWatchStatusDidUpdate(_ notification: NSNotification) {
		switch self.episodesListFetchType {
		case .charts, .season, .search:
			Task { @MainActor [weak self] in
				guard let self = self else { return }
				guard let indexPath = notification.userInfo?["indexPath"] as? IndexPath, let selectedEpisode = self.dataSource.itemIdentifier(for: indexPath) else { return }

				var newSnapshot = self.dataSource.snapshot()
				newSnapshot.reloadItems([selectedEpisode])
				self.dataSource.apply(newSnapshot)
			}
		case .upNext:
			guard let indexPath = notification.userInfo?["indexPath"] as? IndexPath else { return }

			self.prepareUpNextRefresh(indexPath)

			Task { @MainActor [weak self] in
				guard let self = self else { return }
				await self.fetchItems()
			}
		}
	}

	fileprivate func prepareUpNextRefresh(_ indexPath: IndexPath) {
		self.cache.removeValue(forKey: indexPath)
	}

	// MARK: - Go-to menu
	fileprivate func goToFirstEpisode() {
		self.collectionView.safeScrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredVertically, animated: true)
	}

	/// Loads every page that hasn't been fetched yet, then scrolls to the final episode.
	fileprivate func goToLastEpisode() async {
		await self.loadRemainingEpisodes()

		let lastItem = self.dataSource.snapshot().numberOfItems - 1
		self.collectionView.safeScrollToItem(at: IndexPath(item: lastItem, section: 0), at: .centeredVertically, animated: true)
	}

	fileprivate func goToLastWatchedEpisode() async {
		guard let episodes = self.cache as? [IndexPath: Episode] else {
			await self.goToLastEpisode()
			return
		}

		if let lastWatchedEpisode = episodes.sorted(by: { $0.value.attributes.number < $1.value.attributes.number }).first(where: { _, episode in
			episode.watchStatus == .notWatched
		}) {
			self.collectionView.safeScrollToItem(at: lastWatchedEpisode.key, at: .centeredVertically, animated: true)
		} else {
			await self.goToLastEpisode()
		}
	}

	/// Requests every remaining page of episodes.
	private func loadRemainingEpisodes() async {
		while self.nextPageCursor != nil {
			let cursor = self.nextPageCursor
			await self.fetchItems()

			// A cursor that hasn't advanced means the page couldn't be loaded.
			guard self.nextPageCursor != cursor else { return }
		}
	}

	/// Points ``goToBarButtonItem``'s image at the edge the menu offers.
	private func updateGoToBarButtonItemImage() {
		guard let goToEdge = self.goToEdge, goToEdge != self.displayedGoToEdge else { return }

		self.displayedGoToEdge = goToEdge
		self.goToBarButtonItem?.image = UIImage(systemName: goToEdge.systemImageName)
	}

	/// Creates the action jumping to the given edge of the list.
	///
	/// - Parameter edge: The edge to jump to.
	///
	/// - Returns: A new `UIAction`.
	private func makeGoToEdgeEpisodeAction(for edge: GoToEdge) -> UIAction {
		return UIAction(title: edge.actionTitle, image: nil) { [weak self] _ in
			guard let self = self else { return }

			switch edge {
			case .first:
				self.goToFirstEpisode()
			case .last:
				Task {
					await self.goToLastEpisode()
				}
			}
		}
	}

	fileprivate func createGoToEpisodeMenu() -> UIMenu {
		let goToEdgeEpisode = UIDeferredMenuElement.uncached { [weak self] completion in
			guard let self = self, let goToEdge = self.goToEdge else {
				completion([])
				return
			}

			completion([self.makeGoToEdgeEpisodeAction(for: goToEdge)])
		}

		let goToLastWatchedEpisode = UIAction(title: L10n.goToLastWatchedEpisode, image: nil) { [weak self] _ in
			guard let self = self else { return }

			Task {
				await self.goToLastWatchedEpisode()
			}
		}

		return UIMenu(title: "", children: [goToEdgeEpisode, goToLastWatchedEpisode])
	}

	fileprivate func createShowFillersMenu() -> UIMenu {
		var menuElements: [UIMenuElement] = []

		let title = self.shouldHideFillers ? L10n.showFillers : L10n.hideFillers
		let toggleFillers = UIAction(title: title, image: nil) { [weak self] _ in
			guard let self = self else { return }
			self.shouldHideFillers = !self.shouldHideFillers
			self.updateDataSource()
			self.configureNavBarButtons()
		}
		menuElements.append(toggleFillers)

		return UIMenu(title: "", children: menuElements)
	}

	// MARK: - SectionFetchable
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .episodeIdentity(let id): return id as? Element
		}
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .showDetailsSegue: return ShowDetailsCollectionViewController()
		case .episodeDetailsSegue: return EpisodeDetailsCollectionViewController()
		case .episodesListSegue: return EpisodesListCollectionViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .showDetailsSegue:
			guard let destination = destination as? ShowDetailsCollectionViewController else { return }
			if let show = sender as? Show {
				destination.show = show
			} else if let showIdentity = sender as? ShowIdentity {
				destination.showIdentity = showIdentity
			}
		case .episodeDetailsSegue:
			guard let destination = destination as? EpisodeDetailsCollectionViewController else { return }
			guard let episodeDict = (sender as? [IndexPath: Episode])?.first else { return }
			destination.indexPath = episodeDict.key
			destination.episode = episodeDict.value
		case .episodesListSegue:
			guard let destination = destination as? EpisodesListCollectionViewController else { return }
			guard let seasonIdentity = sender as? SeasonIdentity else { return }
			destination.seasonIdentity = seasonIdentity
			destination.episodesListFetchType = .season
		}
	}
}

// MARK: - KCollectionViewDataSource
extension EpisodesListCollectionViewController {
	override func configureDataSource() {
		let episodeCellRegistration = self.getConfiguredEpisodeCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { collectionView, indexPath, itemKind in
			return collectionView.dequeueConfiguredReusableCell(using: episodeCellRegistration, for: indexPath, item: itemKind)
		}
	}

	override func updateDataSource() {
		let episodes = (self.cache as? [IndexPath: Episode]) ?? [:]
		let visibleEpisodeIdentities: [EpisodeIdentity] = {
			guard self.shouldHideFillers else {
				return self.episodeIdentities
			}

			let fillerIDs = episodes.values
				.filter { $0.attributes.isFiller }
				.map { $0.id }

			return self.episodeIdentities.filter { !fillerIDs.contains($0.id) }
		}()

		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		self.snapshot.appendSections([.main])

		let items: [ItemKind] = visibleEpisodeIdentities.map { .episodeIdentity($0) }
		self.snapshot.appendItems(items, toSection: .main)

		self.dataSource.apply(self.snapshot)
	}

	private func getConfiguredEpisodeCell() -> UICollectionView.CellRegistration<EpisodeLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<EpisodeLockupCollectionViewCell, ItemKind>(cellNib: EpisodeLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .episodeIdentity:
				let episode: Episode? = self.fetchModel(at: indexPath)

				if episode == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ResourceCollection<Episode>.self, EpisodeIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				cell.delegate = self
				cell.configure(using: episode, rank: self.episodesListFetchType == .charts ? indexPath.item + 1 : nil)
			}
		}
	}
}

// MARK: - KCollectionViewDelegateLayout
extension EpisodesListCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		let columnCount = Int(width >= 414 ? (width / 384).rounded() : (width / 284).rounded())
		return columnCount > 0 ? columnCount : 1
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] section, layoutEnvironment in
			guard let self = self else { return nil }
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)

			return Layouts.episodesSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
		}
	}
}

// MARK: - UICollectionViewDelegate
extension EpisodesListCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let episode = self.cache[indexPath] as? Episode else { return }

		self.show(.episodeDetailsSegue, sender: [indexPath: episode])
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		self.paginateIfNeeded(at: indexPath, totalItems: self.episodeIdentities.count)
	}

	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let episode = self.cache[indexPath] as? Episode else { return nil }

		let collectionViewCell = collectionView.cellForItem(at: indexPath)
		return episode.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
	}
}

// MARK: - UIScrollViewDelegate
extension EpisodesListCollectionViewController {
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		self.updateGoToBarButtonItemImage()
	}
}

// MARK: - EpisodeLockupCollectionViewCellDelegate
extension EpisodesListCollectionViewController: EpisodeLockupCollectionViewCellDelegate {
	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressWatchStatusButton button: UIButton) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard
			signedIn,
			let indexPath = self.collectionView.indexPath(for: cell),
			let episode = self.cache[indexPath] as? Episode
		else { return }

		cell.watchStatusButton.isEnabled = false

		switch self.episodesListFetchType {
		case .charts, .season, .search:
			await episode.updateWatchStatus(userInfo: ["indexPath": indexPath])
		case .upNext:
			await episode.updateWatchStatus(userInfo: [:])
			self.prepareUpNextRefresh(indexPath)
			await self.fetchItems()
		}

		cell.watchStatusButton.isEnabled = true
	}

	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressShowButton button: UIButton) async {
		guard
			let indexPath = collectionView.indexPath(for: cell),
			let episode = self.cache[indexPath] as? Episode,
			let showIdentity = episode.relationships?.shows?.data.first
		else { return }

		self.show(.showDetailsSegue, sender: showIdentity)
	}

	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressSeasonButton button: UIButton) async {
		guard
			let indexPath = collectionView.indexPath(for: cell),
			let episode = self.cache[indexPath] as? Episode,
			let seasonIdentity = episode.relationships?.seasons?.data.first
		else { return }

		self.show(.episodesListSegue, sender: seasonIdentity)
	}
}
