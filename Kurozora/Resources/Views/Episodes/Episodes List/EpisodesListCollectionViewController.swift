//
//  EpisodesListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

enum EpisodesListFetchType: Equatable {
	case season
	case search
	case upNext(exploreCategory: ExploreCategory)

	static func == (_ lhs: EpisodesListFetchType, _ rhs: EpisodesListFetchType) -> Bool {
		switch (lhs, rhs) {
		case (.season, .season),
		     (.search, .search):
			return true
		case (.upNext(let exploreCategory1), .upNext(exploreCategory: let exploreCategory2)):
			return exploreCategory1 == exploreCategory2
		default:
			return false
		}
	}
}

class EpisodesListCollectionViewController: KCollectionViewController, SectionFetchable {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case showDetailsSegue
		case episodeDetailsSegue
		case episodesListSegue
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

	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	/// The next page url of the pagination.
	var nextPageURL: String?

	/// Whether a fetch request is currently in progress.
	var isRequestInProgress: Bool = false

	/// Indicates whether fillers should be hidden from the user.
	var shouldHideFillers: Bool = false

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
	/// Initialize a new instance of EpisodesListCollectionViewController with the given season id.
	///
	/// - Parameter seasonID: The season id to use when initializing the view.
	///
	/// - Returns: an initialized instance of EpisodesListCollectionViewController.
	func callAsFunction(with seasonID: KurozoraItemID) -> EpisodesListCollectionViewController {
		let episodesListCollectionViewController = EpisodesListCollectionViewController()
		episodesListCollectionViewController.seasonIdentity = SeasonIdentity(id: seasonID)
		episodesListCollectionViewController.episodesListFetchType = .season
		return episodesListCollectionViewController
	}

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		self.handleRefreshControl()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		NotificationCenter.default.addObserver(self, selector: #selector(self.handleSeasonWatchStatusDidUpdate(_:)), name: .KSeasonWatchStatusDidUpdate, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleEpisodeWatchStatusDidUpdate(_:)), name: .KEpisodeWatchStatusDidUpdate, object: nil)

		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		// Add Refresh Control to Collection View
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh the episodes.")
		#endif

		// Configure title
		switch self.episodesListFetchType {
		case .season:
			self.title = self.season?.attributes.title
		case .search:
			self.title = self.searchQuery
		case .upNext:
			self.title = Trans.upNext
		}

		self.configureDataSource()
		self.configureNavigationItems()

		if !self.episodeIdentities.isEmpty {
			self.endFetch()
		} else {
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchEpisodes()
			}
		}

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
	override func handleRefreshControl() {
		switch self.episodesListFetchType {
		case .season, .search:
			if self.seasonIdentity != nil {
				self.nextPageURL = nil
				Task { [weak self] in
					guard let self = self else { return }
					await self.fetchEpisodes()
				}
			}
		case .upNext:
			self.nextPageURL = nil
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchEpisodes()
			}
		}
	}

	override func configureEmptyDataView() {
		self.emptyBackgroundView.configureImageView(image: .Empty.episodes)
		self.emptyBackgroundView.configureLabels(title: "No Episodes", detail: "This season doesn't have episodes yet. Please check back again later.")

		self.collectionView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of rows.
	func toggleEmptyDataView() {
		if self.collectionView.numberOfItems == 0 {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	/// Configures the more bar button item.
	private func configureMoreBarButtonItem() {
		self.moreBarButtonItem = UIBarButtonItem(title: Trans.more, image: UIImage(systemName: "ellipsis.circle"))
		self.navigationItem.rightBarButtonItem = self.moreBarButtonItem
	}

	/// Configures the filler bar button item.
	private func configureFillerBarButtonItem() {
		self.fillerBarButtonItem = UIBarButtonItem(title: Trans.filters, image: UIImage(systemName: "line.3.horizontal.decrease.circle"))
		self.navigationItem.rightBarButtonItems?.append(self.fillerBarButtonItem)
	}

	/// Configures the filler bar button item.
	private func configureGoToBarButtonItem() {
		self.goToBarButtonItem = UIBarButtonItem(title: Trans.goTo, image: UIImage(systemName: "chevron.down.circle"))
		self.navigationItem.rightBarButtonItems?.append(self.goToBarButtonItem)
	}

	/// Configures the navigation items.
	fileprivate func configureNavigationItems() {
		self.configureMoreBarButtonItem()
		self.configureFillerBarButtonItem()
		self.configureGoToBarButtonItem()

		// Hide buttons if not in season fetch type
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

	func fetchSeason() async {
		do {
			guard let seasonIdentity = self.seasonIdentity else { return }
			let seasonResponse = try await KService.getDetails(forSeason: seasonIdentity).value

			self.season = seasonResponse.data.first
		} catch {
			print(error.localizedDescription)
		}

		self.configureNavBarButtons()
	}

	/// Fetches the episodes from the server.
	func fetchEpisodes() async {
		guard !self.isRequestInProgress else {
			return
		}

		// Set request in progress
		self.isRequestInProgress = true

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing episodes...")
		#endif

		switch self.episodesListFetchType {
		case .season:
			do {
				guard let seasonIdentity = self.seasonIdentity else { return }
				let episodeIdentityResponse = try await KService.getEpisodes(forSeason: seasonIdentity, next: self.nextPageURL, limit: self.nextPageURL != nil ? 100 : 25).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.episodeIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = episodeIdentityResponse.next
				self.episodeIdentities.append(contentsOf: episodeIdentityResponse.data)
				self.episodeIdentities.removeDuplicates()
			} catch {
				print(error.localizedDescription)
			}
		case .search:
			do {
				let searchResponse = try await KService.search(.kurozora, of: [.episodes], for: self.searchQuery, next: self.nextPageURL, limit: self.nextPageURL != nil ? 100 : 25, filter: nil).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.episodeIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = searchResponse.data.episodes?.next
				self.episodeIdentities.append(contentsOf: searchResponse.data.episodes?.data ?? [])
				self.episodeIdentities.removeDuplicates()
			} catch {
				print(error.localizedDescription)
			}
		case .upNext(let exploreCategory):
			do {
				let exploreCategoryIdentity = ExploreCategoryIdentity(id: exploreCategory.id)
				let upNextResponse = try await KService.getExplore(exploreCategoryIdentity, next: self.nextPageURL, limit: self.nextPageURL != nil ? 100 : 25).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.episodeIdentities = []
				}

				// Save next page url and append new data
				let episodeResponse = upNextResponse.data.first { exploreCategory in
					exploreCategory.relationships.episodes != nil
				}

				self.nextPageURL = episodeResponse?.relationships.episodes?.next
				self.episodeIdentities.append(contentsOf: episodeResponse?.relationships.episodes?.data ?? [])
				self.episodeIdentities.removeDuplicates()
			} catch {
				print(error.localizedDescription)
			}
		}

		self.endFetch()

		// Reset refresh controller title
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh the episodes.")
		#endif
	}

	/// Handles the season watch status update notification.
	///
	/// - Parameters:
	///    - notification: An object containing information broadcast to registered observers that bridges to Notification.
	@objc func handleSeasonWatchStatusDidUpdate(_ notification: NSNotification) {
		Task { @MainActor [weak self] in
			guard let self = self else { return }
			self.configureNavBarButtons()
		}
	}

	/// Handles the episode watch status update notification.
	///
	/// - Parameters:
	///    - notification: An object containing information broadcast to registered observers that bridges to Notification.
	@objc func handleEpisodeWatchStatusDidUpdate(_ notification: NSNotification) {
		switch self.episodesListFetchType {
		case .season, .search:
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
			Task { @MainActor in
				await self.fetchEpisodes()
			}
		}
	}

	/// Prepares for the Up Next list refresh by removing already watched episodes.
	fileprivate func prepareUpNextRefresh(_ indexPath: IndexPath) {
		self.cache.removeValue(forKey: indexPath)
	}

	/// Goes to the first item in the presented collection view.
	fileprivate func goToFirstEpisode() {
		self.collectionView.safeScrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredVertically, animated: true)
		self.goToBarButtonItem.image = UIImage(systemName: "chevron.down.circle")
		self.configureNavBarButtons()
	}

	/// Goes to the last item in the presented collection view.
	fileprivate func goToLastEpisode() {
		self.collectionView.safeScrollToItem(at: IndexPath(row: self.dataSource.snapshot().numberOfItems - 1, section: 0), at: .centeredVertically, animated: true)
		self.goToBarButtonItem.image = UIImage(systemName: "chevron.up.circle")
		self.configureNavBarButtons()
	}

	/// Goes to the last watched episode in the presented collection view.
	fileprivate func goToLastWatchedEpisode() {
		guard let episodes = self.cache as? [IndexPath: Episode] else {
			self.goToLastEpisode()
			return
		}

		if let lastWatchedEpisode = episodes.sorted(by: { $0.value.attributes.number < $1.value.attributes.number }).first(where: { _, episode in
			episode.attributes.watchStatus == .notWatched
		}) {
			self.collectionView.safeScrollToItem(at: lastWatchedEpisode.key, at: .centeredVertically, animated: true)
			self.configureNavBarButtons()
		} else {
			self.goToLastEpisode()
		}
	}

	/// Builds the "go to episode" menu.
	fileprivate func createGoToEpisodeMenu() -> UIMenu {
		var menuElements: [UIMenuElement] = []
		let visibleIndexPath = collectionView.indexPathsForVisibleItems

		if !visibleIndexPath.contains(IndexPath(item: 0, section: 0)) {
			// Go to first episode
			let goToFirstEpisode = UIAction(title: Trans.goToFirstEpisode, image: nil) { [weak self] _ in
				guard let self = self else { return }
				self.goToFirstEpisode()
			}
			menuElements.append(goToFirstEpisode)
		} else {
			// Go to last episode
			let goToLastEpisode = UIAction(title: Trans.goToLastEpisode, image: nil) { [weak self] _ in
				guard let self = self else { return }
				self.goToLastEpisode()
			}
			menuElements.append(goToLastEpisode)
		}

		// Go to last watched episode
		let goToLastWatchedEpisode = UIAction(title: Trans.goToLastWatchedEpisode, image: nil) { [weak self] _ in
			guard let self = self else { return }
			self.goToLastWatchedEpisode()
		}
		menuElements.append(goToLastWatchedEpisode)

		// Create and return a UIMenu
		return UIMenu(title: "", children: menuElements)
	}

	/// Builds the "show fillers" menu.
	fileprivate func createShowFillersMenu() -> UIMenu {
		var menuElements: [UIMenuElement] = []

		// Create "Show fillers" element
		let title = self.shouldHideFillers ? Trans.showFillers : Trans.hideFillers
		let toggleFillers = UIAction(title: title, image: nil) { [weak self] _ in
			guard let self = self else { return }
			self.shouldHideFillers = !self.shouldHideFillers
			self.updateDataSource()
			self.configureNavBarButtons()
		}
		menuElements.append(toggleFillers)

		// Create and return a UIMenu
		return UIMenu(title: "", children: menuElements)
	}

	// MARK: - SectionFetchable
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .episodeIdentity(let id): return id as? Element
		}
	}

	// MARK: - Segue
	override func makeDestination(for identifier: SegueIdentifier) -> UIViewController? {
		guard let segue = identifier as? SegueIdentifiers else { return nil }

		switch segue {
		case .showDetailsSegue: return ShowDetailsCollectionViewController()
		case .episodeDetailsSegue: return EpisodeDetailsCollectionViewController()
		case .episodesListSegue: return EpisodesListCollectionViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .showDetailsSegue:
			guard let showDetailsCollectionViewController = destination as? ShowDetailsCollectionViewController else { return }
			if let show = sender as? Show {
				showDetailsCollectionViewController.show = show
			} else if let showIdentity = sender as? ShowIdentity {
				showDetailsCollectionViewController.showIdentity = showIdentity
			}
		case .episodeDetailsSegue:
			guard let episodeDetailsCollectionViewController = destination as? EpisodeDetailsCollectionViewController else { return }
			guard let episodeDict = (sender as? [IndexPath: Episode])?.first else { return }

			episodeDetailsCollectionViewController.indexPath = episodeDict.key
			episodeDetailsCollectionViewController.episode = episodeDict.value
		case .episodesListSegue:
			guard let episodesListCollectionViewController = destination as? EpisodesListCollectionViewController else { return }
			guard let seasonIdentity = sender as? SeasonIdentity else { return }
			episodesListCollectionViewController.seasonIdentity = seasonIdentity
			episodesListCollectionViewController.episodesListFetchType = .season
		}
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
		case .season, .search:
			await episode.updateWatchStatus(userInfo: ["indexPath": indexPath])
		case .upNext:
			await episode.updateWatchStatus(userInfo: [:])
			self.prepareUpNextRefresh(indexPath)
			await self.fetchEpisodes()
		}
		cell.watchStatusButton.isEnabled = true
	}

	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressShowButton button: UIButton) async {
		guard
			let indexPath = collectionView.indexPath(for: cell),
			let episode = self.cache[indexPath] as? Episode,
			let showIdentity = episode.relationships?.shows?.data.first
		else { return }

		self.show(SegueIdentifiers.showDetailsSegue, sender: showIdentity)
	}

	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressSeasonButton button: UIButton) async {
		guard
			let indexPath = collectionView.indexPath(for: cell),
			let episode = self.cache[indexPath] as? Episode,
			let seasonIdentity = episode.relationships?.seasons?.data.first
		else { return }

		self.show(SegueIdentifiers.episodesListSegue, sender: seasonIdentity)
	}
}

// MARK: - SectionLayoutKind
extension EpisodesListCollectionViewController {
	/// List of episode section layout kind.
	///
	/// ```swift
	/// case main = 0
	/// ```
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}

// MARK: - ItemKind
extension EpisodesListCollectionViewController {
	/// List of item layout kind.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `EpisodeIdentity` object.
		case episodeIdentity(_: EpisodeIdentity)

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .episodeIdentity(let episodeIdentity):
				hasher.combine(episodeIdentity)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.episodeIdentity(let episodeIdentity1), .episodeIdentity(let episodeIdentity2)):
				return episodeIdentity1 == episodeIdentity2
			}
		}
	}
}

// MARK: - Cell Configuration
extension EpisodesListCollectionViewController {
	func getConfiguredEpisodeCell() -> UICollectionView.CellRegistration<EpisodeLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<EpisodeLockupCollectionViewCell, ItemKind>(cellNib: EpisodeLockupCollectionViewCell.nib) { [weak self] episodeLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .episodeIdentity:
				let episode: Episode? = self.fetchModel(at: indexPath)

				if episode == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(EpisodeResponse.self, EpisodeIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				episodeLockupCollectionViewCell.delegate = self
				episodeLockupCollectionViewCell.configure(using: episode)
			}
		}
	}
}
