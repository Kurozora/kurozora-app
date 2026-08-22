//
//  TrailersCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import Tabman
import UIKit

/// A collection of the titles that have a trailer, switchable between anime and games.
class TrailersCollectionViewController: ListCollectionViewController, SectionFetchable, TypedSegueHandling {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case showDetailsSegue
		case gameDetailsSegue
	}

	/// The kinds of titles the collection lists.
	enum Kind: Int, CaseIterable {
		case shows
		case games

		/// The localized title of the kind.
		var title: String {
			switch self {
			case .shows: return L10n.shows
			case .games: return L10n.games
			}
		}
	}

	/// The section identifier.
	enum SectionLayoutKind: Int, CaseIterable {
		case hero = 0
		case main = 1
	}

	/// An item displayed in the collection.
	enum ItemKind: Hashable {
		case showIdentity(_: ShowIdentity)
		case gameIdentity(_: GameIdentity)
	}

	// MARK: - Views
	/// The height of the tab bar toolbar.
	private static let toolbarHeight: CGFloat = 49.0

	let toolbar = UIToolbar()
	let tabBarView = TMBar.KBar()

	/// The bar button item presenting the sort order.
	private var sortBarButtonItem: UIBarButtonItem!

	/// The bar button item that dims titles already in the user's library.
	private var dimLibraryBarButtonItem: UIBarButtonItem!

	/// The interaction blurring the collection under the toolbar's edge.
	private var topScrollEdgeInteraction: UIInteraction?

	// MARK: - Properties
	/// The kind currently shown.
	private var kind: Kind = .shows

	/// Whether the queue is listed beside the hero.
	private var listsQueue = false

	/// The trailer the feed picked for each title, keyed by the title's identifier.
	private var trailerURLs: [KurozoraItemID: String] = [:]

	/// The number of trailers the hero pages through when the queue is not beside it.
	private static let pagedHeroCount = 10

	/// The number of trailers the hero section holds at the current width.
	private var heroCount = TrailersCollectionViewController.pagedHeroCount

	/// The order the trailers are listed in.
	private var sort: TrailerSort = .justAdded

	var showIdentities: [ShowIdentity] = []
	var gameIdentities: [GameIdentity] = []

	// MARK: - SectionFetchable
	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	/// Whether titles already in the user's library are dimmed.
	private var dimsLibraryEntries = false

	/// Observes local library mutations to refresh visible cells.
	private var libraryObserver: LocalLibraryEntryObserver?

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	override var emptyStateImage: UIImage? { self.kind == .games ? .Empty.libraryGame : .Empty.libraryAnime }
	override var emptyStateTitle: String { L10n.noItemsTitle(L10n.trailers) }
	override var emptyStateDetail: String { L10n.noTrailersDetail }

	override var hasLoadedInitialData: Bool {
		!self.showIdentities.isEmpty || !self.gameIdentities.isEmpty
	}

	// MARK: - View
	override func themeWillReload() {
		super.themeWillReload()

		self.styleTabBarView()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = L10n.trailers
		self.navigationItem.largeTitleDisplayMode = .never

		self.configureView()
		self.configureNavBarButtons()
		self.observeLibraryChanges()

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(self.handleUserSignedInDidChange),
			name: .KUserIsSignedInDidChange,
			object: nil
		)
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()

		if self.dataSource == nil || self.snapshot.itemIdentifiers.isEmpty {
			_ = self.updateHeroMetrics(forWidth: self.collectionView.bounds.width)
		}
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		guard self.dataSource != nil, self.heroMetricsChanged(forWidth: self.collectionView.bounds.width) else { return }

		Task { @MainActor [weak self] in
			guard let self = self, self.dataSource != nil else { return }
			guard self.updateHeroMetrics(forWidth: self.collectionView.bounds.width) else { return }

			self.collectionView.collectionViewLayout.invalidateLayout()
			self.updateSnapshot()
			self.dataSource.applySnapshotUsingReloadData(self.snapshot)
		}
	}

	/// Whether the hero section no longer matches the given width.
	///
	/// - Parameter width: The width of the collection.
	///
	/// - Returns: `true` when the hero section needs rebuilding.
	private func heroMetricsChanged(forWidth width: CGFloat) -> Bool {
		let listsQueue = width >= Layouts.trailerQueueWidth
		let heroCount = listsQueue ? Layouts.trailerQueueCount(forWidth: width) + 1 : Self.pagedHeroCount
		return listsQueue != self.listsQueue || heroCount != self.heroCount
	}

	/// Matches the hero section to the given width.
	///
	/// - Parameter width: The width of the collection.
	///
	/// - Returns: `true` when the section changed.
	private func updateHeroMetrics(forWidth width: CGFloat) -> Bool {
		guard self.heroMetricsChanged(forWidth: width) else { return false }

		let listsQueue = width >= Layouts.trailerQueueWidth
		let heroCount = listsQueue ? Layouts.trailerQueueCount(forWidth: width) + 1 : Self.pagedHeroCount

		self.listsQueue = listsQueue
		self.moveCache(from: self.heroCount, to: heroCount)
		self.heroCount = heroCount
		return true
	}

	/// Returns the cached model at the given index path.
	///
	/// - Parameter indexPath: The index path of the item.
	///
	/// - Returns: the cached model, or `nil` when nothing is cached.
	private func cachedModel(at indexPath: IndexPath) -> KurozoraItem? {
		guard let model = self.cache[indexPath] else { return nil }

		let identityID: KurozoraItemID? = switch self.dataSource.itemIdentifier(for: indexPath) {
		case .showIdentity(let identity): identity.id
		case .gameIdentity(let identity): identity.id
		case nil: nil
		}

		guard model.id == identityID else {
			self.cache[indexPath] = nil
			return nil
		}

		return model
	}

	/// Moves the cached models to match the new hero size.
	///
	/// - Parameters:
	///    - oldHeroCount: The number of trailers the hero section held.
	///    - newHeroCount: The number of trailers the hero section holds now.
	private func moveCache(from oldHeroCount: Int, to newHeroCount: Int) {
		guard oldHeroCount != newHeroCount, !self.cache.isEmpty else { return }

		var movedCache: [IndexPath: KurozoraItem] = [:]

		for (indexPath, model) in self.cache {
			let position = indexPath.section == SectionLayoutKind.hero.rawValue ? indexPath.item : indexPath.item + oldHeroCount

			if position < newHeroCount {
				movedCache[IndexPath(item: position, section: SectionLayoutKind.hero.rawValue)] = model
			} else {
				movedCache[IndexPath(item: position - newHeroCount, section: SectionLayoutKind.main.rawValue)] = model
			}
		}

		self.cache = movedCache
	}

	// MARK: - Functions
	private func configureView() {
		self.collectionView.contentInset.top = Self.toolbarHeight
		self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset

		self.configureTabBarView()
		self.configureToolbar()
		self.configureViewHierarchy()
		self.configureViewConstraints()

		let tabBarBarButtonItem = UIBarButtonItem(customView: self.tabBarView)
		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			tabBarBarButtonItem.hidesSharedBackground = true
		}
		self.toolbar.setItems([tabBarBarButtonItem], animated: false)
	}

	private func configureTabBarView() {
		self.tabBarView.delegate = self
		self.tabBarView.dataSource = self
		self.tabBarView.reloadData(at: 0 ... Kind.allCases.count - 1, context: .full)
		self.updateBar(to: CGFloat(self.kind.rawValue), animated: false)
		self.styleTabBarView()
	}

	private func updateBar(to position: CGFloat, animated: Bool) {
		let animation = TMAnimation(isEnabled: animated, duration: 0.25)
		self.tabBarView.update(for: position, capacity: Kind.allCases.count, direction: .forward, animation: animation)
	}

	private func styleTabBarView() {
		self.tabBarView.backgroundView.style = .clear
		self.tabBarView.indicator.layout(in: self.tabBarView)
		self.tabBarView.scrollMode = .interactive
		self.tabBarView.buttons.customize { button in
			button.contentInset = UIEdgeInsets(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0)
			button.selectedTintColor = KThemePicker.textColor.colorValue
			button.tintColor = button.selectedTintColor.withAlphaComponent(0.50)
		}
		self.tabBarView.layout.interButtonSpacing = 0.0
		self.tabBarView.layout.contentMode = .intrinsic
		self.tabBarView.fadesContentEdges = true
	}

	private func configureToolbar() {
		self.toolbar.translatesAutoresizingMaskIntoConstraints = false
		self.toolbar.delegate = self
		self.toolbar.isTranslucent = false
		self.toolbar.backgroundColor = .clear
		self.toolbar.barStyle = .default
		self.toolbar.theme_tintColor = KThemePicker.tintColor.rawValue
		self.toolbar.theme_barTintColor = KThemePicker.barTintColor.rawValue

		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			let interaction = UIScrollEdgeElementContainerInteraction()
			interaction.scrollView = self.collectionView
			interaction.edge = .top
			self.toolbar.addInteraction(interaction)
			self.topScrollEdgeInteraction = interaction
		}
	}

	private func configureViewHierarchy() {
		self.view.addSubview(self.toolbar)
	}

	private func configureViewConstraints() {
		NSLayoutConstraint.activate([
			self.toolbar.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
			self.toolbar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.toolbar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.toolbar.heightAnchor.constraint(equalToConstant: Self.toolbarHeight),
		])

		self.tabBarView.fillToSuperview()
	}

	/// Configures the sort and dim library bar button items.
	private func configureNavBarButtons() {
		self.sortBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down.circle"))
		self.sortBarButtonItem.accessibilityLabel = L10n.sort
		self.rebuildSortMenu()

		self.dimLibraryBarButtonItem = UIBarButtonItem(
			image: UIImage(systemName: "rectangle.stack.fill"),
			primaryAction: UIAction { [weak self] _ in
				guard let self = self else { return }
				self.handleDimLibraryButtonPressed()
			}
		)
		self.dimLibraryBarButtonItem.accessibilityLabel = L10n.dimLibrary
		self.dimLibraryBarButtonItem.accessibilityValue = L10n.off

		self.updateNavBarButtons()
	}

	/// Rebuilds the sort menu.
	private func rebuildSortMenu() {
		let actions = TrailerSort.allCases.map { sort in
			UIAction(title: sort.title, state: sort == self.sort ? .on : .off) { [weak self] _ in
				self?.handleSortSelected(sort)
			}
		}

		self.sortBarButtonItem.menu = UIMenu(title: L10n.sort, children: actions)
	}

	/// Shows the dim library button alongside the sort only while a user is signed in.
	private func updateNavBarButtons() {
		var barButtonItems: [UIBarButtonItem] = [self.sortBarButtonItem]

		if User.isSignedIn {
			barButtonItems.append(self.dimLibraryBarButtonItem)
		}

		self.navigationItem.rightBarButtonItems = barButtonItems
	}

	/// Reloads the collection under the newly selected order.
	///
	/// - Parameter sort: The order the user picked.
	private func handleSortSelected(_ sort: TrailerSort) {
		guard sort != self.sort else { return }
		self.sort = sort
		self.rebuildSortMenu()
		self.reloadForQueryChange()
	}

	/// Clears the loaded titles and reloads from the first page.
	private func reloadForQueryChange() {
		self.nextPageCursor = nil
		self.showIdentities = []
		self.gameIdentities = []
		self.cache = [:]
		self.updateDataSource()
		self._prefersActivityIndicatorHidden = false

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchItems()
		}
	}

	override func handleRefreshControl() {
		self.reloadForQueryChange()
	}

	/// The number of loaded identities for the current kind.
	private var loadedCount: Int {
		switch self.kind {
		case .shows: return self.showIdentities.count
		case .games: return self.gameIdentities.count
		}
	}

	override func fetchItems() async {
		guard !self.isRequestInProgress else { return }
		self.isRequestInProgress = true

		defer { self.endFetch() }

		do {
			switch self.kind {
			case .shows:
				let response = try await KService.showTrailers(sortedBy: self.sort).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.showIdentities = []
					self.trailerURLs = [:]
				}

				self.nextPageCursor = response.nextCursor
				self.absorb(response.data)
				self.showIdentities.append(contentsOf: response.data.compactMap(\.parent))
				self.showIdentities.removeDuplicates()
			case .games:
				let response = try await KService.gameTrailers(sortedBy: self.sort).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.gameIdentities = []
					self.trailerURLs = [:]
				}

				self.nextPageCursor = response.nextCursor
				self.absorb(response.data)
				self.gameIdentities.append(contentsOf: response.data.compactMap(\.parent))
				self.gameIdentities.removeDuplicates()
			}
		} catch {
			print(error.localizedDescription)
		}
	}

	/// Remembers which trailer the feed picked for each title.
	///
	/// - Parameter trailers: The trailers the feed returned.
	private func absorb<Parent: KurozoraItem & Codable & Hashable>(_ trailers: [Trailer<Parent>]) {
		for trailer in trailers {
			guard let parent = trailer.parent else { continue }
			self.trailerURLs[parent.id] = trailer.attributes.url
		}
	}

	// MARK: - Library dimming
	/// Subscribes to local library mutations affecting the visible cells.
	private func observeLibraryChanges() {
		guard let slug = User.current?.attributes.slug else {
			self.libraryObserver = nil
			return
		}
		self.libraryObserver = LocalLibraryEntryObserver(
			matching: LocalLibraryEntryObserver.matches(userSlug: slug),
			onChange: { [weak self] _ in
				self?.refreshVisibleDimming()
			},
			onRemove: { [weak self] _ in
				self?.refreshVisibleDimming()
			}
		)
	}

	/// Handles dim library button pressed.
	private func handleDimLibraryButtonPressed() {
		self.dimsLibraryEntries.toggle()
		self.dimLibraryBarButtonItem.image = UIImage(systemName: self.dimsLibraryEntries ? "rectangle.stack.slash.fill" : "rectangle.stack.fill")
		self.dimLibraryBarButtonItem.accessibilityValue = self.dimsLibraryEntries ? L10n.on : L10n.off
		self.refreshVisibleDimming()
	}

	/// Whether the cell at the given index path should be dimmed.
	///
	/// - Parameter indexPath: The index path of the cell.
	///
	/// - Returns: `true` when dimming is on and the underlying title is in the user's library.
	private func isDimmed(at indexPath: IndexPath) -> Bool {
		guard self.dimsLibraryEntries else { return false }

		let libraryKind: LibraryKind = self.kind == .games ? .games : .shows
		guard let trackable = self.cachedModel(at: indexPath) else { return false }
		let libraryStatus = LibraryStore.shared.effectiveLibrary(forTrackableID: trackable.id.rawValue, kind: libraryKind)?.status ?? .none
		return libraryStatus != .none
	}

	/// Re-applies dimming to the visible cells.
	private func refreshVisibleDimming() {
		for indexPath in self.collectionView.indexPathsForVisibleItems {
			guard let cell = self.collectionView.cellForItem(at: indexPath) as? BaseLockupCollectionViewCell else { continue }
			cell.setDimmed(self.isDimmed(at: indexPath))
		}
	}

	/// Handles the user's sign-in state changing.
	@objc private func handleUserSignedInDidChange() {
		self.updateNavBarButtons()
		self.observeLibraryChanges()

		if !User.isSignedIn, self.dimsLibraryEntries {
			self.dimsLibraryEntries = false
			self.dimLibraryBarButtonItem.image = UIImage(systemName: "rectangle.stack.fill")
			self.dimLibraryBarButtonItem.accessibilityValue = L10n.off
			self.refreshVisibleDimming()
		}
	}

	// MARK: - SectionFetchable
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .showIdentity(let id): return id as? Element
		case .gameIdentity(let id): return id as? Element
		}
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .showDetailsSegue: return ShowDetailsCollectionViewController()
		case .gameDetailsSegue: return GameDetailsCollectionViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .showDetailsSegue:
			guard let destination = destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			destination.show = show
		case .gameDetailsSegue:
			guard let destination = destination as? GameDetailsCollectionViewController else { return }
			guard let game = sender as? Game else { return }
			destination.game = game
		}
	}
}

// MARK: - KCollectionViewDataSource
extension TrailersCollectionViewController {
	override func configureDataSource() {
		let lockupCellRegistration = self.getConfiguredLockupCell()
		let heroCellRegistration = self.getConfiguredHeroCell()
		let queueCellRegistration = self.getConfiguredQueueCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] collectionView, indexPath, itemKind in
			guard let self = self else { return nil }

			guard SectionLayoutKind(rawValue: indexPath.section) == .hero else {
				return collectionView.dequeueConfiguredReusableCell(using: lockupCellRegistration, for: indexPath, item: itemKind)
			}

			if self.listsQueue, indexPath.item > 0 {
				return collectionView.dequeueConfiguredReusableCell(using: queueCellRegistration, for: indexPath, item: itemKind)
			}

			return collectionView.dequeueConfiguredReusableCell(using: heroCellRegistration, for: indexPath, item: itemKind)
		}

		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		self.snapshot.appendSections([.hero, .main])
		self.dataSource.apply(self.snapshot)
	}

	override func updateDataSource() {
		self.updateSnapshot()
		self.dataSource.apply(self.snapshot)
		self.collectionView.collectionViewLayout.invalidateLayout()
	}

	/// Rebuilds the snapshot from the loaded identities.
	private func updateSnapshot() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		self.snapshot.appendSections([.hero, .main])

		let items: [ItemKind] = switch self.kind {
		case .shows: self.showIdentities.map { .showIdentity($0) }
		case .games: self.gameIdentities.map { .gameIdentity($0) }
		}

		self.snapshot.appendItems(Array(items.prefix(self.heroCount)), toSection: .hero)
		self.snapshot.appendItems(Array(items.dropFirst(self.heroCount)), toSection: .main)
	}

	/// Resolves the title an item stands for.
	///
	/// - Parameters:
	///    - itemKind: The item being configured.
	///    - indexPath: The index path of the item.
	///
	/// - Returns: the title, and the trailer the feed picked for it.
	private func resolve(_ itemKind: ItemKind, at indexPath: IndexPath) -> (show: Show?, game: Game?, trailerURL: String?) {
		switch itemKind {
		case .showIdentity(let identity):
			let show = self.cachedModel(at: indexPath) as? Show

			if show == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
				Task {
					await self.fetchSectionIfNeeded(ResourceCollection<Show>.self, ShowIdentity.self, at: indexPath, itemKind: itemKind)
				}
			}

			return (show, nil, self.trailerURLs[identity.id])
		case .gameIdentity(let identity):
			let game = self.cachedModel(at: indexPath) as? Game

			if game == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
				Task {
					await self.fetchSectionIfNeeded(ResourceCollection<Game>.self, GameIdentity.self, at: indexPath, itemKind: itemKind)
				}
			}

			return (nil, game, self.trailerURLs[identity.id])
		}
	}

	private func getConfiguredLockupCell() -> UICollectionView.CellRegistration<TrailerLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<TrailerLockupCollectionViewCell, ItemKind> { [weak self] cell, indexPath, itemKind in
			guard let self = self else { return }
			let resolved = self.resolve(itemKind, at: indexPath)

			cell.delegate = self
			cell.preferredTrailerURL = resolved.trailerURL

			if case .gameIdentity = itemKind {
				cell.configure(using: resolved.game)
			} else {
				cell.configure(using: resolved.show)
			}

			cell.setDimmed(self.isDimmed(at: indexPath))
		}
	}

	private func getConfiguredHeroCell() -> UICollectionView.CellRegistration<TrailerHeroCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<TrailerHeroCollectionViewCell, ItemKind> { [weak self] cell, indexPath, itemKind in
			guard let self = self else { return }
			let resolved = self.resolve(itemKind, at: indexPath)

			cell.delegate = self
			cell.preferredTrailerURL = resolved.trailerURL

			if case .gameIdentity = itemKind {
				cell.configure(using: resolved.game)
			} else {
				cell.configure(using: resolved.show)
			}

			cell.setDimmed(self.isDimmed(at: indexPath))
		}
	}

	private func getConfiguredQueueCell() -> UICollectionView.CellRegistration<TrailerQueueCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<TrailerQueueCollectionViewCell, ItemKind> { [weak self] cell, indexPath, itemKind in
			guard let self = self else { return }
			let resolved = self.resolve(itemKind, at: indexPath)

			cell.delegate = self

			if case .gameIdentity = itemKind {
				cell.configure(using: resolved.game)
			} else {
				cell.configure(using: resolved.show)
			}

			cell.setDimmed(self.isDimmed(at: indexPath))
		}
	}
}

// MARK: - KCollectionViewDelegateLayout
extension TrailersCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		let columnCount = Int(width >= 414 ? (width / 384).rounded() : (width / 284).rounded())
		return columnCount > 0 ? columnCount : 1
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] section, layoutEnvironment in
			guard let self = self else { return nil }

			if SectionLayoutKind(rawValue: section) == .hero {
				return Layouts.trailerHeroSection(section, layoutEnvironment: layoutEnvironment, queueCount: self.heroCount - 1, listsQueue: self.listsQueue)
			}

			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
			return Layouts.videoSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
		}
	}
}

// MARK: - UICollectionViewDelegate
extension TrailersCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if SectionLayoutKind(rawValue: indexPath.section) == .hero, self.listsQueue, indexPath.item > 0 {
			self.featureTrailer(at: indexPath)

			return
		}

		switch self.kind {
		case .shows:
			guard let show = self.cachedModel(at: indexPath) as? Show else { return }
			self.show(.showDetailsSegue, sender: show)
		case .games:
			guard let game = self.cachedModel(at: indexPath) as? Game else { return }
			self.show(.gameDetailsSegue, sender: game)
		}
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		guard SectionLayoutKind(rawValue: indexPath.section) == .main else { return }
		self.paginateIfNeeded(at: indexPath, totalItems: self.loadedCount - self.heroCount)
	}

	/// Plays the trailer at the given index path, sending the one it replaces to the back of the queue.
	///
	/// - Parameter indexPath: The index path of the queue entry that was tapped.
	private func featureTrailer(at indexPath: IndexPath) {
		let heroCount = self.snapshot.numberOfItems(inSection: .hero)

		guard indexPath.item > 0, indexPath.item < heroCount else { return }

		var order = Array(0..<heroCount)
		order.insert(order.remove(at: indexPath.item), at: 0)
		order.append(order.remove(at: 1))

		switch self.kind {
		case .shows:
			self.showIdentities.replaceSubrange(0..<heroCount, with: order.map { self.showIdentities[$0] })
		case .games:
			self.gameIdentities.replaceSubrange(0..<heroCount, with: order.map { self.gameIdentities[$0] })
		}

		let models = order.map { self.cache[IndexPath(item: $0, section: indexPath.section)] }

		for (position, model) in models.enumerated() {
			self.cache[IndexPath(item: position, section: indexPath.section)] = model
		}

		self.updateDataSource()

		let heroItems = self.snapshot.itemIdentifiers(inSection: .hero)

		if let featured = heroItems.first, let benched = heroItems.last {
			self.snapshot.reloadItems([featured, benched])
			self.dataSource.apply(self.snapshot)
		}
	}

	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let collectionViewCell = collectionView.cellForItem(at: indexPath)

		switch self.kind {
		case .shows:
			guard let show = self.cachedModel(at: indexPath) as? Show else { return nil }
			return show.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .games:
			guard let game = self.cachedModel(at: indexPath) as? Game else { return nil }
			return game.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		}
	}
}

// MARK: - TMBarDataSource
extension TrailersCollectionViewController: TMBarDataSource {
	func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
		guard let kind = Kind(rawValue: index) else { return TMBarItem(title: "") }
		return TMBarItem(title: kind.title)
	}
}

// MARK: - TMBarDelegate
extension TrailersCollectionViewController: TMBarDelegate {
	func bar(_ bar: TMBar, didRequestScrollTo index: Int) {
		guard let kind = Kind(rawValue: index), kind != self.kind else { return }

		self.updateBar(to: CGFloat(index), animated: true)
		self.kind = kind
		self.configureEmptyDataView()
		self.reloadForQueryChange()
	}
}

// MARK: - UIToolbarDelegate
extension TrailersCollectionViewController: UIToolbarDelegate {
	func position(for bar: UIBarPositioning) -> UIBarPosition {
		return .topAttached
	}
}

// MARK: - BaseLockupCollectionViewCellDelegate
extension TrailersCollectionViewController: BaseLockupCollectionViewCellDelegate {
	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressStatus button: UIButton) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard signedIn else { return }
		guard let indexPath = self.collectionView.indexPath(for: cell), let target = self.cachedModel(at: indexPath) as? Libraryable else { return }

		let oldLibraryStatus = cell.libraryStatus
		let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: LibraryStatus.alertControllerItems(for: cell.libraryKind), currentSelection: oldLibraryStatus, action: { title, value in
			Task {
				await target.addToLibrary(status: value)
				cell.libraryStatus = value
				button.setTitle("\(title) ▾", for: .normal)
			}
		})

		if cell.libraryStatus != .none {
			actionSheetAlertController.addAction(UIAlertAction(title: L10n.removeFromLibrary, style: .destructive) { _ in
				Task {
					await target.removeFromLibrary()
					cell.libraryStatus = .none
					button.setTitle(L10n.add.uppercased(with: Locale.current), for: .normal)
				}
			})
		}

		if let popoverController = actionSheetAlertController.popoverPresentationController {
			popoverController.sourceView = button
			popoverController.sourceRect = button.bounds
		}

		if (self.navigationController?.visibleViewController as? UIAlertController) == nil {
			self.present(actionSheetAlertController, animated: true, completion: nil)
		}
	}

	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressReminder button: UIButton) async {
		guard let indexPath = self.collectionView.indexPath(for: cell), let show = self.cachedModel(at: indexPath) as? Show else { return }

		await show.toggleReminder(on: self)
		cell.configureReminderButton(for: show.libraryAttributes?.reminderStatus)
	}
}
