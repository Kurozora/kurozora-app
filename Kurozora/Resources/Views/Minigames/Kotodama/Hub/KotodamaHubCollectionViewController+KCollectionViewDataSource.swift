//
//  KotodamaHubCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension KotodamaHubCollectionViewController {
	override func configureDataSource() {
		let dailyCellRegistration = UICollectionView.CellRegistration<KotodamaDailyCardCollectionViewCell, KotodamaDaily> { [weak self] cell, _, daily in
			cell.delegate = self
			cell.configure(using: daily)
		}

		let menuCellRegistration = UICollectionView.CellRegistration<KotodamaMenuCollectionViewCell, KotodamaMode> { cell, _, mode in
			cell.configure(using: mode)
		}

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(
			collectionView: self.collectionView
		) { collectionView, indexPath, itemKind in
			switch itemKind {
			case .daily(let daily):
				return collectionView.dequeueConfiguredReusableCell(
					using: dailyCellRegistration,
					for: indexPath,
					item: daily
				)
			case .mode(let mode):
				return collectionView.dequeueConfiguredReusableCell(
					using: menuCellRegistration,
					for: indexPath,
					item: mode
				)
			}
		}
	}

	override func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		if let daily = self.daily {
			snapshot.appendSections([.daily, .modes])
			snapshot.appendItems([.daily(daily)], toSection: .daily)
			snapshot.appendItems(KotodamaMode.allCases.map { ItemKind.mode($0) }, toSection: .modes)
		}

		self.snapshot = snapshot
		self.dataSource.apply(snapshot) { [weak self] in
			guard let self = self else { return }
			self.toggleEmptyDataView()
		}
	}
}

// MARK: - KotodamaDailyCardCollectionViewCellDelegate
extension KotodamaHubCollectionViewController: KotodamaDailyCardCollectionViewCellDelegate {
	func kotodamaDailyCardCellDidPressAction(_ cell: KotodamaDailyCardCollectionViewCell) {
		self.playDaily()
	}
}

// MARK: - UICollectionViewDelegate
extension KotodamaHubCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)

		guard case .mode(let mode) = self.dataSource.itemIdentifier(for: indexPath) else { return }

		self.open(mode: mode)
	}
}

// MARK: - SectionLayoutKind
extension KotodamaHubCollectionViewController {
	/// The set of available sections.
	enum SectionLayoutKind: Int, CaseIterable {
		/// Today's puzzle.
		case daily

		/// The other Kotodama screens.
		case modes
	}
}

// MARK: - ItemKind
extension KotodamaHubCollectionViewController {
	/// The set of available items.
	enum ItemKind: Hashable {
		/// Today's puzzle.
		case daily(KotodamaDaily)

		/// One of the other Kotodama screens.
		case mode(KotodamaMode)
	}
}
