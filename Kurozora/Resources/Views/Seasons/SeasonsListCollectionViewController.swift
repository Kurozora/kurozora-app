//
//  SeasonsListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// A paginated list of seasons for a given show.
class SeasonsListCollectionViewController: ListCollectionViewController, SectionFetchable {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case episodesListSegue
	}

	/// The section identifier.
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}

	/// An item displayed in the list.
	enum ItemKind: Hashable {
		case seasonIdentity(_: SeasonIdentity)
	}

	// MARK: - Properties
	var showIdentity: ShowIdentity?
	var seasonIdentities: [SeasonIdentity] = []

	// MARK: - SectionFetchable
	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	override var emptyStateImage: UIImage { .Empty.seasons }
	override var emptyStateTitle: String { "No Seasons" }
	override var emptyStateDetail: String { "This show doesn't have seasons yet. Please check back again later." }

	override var hasLoadedInitialData: Bool {
		!self.seasonIdentities.isEmpty
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = L10n.seasons

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshSeasons)
		#endif
	}

	override func fetchItems() async {
		guard !self.isRequestInProgress else { return }
		self.isRequestInProgress = true

		defer {
			self.endFetch()

			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshSeasons)
			#endif
		}

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.refreshingSeasons)
		#endif

		do {
			guard let showIdentity = self.showIdentity else { return }
			let response = try await KService.seasons(for: showIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

			if self.nextPageCursor == nil {
				self.seasonIdentities = []
			}

			self.nextPageCursor = response.nextCursor
			self.seasonIdentities.append(contentsOf: response.data)
			self.seasonIdentities.removeDuplicates()
		} catch {
			print(error.localizedDescription)
		}
	}

	// MARK: - SectionFetchable
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .seasonIdentity(let id): return id as? Element
		}
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .episodesListSegue: return EpisodesListCollectionViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .episodesListSegue:
			guard let destination = destination as? EpisodesListCollectionViewController else { return }
			guard let season = sender as? Season else { return }
			destination.season = season
			destination.episodesListFetchType = .season
		}
	}
}

// MARK: - KCollectionViewDataSource
extension SeasonsListCollectionViewController {
	override func configureDataSource() {
		let posterCellRegistration = self.getConfiguredSeasonCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { collectionView, indexPath, itemKind in
			return collectionView.dequeueConfiguredReusableCell(using: posterCellRegistration, for: indexPath, item: itemKind)
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		self.snapshot.appendSections([.main])

		let items: [ItemKind] = self.seasonIdentities.map { .seasonIdentity($0) }
		self.snapshot.appendItems(items, toSection: .main)

		self.dataSource.apply(self.snapshot)
	}

	private func getConfiguredSeasonCell() -> UICollectionView.CellRegistration<SeasonLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SeasonLockupCollectionViewCell, ItemKind>(cellNib: SeasonLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .seasonIdentity:
				let season: Season? = self.fetchModel(at: indexPath)

				if season == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ResourceCollection<Season>.self, SeasonIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				cell.configure(using: season)
			}
		}
	}
}

// MARK: - KCollectionViewDelegateLayout
extension SeasonsListCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		let columnCount = Int(width >= 414 ? (width / 384).rounded() : (width / 284).rounded())
		return columnCount > 0 ? columnCount : 1
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] section, layoutEnvironment in
			guard let self = self else { return nil }
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)

			return Layouts.seasonsSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
		}
	}
}

// MARK: - UICollectionViewDelegate
extension SeasonsListCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let season = self.cache[indexPath] as? Season else { return }

		self.show(SegueIdentifiers.episodesListSegue, sender: season)
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		self.paginateIfNeeded(at: indexPath, totalItems: self.seasonIdentities.count)
	}

	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard
			let season = self.cache[indexPath] as? Season,
			let collectionViewCell = collectionView.cellForItem(at: indexPath) as? SeasonLockupCollectionViewCell
		else { return nil }

		return season.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell.contentView, barButtonItem: nil)
	}
}
