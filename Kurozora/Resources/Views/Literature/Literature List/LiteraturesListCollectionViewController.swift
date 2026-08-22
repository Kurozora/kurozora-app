//
//  LiteraturesListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/02/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// A source of literatures for ``LiteraturesListCollectionViewController``.
enum LiteraturesListFetchType {
	case show
	case game
	case character
	case charts
	case explore
	case person
	case moreByStudio
	case relatedLiterature
	case search
	case studio
	case upcoming
}

/// A paginated list of literatures (or related literatures).
class LiteraturesListCollectionViewController: ListCollectionViewController, SectionFetchable, TypedSegueHandling {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case literatureDetailsSegue
	}

	/// The section identifier.
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}

	/// An item displayed in the list.
	enum ItemKind: Hashable {
		case literatureIdentity(_: LiteratureIdentity)
		case relatedLiterature(_: RelatedLiterature)
	}

	// MARK: - Properties
	var showIdentity: ShowIdentity?
	var gameIdentity: GameIdentity?
	var personIdentity: PersonIdentity?
	var characterIdentity: CharacterIdentity?
	var literatureIdentity: LiteratureIdentity?
	var studioIdentity: StudioIdentity?
	var exploreCategoryIdentity: ExploreCategoryIdentity?

	var literatureIdentities: [LiteratureIdentity] = []
	var relatedLiteratures: [RelatedLiterature] = []

	var searchQuery: String = ""
	var literaturesListFetchType: LiteraturesListFetchType = .search

	// MARK: - Views
	/// The bar button item that dims titles already in the user's library.
	private var dimLibraryBarButtonItem: UIBarButtonItem!

	// MARK: - SectionFetchable
	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	/// Whether titles already in the user's library are dimmed.
	private var dimsLibraryEntries = false

	/// Observes local library mutations to refresh visible cells.
	private var libraryObserver: LocalLibraryEntryObserver?

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	override var emptyStateImage: UIImage? { .Empty.libraryManga }
	override var emptyStateTitle: String {
		switch self.literaturesListFetchType {
		case .charts: return L10n.noItemsTitle(L10n.topCharts)
		default: return L10n.noItemsTitle(L10n.literatures)
		}
	}
	override var emptyStateDetail: String {
		switch self.literaturesListFetchType {
		case .charts: return L10n.cantGetListRefresh(L10n.topCharts.lowercased(with: .current))
		default: return L10n.cantGetListRefresh(L10n.literatures.lowercased(with: .current))
		}
	}

	override var hasLoadedInitialData: Bool {
		!self.literatureIdentities.isEmpty || !self.relatedLiteratures.isEmpty
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		if self.literaturesListFetchType == .charts {
			self.title = L10n.xTopCharts(L10n.literatures)
		}

		self.configureDimLibraryBarButtonItem()
		self.observeLibraryChanges()

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(self.handleUserSignedInDidChange),
			name: .KUserIsSignedInDidChange,
			object: nil
		)
	}

	/// Subscribes to local library mutations affecting the visible cells.
	private func observeLibraryChanges() {
		guard let slug = User.current?.attributes.slug else {
			self.libraryObserver = nil
			return
		}
		self.libraryObserver = LocalLibraryEntryObserver(
			matching: LocalLibraryEntryObserver.matches(userSlug: slug, kind: .literatures),
			onChange: { [weak self] entry in
				self?.applyLibraryEntryChange(forTrackableID: entry.trackableID, isRemoval: false)
			},
			onRemove: { [weak self] removed in
				self?.applyLibraryEntryChange(forTrackableID: removed.trackableID, isRemoval: true)
			}
		)
	}

	/// Updates every visible cell whose underlying literature matches the given entry's trackable identity.
	private func applyLibraryEntryChange(forTrackableID trackableID: String, isRemoval: Bool) {
		var matchedItems: [ItemKind] = []
		let currentSnapshot = self.dataSource.snapshot()

		for item in currentSnapshot.itemIdentifiers {
			switch item {
			case .literatureIdentity(let identity):
				if identity.id.rawValue == trackableID,
				   let index = currentSnapshot.indexOfItem(item),
				   let literature = self.cache[IndexPath(item: index, section: 0)] as? Literature {
					matchedItems.append(item)
				}
			case .relatedLiterature(let relatedLiterature):
				if relatedLiterature.literature.id.rawValue == trackableID {
					matchedItems.append(item)
				}
			}
		}

		guard !matchedItems.isEmpty else { return }
		var snapshot = currentSnapshot
		snapshot.reconfigureItems(matchedItems)
		self.dataSource.apply(snapshot, animatingDifferences: false)
	}

	/// Creates the bar button item that dims titles already in the user's library.
	private func configureDimLibraryBarButtonItem() {
		self.dimLibraryBarButtonItem = UIBarButtonItem(
			image: UIImage(systemName: "rectangle.stack.fill"),
			primaryAction: UIAction { [weak self] _ in
				guard let self = self else { return }
				self.handleDimLibraryButtonPressed()
			}
		)
		self.dimLibraryBarButtonItem.accessibilityLabel = L10n.dimLibrary
		self.dimLibraryBarButtonItem.accessibilityValue = L10n.off

		self.updateDimLibraryBarButtonItem()
	}

	/// Shows the dim library button on the charts list while a user is signed in.
	private func updateDimLibraryBarButtonItem() {
		let isAvailable = self.literaturesListFetchType == .charts && User.isSignedIn

		if isAvailable {
			self.navigationItem.rightBarButtonItem = self.dimLibraryBarButtonItem
		} else if self.navigationItem.rightBarButtonItem === self.dimLibraryBarButtonItem {
			self.navigationItem.rightBarButtonItem = nil
		}
	}

	/// Handles dim library button pressed.
	private func handleDimLibraryButtonPressed() {
		self.dimsLibraryEntries.toggle()
		self.reflectDimLibraryState()
	}

	/// Reflects the dim library state on the button and the visible cells.
	private func reflectDimLibraryState() {
		self.dimLibraryBarButtonItem.image = UIImage(systemName: self.dimsLibraryEntries ? "rectangle.stack.slash.fill" : "rectangle.stack.fill")
		self.dimLibraryBarButtonItem.accessibilityValue = self.dimsLibraryEntries ? L10n.on : L10n.off
		self.refreshVisibleDimming()
	}

	/// Whether the given literature is in the signed-in user's library.
	///
	/// - Parameter literature: The literature to look up.
	///
	/// - Returns: `true` when the literature has a local library status.
	private func isLiteratureInLibrary(_ literature: Literature) -> Bool {
		let libraryStatus = LibraryStore.shared.effectiveLibrary(forTrackableID: literature.id.rawValue, kind: .literatures)?.status ?? .none
		return libraryStatus != .none
	}

	/// Whether the cell at the given index path should be dimmed.
	///
	/// - Parameter indexPath: The index path of the cell.
	///
	/// - Returns: `true` when dimming is on and the underlying literature is in the user's library.
	private func isDimmed(at indexPath: IndexPath) -> Bool {
		guard self.dimsLibraryEntries else { return false }
		guard let literature = (self.cache[indexPath] as? Literature) ?? self.relatedLiteratures[safe: indexPath.item]?.literature else { return false }
		return self.isLiteratureInLibrary(literature)
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
		self.updateDimLibraryBarButtonItem()
		self.observeLibraryChanges()

		if !User.isSignedIn, self.dimsLibraryEntries {
			self.dimsLibraryEntries = false
			self.reflectDimLibraryState()
		}
	}

	override func fetchItems() async {
		guard !self.isRequestInProgress else { return }
		self.isRequestInProgress = true

		defer { self.endFetch() }

		do {
			switch self.literaturesListFetchType {
			case .show:
				guard let showIdentity = self.showIdentity else { return }
				let response = try await KService.relatedLiteratures(for: showIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.relatedLiteratures = []
					self.literatureIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.relatedLiteratures.append(contentsOf: response.data)
				self.relatedLiteratures.removeDuplicates()
			case .game:
				guard let gameIdentity = self.gameIdentity else { return }
				let response = try await KService.relatedLiteratures(for: gameIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.relatedLiteratures = []
					self.literatureIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.relatedLiteratures.append(contentsOf: response.data)
				self.relatedLiteratures.removeDuplicates()
			case .character:
				guard let characterIdentity = self.characterIdentity else { return }
				let response = try await KService.literatures(for: characterIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.literatureIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.literatureIdentities.append(contentsOf: response.data)
				self.literatureIdentities.removeDuplicates()
			case .charts:
				let response = try await KService.topLiteratures().cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.literatureIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.literatureIdentities.append(contentsOf: response.data)
				self.literatureIdentities.removeDuplicates()
			case .person:
				guard let personIdentity = self.personIdentity else { return }
				let response = try await KService.literatures(for: personIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.literatureIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.literatureIdentities.append(contentsOf: response.data)
				self.literatureIdentities.removeDuplicates()
			case .search:
				let searchResponse = try await KService.search(.kurozora, types: [.literatures], query: self.searchQuery).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).filter(nil).response()

				if self.nextPageCursor == nil {
					self.relatedLiteratures = []
					self.literatureIdentities = []
				}

				self.nextPageCursor = searchResponse.data.literatures?.nextCursor
				self.literatureIdentities.append(contentsOf: searchResponse.data.literatures?.data ?? [])
				self.literatureIdentities.removeDuplicates()
			case .moreByStudio:
				guard let literatureIdentity = self.literatureIdentity else { return }
				let response = try await KService.moreByStudio(for: literatureIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.literatureIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.literatureIdentities.append(contentsOf: response.data)
				self.literatureIdentities.removeDuplicates()
			case .relatedLiterature:
				guard let literatureIdentity = self.literatureIdentity else { return }
				let response = try await KService.relatedLiteratures(for: literatureIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.relatedLiteratures = []
					self.literatureIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.relatedLiteratures.append(contentsOf: response.data)
				self.relatedLiteratures.removeDuplicates()
			case .studio:
				guard let studioIdentity = self.studioIdentity else { return }
				let response = try await KService.literatures(for: studioIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.literatureIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.literatureIdentities.append(contentsOf: response.data)
				self.literatureIdentities.removeDuplicates()
			case .upcoming:
				let response = try await KService.upcomingLiteratures().cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.literatureIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.literatureIdentities.append(contentsOf: response.data)
				self.literatureIdentities.removeDuplicates()
			case .explore:
				guard let exploreCategoryIdentity = self.exploreCategoryIdentity else { return }
				let response = try await KService.exploreCategory(exploreCategoryIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.relatedLiteratures = []
					self.literatureIdentities = []
				}

				self.nextPageCursor = response.data.first?.relationships.literatures?.nextCursor
				self.literatureIdentities.append(contentsOf: response.data.first?.relationships.literatures?.data ?? [])
				self.literatureIdentities.removeDuplicates()
			}
		} catch {
			print(error.localizedDescription)
		}
	}

	// MARK: - SectionFetchable
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .literatureIdentity(let id): return id as? Element
		default: return nil
		}
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .literatureDetailsSegue: return LiteratureDetailsCollectionViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .literatureDetailsSegue:
			guard let destination = destination as? LiteratureDetailsCollectionViewController else { return }
			guard let literature = sender as? Literature else { return }
			destination.literature = literature
		}
	}
}

// MARK: - KCollectionViewDataSource
extension LiteraturesListCollectionViewController {
	override func configureDataSource() {
		let smallLockupCellRegistration = self.getConfiguredSmallCell()
		let upcomingLockupCellRegistration = self.getConfiguredUpcomingCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] collectionView, indexPath, itemKind in
			guard let self = self else { return nil }

			switch self.literaturesListFetchType {
			case .upcoming:
				return collectionView.dequeueConfiguredReusableCell(using: upcomingLockupCellRegistration, for: indexPath, item: itemKind)
			default:
				return collectionView.dequeueConfiguredReusableCell(using: smallLockupCellRegistration, for: indexPath, item: itemKind)
			}
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		self.snapshot.appendSections([.main])

		switch self.literaturesListFetchType {
		case .relatedLiterature, .show, .game:
			let items: [ItemKind] = self.relatedLiteratures.map { .relatedLiterature($0) }
			self.snapshot.appendItems(items, toSection: .main)
		default:
			let items: [ItemKind] = self.literatureIdentities.map { .literatureIdentity($0) }
			self.snapshot.appendItems(items, toSection: .main)
		}

		self.dataSource.apply(self.snapshot)
	}

	private func getConfiguredSmallCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: SmallLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .literatureIdentity:
				let literature: Literature? = self.fetchModel(at: indexPath)

				if literature == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ResourceCollection<Literature>.self, LiteratureIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				cell.delegate = self
				cell.configure(using: literature, rank: self.literaturesListFetchType == .charts ? indexPath.item + 1 : nil)
				cell.setDimmed(self.isDimmed(at: indexPath))
			case .relatedLiterature(let relatedLiterature):
				cell.delegate = self
				cell.configure(using: relatedLiterature)
				cell.setDimmed(self.isDimmed(at: indexPath))
			}
		}
	}

	private func getConfiguredUpcomingCell() -> UICollectionView.CellRegistration<UpcomingLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<UpcomingLockupCollectionViewCell, ItemKind>(cellNib: UpcomingLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .literatureIdentity:
				let literature: Literature? = self.fetchModel(at: indexPath)

				if literature == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ResourceCollection<Literature>.self, LiteratureIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				cell.delegate = self
				cell.configure(using: literature)
				cell.setDimmed(self.isDimmed(at: indexPath))
			default: break
			}
		}
	}
}

// MARK: - KCollectionViewDelegateLayout
extension LiteraturesListCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		let columnCount = Int(width >= 414 ? (width / 384).rounded() : (width / 284).rounded())
		return columnCount > 0 ? columnCount : 1
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] section, layoutEnvironment in
			guard let self = self else { return nil }
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)

			if self.literaturesListFetchType == .upcoming {
				return Layouts.upcomingSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
			}

			return Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
		}
	}
}

// MARK: - UICollectionViewDelegate
extension LiteraturesListCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let literature = self.cache[indexPath] as? Literature
		let relatedLiterature = self.relatedLiteratures[safe: indexPath.item]?.literature
		guard let literature = literature ?? relatedLiterature else { return }

		self.show(.literatureDetailsSegue, sender: literature)
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		switch self.literaturesListFetchType {
		case .relatedLiterature, .show, .game:
			self.paginateIfNeeded(at: indexPath, totalItems: self.relatedLiteratures.count)
		default:
			self.paginateIfNeeded(at: indexPath, totalItems: self.literatureIdentities.count)
		}
	}

	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let collectionViewCell = collectionView.cellForItem(at: indexPath)

		switch self.literaturesListFetchType {
		case .relatedLiterature, .show, .game:
			guard let literature = self.relatedLiteratures[safe: indexPath.item]?.literature else { return nil }
			return literature.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		default:
			guard let literature = self.cache[indexPath] as? Literature else { return nil }
			return literature.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		}
	}
}

// MARK: - BaseLockupCollectionViewCellDelegate
extension LiteraturesListCollectionViewController: BaseLockupCollectionViewCellDelegate {
	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressStatus button: UIButton) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard signedIn else { return }
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		let literature = (self.cache[indexPath] as? Literature) ?? self.relatedLiteratures[indexPath.item].literature

		let oldLibraryStatus = cell.libraryStatus
		let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: LibraryStatus.alertControllerItems(for: cell.libraryKind), currentSelection: oldLibraryStatus, action: { title, value in
			Task {
				await literature.addToLibrary(status: value)
				cell.libraryStatus = value
				button.setTitle("\(title) ▾", for: .normal)
			}
		})

		if cell.libraryStatus != .none {
			actionSheetAlertController.addAction(UIAlertAction(title: L10n.removeFromLibrary, style: .destructive) { _ in
				Task {
					await literature.removeFromLibrary()
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
