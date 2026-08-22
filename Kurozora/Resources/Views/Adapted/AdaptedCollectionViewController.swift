//
//  AdaptedCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import Tabman
import UIKit

/// A collection of the titles adapted to anime.
class AdaptedCollectionViewController: KCollectionViewController, SectionFetchable, TypedSegueHandling {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case literatureDetailsSegue
		case gameDetailsSegue
	}

	/// The kinds of titles the collection lists.
	enum Kind: Int, CaseIterable {
		case literatures
		case games

		/// The localized title of the kind.
		var title: String {
			switch self {
			case .literatures: return L10n.literatures
			case .games: return L10n.games
			}
		}
	}

	/// The section identifier.
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}

	/// An item displayed in the collection.
	enum ItemKind: Hashable {
		case literatureIdentity(_: LiteratureIdentity)
		case gameIdentity(_: GameIdentity)
	}

	// MARK: - Views
	/// The height of the tab bar toolbar.
	private static let toolbarHeight: CGFloat = 49.0

	let toolbar = UIToolbar()
	let tabBarView = TMBar.KBar()

	/// The bar button item presenting the adaptation filter.
	private var filterBarButtonItem: UIBarButtonItem!

	/// The bar button item that dims titles already in the user's library.
	private var dimLibraryBarButtonItem: UIBarButtonItem!

	/// The toolbar's scroll-edge interaction.
	private var topScrollEdgeInteraction: UIInteraction?

	// MARK: - Properties
	/// The kind currently shown.
	private var kind: Kind = .literatures

	/// The airing status the collection is filtered by.
	private var filter: AdaptedFilter = .airing

	var literatureIdentities: [LiteratureIdentity] = []
	var gameIdentities: [GameIdentity] = []

	/// The cursor of the next page of results.
	var nextPageCursor: PageCursor?

	/// A Boolean value that indicates whether a fetch request is in progress.
	var isRequestInProgress: Bool = false

	// MARK: - SectionFetchable
	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	/// Whether titles already in the user's library are dimmed.
	private var dimsLibraryEntries = false

	/// The observer for local library mutations.
	private var libraryObserver: LocalLibraryEntryObserver?

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	// Refresh control
	override var prefersRefreshControlDisabled: Bool {
		return true
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

	// MARK: - View
	override func themeWillReload() {
		super.themeWillReload()

		self.styleTabBarView()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = L10n.adaptedToAnime
		self.navigationItem.largeTitleDisplayMode = .never

		self.configureView()
		self.configureDataSource()
		self.configureNavBarButtons()
		self.observeLibraryChanges()

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(self.handleUserSignedInDidChange),
			name: .KUserIsSignedInDidChange,
			object: nil
		)

		self._prefersActivityIndicatorHidden = false
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchItems()
		}
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

	/// Configures the filter and dim library bar button items.
	private func configureNavBarButtons() {
		self.filterBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle"))
		self.filterBarButtonItem.accessibilityLabel = L10n.filter
		self.rebuildFilterMenu()

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

	/// Rebuilds the filter menu.
	private func rebuildFilterMenu() {
		let actions = AdaptedFilter.allCases.map { filter in
			UIAction(title: filter.localizedTitle, state: filter == self.filter ? .on : .off) { [weak self] _ in
				self?.handleFilterSelected(filter)
			}
		}

		self.filterBarButtonItem.menu = UIMenu(title: L10n.filter, children: actions)
	}

	/// Updates the navigation bar buttons.
	private func updateNavBarButtons() {
		var barButtonItems: [UIBarButtonItem] = [self.filterBarButtonItem]

		if User.isSignedIn {
			barButtonItems.append(self.dimLibraryBarButtonItem)
		}

		self.navigationItem.rightBarButtonItems = barButtonItems
	}

	/// Applies the selected filter.
	///
	/// - Parameter filter: The filter to apply.
	private func handleFilterSelected(_ filter: AdaptedFilter) {
		guard filter != self.filter else { return }
		self.filter = filter
		self.rebuildFilterMenu()
		self.reloadForQueryChange()
	}

	/// Reloads the collection from the first page.
	private func reloadForQueryChange() {
		self.nextPageCursor = nil
		self.literatureIdentities = []
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

	/// The number of loaded titles for the current kind.
	private var loadedCount: Int {
		switch self.kind {
		case .literatures: return self.literatureIdentities.count
		case .games: return self.gameIdentities.count
		}
	}

	func fetchItems() async {
		guard !self.isRequestInProgress else { return }
		self.isRequestInProgress = true

		defer { self.endFetch() }

		do {
			switch self.kind {
			case .literatures:
				let response = try await KService.adaptedLiteratures(filter: self.filter).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.literatureIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.literatureIdentities.append(contentsOf: response.data)
				self.literatureIdentities.removeDuplicates()
			case .games:
				let response = try await KService.adaptedGames(filter: self.filter).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.gameIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.gameIdentities.append(contentsOf: response.data)
				self.gameIdentities.removeDuplicates()
			}
		} catch {
			print(error.localizedDescription)
		}
	}

	/// Ends the current fetch cycle.
	private func endFetch() {
		self.isRequestInProgress = false
		self.updateDataSource()
		self._prefersActivityIndicatorHidden = true
		self.toggleEmptyDataView()
	}

	/// Requests the next page when nearing the end of the collection.
	///
	/// - Parameter indexPath: The index path about to be displayed.
	private func paginateIfNeeded(at indexPath: IndexPath) {
		let totalItems = self.loadedCount
		guard totalItems > 0, self.nextPageCursor != nil else { return }

		let lastIndex = totalItems - 1
		var threshold = lastIndex / 8
		threshold = min(threshold, 15)
		threshold = lastIndex - threshold
		threshold = max(threshold, 1)

		if indexPath.item >= threshold {
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchItems()
			}
		}
	}

	// MARK: - Empty state
	override func configureEmptyDataView() {
		let emptyStateImage: UIImage = self.kind == .games ? .Empty.libraryGame : .Empty.libraryManga
		let detail = L10n.cantGetListRefresh(L10n.adaptedToAnime.lowercased(with: .current))

		self.emptyBackgroundView.configureImageView(image: emptyStateImage)
		self.emptyBackgroundView.configureLabels(title: L10n.noItemsTitle(L10n.adaptedToAnime), detail: detail)

		self.collectionView.backgroundView?.alpha = 0
	}

	/// Shows or hides the empty-data view.
	private func toggleEmptyDataView() {
		if self.snapshot.itemIdentifiers.isEmpty {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	// MARK: - Library dimming
	/// Subscribes to local library mutations.
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
	private func isDimmed(at indexPath: IndexPath) -> Bool {
		guard self.dimsLibraryEntries else { return false }

		let libraryKind: LibraryKind = self.kind == .games ? .games : .literatures
		guard let trackable = self.cache[indexPath] else { return false }
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
		case .literatureIdentity(let id): return id as? Element
		case .gameIdentity(let id): return id as? Element
		}
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .literatureDetailsSegue: return LiteratureDetailsCollectionViewController()
		case .gameDetailsSegue: return GameDetailsCollectionViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .literatureDetailsSegue:
			guard let destination = destination as? LiteratureDetailsCollectionViewController else { return }
			guard let literature = sender as? Literature else { return }
			destination.literature = literature
		case .gameDetailsSegue:
			guard let destination = destination as? GameDetailsCollectionViewController else { return }
			guard let game = sender as? Game else { return }
			destination.game = game
		}
	}
}

// MARK: - KCollectionViewDataSource
extension AdaptedCollectionViewController {
	override func configureDataSource() {
		let smallLockupCellRegistration = self.getConfiguredSmallCell()
		let gameLockupCellRegistration = self.getConfiguredGameCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { collectionView, indexPath, itemKind in
			switch itemKind {
			case .literatureIdentity:
				return collectionView.dequeueConfiguredReusableCell(using: smallLockupCellRegistration, for: indexPath, item: itemKind)
			case .gameIdentity:
				return collectionView.dequeueConfiguredReusableCell(using: gameLockupCellRegistration, for: indexPath, item: itemKind)
			}
		}

		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		self.snapshot.appendSections([.main])
		self.dataSource.apply(self.snapshot)
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		self.snapshot.appendSections([.main])

		switch self.kind {
		case .literatures:
			self.snapshot.appendItems(self.literatureIdentities.map { .literatureIdentity($0) }, toSection: .main)
		case .games:
			self.snapshot.appendItems(self.gameIdentities.map { .gameIdentity($0) }, toSection: .main)
		}

		self.dataSource.apply(self.snapshot)
	}

	private func getConfiguredSmallCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: SmallLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self else { return }

			let literature: Literature? = self.fetchModel(at: indexPath)

			if literature == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
				Task {
					await self.fetchSectionIfNeeded(ResourceCollection<Literature>.self, LiteratureIdentity.self, at: indexPath, itemKind: itemKind)
				}
			}

			cell.delegate = self
			cell.configure(using: literature, rank: nil)
			cell.setDimmed(self.isDimmed(at: indexPath))
		}
	}

	private func getConfiguredGameCell() -> UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind>(cellNib: GameLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self else { return }

			let game: Game? = self.fetchModel(at: indexPath)

			if game == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
				Task {
					await self.fetchSectionIfNeeded(ResourceCollection<Game>.self, GameIdentity.self, at: indexPath, itemKind: itemKind)
				}
			}

			cell.delegate = self
			cell.configure(using: game, rank: nil)
			cell.setDimmed(self.isDimmed(at: indexPath))
		}
	}
}

// MARK: - KCollectionViewDelegateLayout
extension AdaptedCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		let columnCount = Int(width >= 414 ? (width / 384).rounded() : (width / 284).rounded())
		return columnCount > 0 ? columnCount : 1
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] section, layoutEnvironment in
			guard let self = self else { return nil }
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
			return Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
		}
	}
}

// MARK: - UICollectionViewDelegate
extension AdaptedCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		switch self.kind {
		case .literatures:
			guard let literature = self.cache[indexPath] as? Literature else { return }
			self.show(.literatureDetailsSegue, sender: literature)
		case .games:
			guard let game = self.cache[indexPath] as? Game else { return }
			self.show(.gameDetailsSegue, sender: game)
		}
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		self.paginateIfNeeded(at: indexPath)
	}

	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let collectionViewCell = collectionView.cellForItem(at: indexPath)

		switch self.kind {
		case .literatures:
			guard let literature = self.cache[indexPath] as? Literature else { return nil }
			return literature.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .games:
			guard let game = self.cache[indexPath] as? Game else { return nil }
			return game.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		}
	}
}

// MARK: - TMBarDataSource
extension AdaptedCollectionViewController: TMBarDataSource {
	func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
		guard let kind = Kind(rawValue: index) else { return TMBarItem(title: "") }
		return TMBarItem(title: kind.title)
	}
}

// MARK: - TMBarDelegate
extension AdaptedCollectionViewController: TMBarDelegate {
	func bar(_ bar: TMBar, didRequestScrollTo index: Int) {
		guard let kind = Kind(rawValue: index), kind != self.kind else { return }

		self.updateBar(to: CGFloat(index), animated: true)
		self.kind = kind
		self.configureEmptyDataView()
		self.reloadForQueryChange()
	}
}

// MARK: - UIToolbarDelegate
extension AdaptedCollectionViewController: UIToolbarDelegate {
	func position(for bar: UIBarPositioning) -> UIBarPosition {
		return .topAttached
	}
}

// MARK: - BaseLockupCollectionViewCellDelegate
extension AdaptedCollectionViewController: BaseLockupCollectionViewCellDelegate {
	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressStatus button: UIButton) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard signedIn else { return }
		guard let indexPath = self.collectionView.indexPath(for: cell), let target = self.cache[indexPath] as? Libraryable else { return }

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

	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressReminder button: UIButton) async {}
}
