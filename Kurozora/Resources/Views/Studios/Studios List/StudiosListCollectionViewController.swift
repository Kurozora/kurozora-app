//
//  StudiosListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/06/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// A source of studios for ``StudiosListCollectionViewController``.
enum StudiosListFetchType {
	case charts
	case game
	case literature
	case show
	case search
}

/// A paginated list of studios.
class StudiosListCollectionViewController: ListCollectionViewController, SectionFetchable, TypedSegueHandling {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case studioDetailsSegue
	}

	/// The section identifier.
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}

	/// An item displayed in the list.
	enum ItemKind: Hashable {
		case studioIdentity(_: StudioIdentity)
	}

	// MARK: - Properties
	var gameIdentity: GameIdentity?
	var literatureIdentity: LiteratureIdentity?
	var showIdentity: ShowIdentity?
	var studioIdentities: [StudioIdentity] = []
	var searchQuery: String = ""
	var studiosListFetchType: StudiosListFetchType = .search

	// MARK: - SectionFetchable
	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	override var emptyStateImage: UIImage { .Empty.cast }

	override var emptyStateTitle: String {
		switch self.studiosListFetchType {
		case .charts: return L10n.noItemsTitle(L10n.topCharts)
		default: return L10n.noItemsTitle(L10n.studios)
		}
	}

	override var emptyStateDetail: String {
		switch self.studiosListFetchType {
		case .charts: return L10n.cantGetListDetail(L10n.topCharts.lowercased(with: .current))
		default: return L10n.cantGetListDetail(L10n.studios.lowercased(with: .current))
		}
	}

	override var hasLoadedInitialData: Bool {
		!self.studioIdentities.isEmpty
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = self.studiosListFetchType == .charts ? L10n.xTopCharts(L10n.studios) : L10n.studios

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshItems(L10n.studios.lowercased(with: Locale.current)))
		#endif
	}

	override func fetchItems() async {
		guard !self.isRequestInProgress else { return }
		self.isRequestInProgress = true

		defer {
			self.endFetch()

			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshItems(L10n.studios.lowercased(with: Locale.current)))
			#endif
		}

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.refreshingItems(L10n.studios.lowercased(with: Locale.current)))
		#endif

		do {
			switch self.studiosListFetchType {
			case .charts:
				let response = try await KService.topStudios().cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.studioIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.studioIdentities.append(contentsOf: response.data)
				self.studioIdentities.removeDuplicates()
			case .game:
				guard let gameIdentity = self.gameIdentity else { return }
				let response = try await KService.studios(for: gameIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.studioIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.studioIdentities.append(contentsOf: response.data)
				self.studioIdentities.removeDuplicates()
			case .literature:
				guard let literatureIdentity = self.literatureIdentity else { return }
				let response = try await KService.studios(for: literatureIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.studioIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.studioIdentities.append(contentsOf: response.data)
				self.studioIdentities.removeDuplicates()
			case .show:
				guard let showIdentity = self.showIdentity else { return }
				let response = try await KService.studios(for: showIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.studioIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.studioIdentities.append(contentsOf: response.data)
				self.studioIdentities.removeDuplicates()
			case .search:
				let searchResponse = try await KService.search(.kurozora, types: [.studios], query: self.searchQuery).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).filter(nil).response()

				if self.nextPageCursor == nil {
					self.studioIdentities = []
				}

				self.nextPageCursor = searchResponse.data.studios?.nextCursor
				self.studioIdentities.append(contentsOf: searchResponse.data.studios?.data ?? [])
				self.studioIdentities.removeDuplicates()
			}
		} catch {
			print(error.localizedDescription)
		}
	}

	// MARK: - SectionFetchable
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .studioIdentity(let id): return id as? Element
		}
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .studioDetailsSegue: return StudioDetailsCollectionViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .studioDetailsSegue:
			guard let destination = destination as? StudioDetailsCollectionViewController else { return }
			guard let studio = sender as? Studio else { return }
			destination.studio = studio
		}
	}
}

// MARK: - KCollectionViewDataSource
extension StudiosListCollectionViewController {
	override func configureDataSource() {
		let studioCellRegistration = self.getConfiguredStudioCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { collectionView, indexPath, itemKind in
			return collectionView.dequeueConfiguredReusableCell(using: studioCellRegistration, for: indexPath, item: itemKind)
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		self.snapshot.appendSections([.main])

		let items: [ItemKind] = self.studioIdentities.map { .studioIdentity($0) }
		self.snapshot.appendItems(items, toSection: .main)

		self.dataSource.apply(self.snapshot)
	}

	private func getConfiguredStudioCell() -> UICollectionView.CellRegistration<StudioLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<StudioLockupCollectionViewCell, ItemKind>(cellNib: StudioLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .studioIdentity:
				let studio: Studio? = self.fetchModel(at: indexPath)

				if studio == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ResourceCollection<Studio>.self, StudioIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				cell.configure(using: studio, rank: self.studiosListFetchType == .charts ? indexPath.item + 1 : nil)
			}
		}
	}
}

// MARK: - KCollectionViewDelegateLayout
extension StudiosListCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		let columnCount = Int(width >= 414.0 ? (width / 384.0).rounded() : (width / 284.0).rounded())
		return columnCount > 0 ? columnCount : 1
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] section, layoutEnvironment in
			guard let self = self else { return nil }
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)

			return Layouts.studiosSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
		}
	}
}

// MARK: - UICollectionViewDelegate
extension StudiosListCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let studio = self.cache[indexPath] as? Studio else { return }

		self.show(.studioDetailsSegue, sender: studio)
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		self.paginateIfNeeded(at: indexPath, totalItems: self.studioIdentities.count)
	}

	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let studio = self.cache[indexPath] as? Studio else { return nil }

		let collectionViewCell = collectionView.cellForItem(at: indexPath)
		return studio.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
	}
}
