//
//  LiteraturesListCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/02/2023.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

// MARK: - KCollectionViewDataSource
extension LiteraturesListCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [
			SmallLockupCollectionViewCell.self,
			UpcomingLockupCollectionViewCell.self
		]
	}

	override func configureDataSource() {
		let smallLockupCellRegistration = UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.smallLockupCollectionViewCell)) { [weak self] smallLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .literatureIdentity(let literatureIdentity):
				let literature = self.fetchLiterature(at: indexPath)
				var literatureDataRequest = self.prefetchingIndexPathOperations[indexPath] ?? smallLockupCollectionViewCell.dataRequest

				if literatureDataRequest == nil && literature == nil {
					literatureDataRequest = KService.getDetails(forLiterature: literatureIdentity) { result in
						switch result {
						case .success(let literatures):
							self.literatures[indexPath] = literatures.first
							self.setItemKindNeedsUpdate(itemKind)
						case .failure: break
						}
					}
				}

				smallLockupCollectionViewCell.dataRequest = literatureDataRequest
				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.configure(using: literature)
			case .relatedLiterature(let relatedLiterature):
				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.configure(using: relatedLiterature)
			}
		}

		let upcomingLockupCellRegistration = UICollectionView.CellRegistration<UpcomingLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.upcomingLockupCollectionViewCell)) { [weak self] upcomingLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .literatureIdentity(let literatureIdentity):
				let literature = self.fetchLiterature(at: indexPath)
				var literatureDataRequest = self.prefetchingIndexPathOperations[indexPath] ?? upcomingLockupCollectionViewCell.dataRequest

				if literatureDataRequest == nil && literature == nil {
					literatureDataRequest = KService.getDetails(forLiterature: literatureIdentity) { result in
						switch result {
						case .success(let literatures):
							self.literatures[indexPath] = literatures.first
							self.setItemKindNeedsUpdate(itemKind)
						case .failure: break
						}
					}
				}

				upcomingLockupCollectionViewCell.dataRequest = literatureDataRequest
				upcomingLockupCollectionViewCell.delegate = self
				upcomingLockupCollectionViewCell.configure(using: literature)
			default: break
			}
		}

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
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
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		snapshot.appendSections([.main])

		// Append items
		switch self.literaturesListFetchType {
		case .relatedLiterature, .show:
			let relatedLiteratureItems: [ItemKind] = self.relatedLiteratures.map { relatedLiterature in
				return .relatedLiterature(relatedLiterature)
			}
			snapshot.appendItems(relatedLiteratureItems, toSection: .main)
		default:
			let literatureItems: [ItemKind] = self.literatureIdentities.map { literatureIdentity in
				return .literatureIdentity(literatureIdentity)
			}
			snapshot.appendItems(literatureItems, toSection: .main)
		}

		self.dataSource.apply(snapshot)
	}

	func fetchLiterature(at indexPath: IndexPath) -> Literature? {
		guard let literature = self.literatures[indexPath] else { return nil }
		return literature
	}

	func setItemKindNeedsUpdate(_ itemKind: ItemKind) {
		var snapshot = self.dataSource.snapshot()
		guard snapshot.indexOfItem(itemKind) != nil else { return }
		snapshot.reconfigureItems([itemKind])
		self.dataSource.apply(snapshot, animatingDifferences: true)
	}
}
