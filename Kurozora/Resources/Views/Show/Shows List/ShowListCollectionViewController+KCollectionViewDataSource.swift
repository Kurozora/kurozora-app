//
//  ShowListCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/06/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

// MARK: - KCollectionViewDataSource
extension ShowsListCollectionViewController {
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
			case .showIdentity(let showIdentity):
				let show = self.fetchShow(at: indexPath)
				var showDataRequest = self.prefetchingIndexPathOperations[indexPath] ?? smallLockupCollectionViewCell.dataRequest

				if showDataRequest == nil && show == nil {
					showDataRequest = KService.getDetails(forShow: showIdentity) { result in
						switch result {
						case .success(let shows):
							self.shows[indexPath] = shows.first
							self.setItemKindNeedsUpdate(itemKind)
						case .failure: break
						}
					}
				}

				smallLockupCollectionViewCell.dataRequest = showDataRequest
				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.configure(using: show)
			case .relatedShow(let relatedShow):
				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.configure(using: relatedShow)
			}
		}

		let upcomingLockupCellRegistration = UICollectionView.CellRegistration<UpcomingLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.upcomingLockupCollectionViewCell)) { [weak self] upcomingLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .showIdentity(let showIdentity):
				let show = self.fetchShow(at: indexPath)
				var showDataRequest = self.prefetchingIndexPathOperations[indexPath] ?? upcomingLockupCollectionViewCell.dataRequest

				if showDataRequest == nil && show == nil {
					showDataRequest = KService.getDetails(forShow: showIdentity) { result in
						switch result {
						case .success(let shows):
							self.shows[indexPath] = shows.first
							self.setItemKindNeedsUpdate(itemKind)
						case .failure: break
						}
					}
				}

				upcomingLockupCollectionViewCell.dataRequest = showDataRequest
				upcomingLockupCollectionViewCell.delegate = self
				upcomingLockupCollectionViewCell.configure(using: show)
			default: break
			}
		}

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }

			switch self.showsListFetchType {
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
		switch self.showsListFetchType {
		case .relatedShow, .literature, .game:
			let relatedShowItems: [ItemKind] = self.relatedShows.map { relatedShow in
				return .relatedShow(relatedShow)
			}
			snapshot.appendItems(relatedShowItems, toSection: .main)
		default:
			let showItems: [ItemKind] = self.showIdentities.map { showIdentity in
				return .showIdentity(showIdentity)
			}
			snapshot.appendItems(showItems, toSection: .main)
		}

		self.dataSource.apply(snapshot)
	}

	func fetchShow(at indexPath: IndexPath) -> Show? {
		guard let show = self.shows[indexPath] else { return nil }
		return show
	}

	func setItemKindNeedsUpdate(_ itemKind: ItemKind) {
		var snapshot = self.dataSource.snapshot()
		guard snapshot.indexOfItem(itemKind) != nil else { return }
		snapshot.reconfigureItems([itemKind])
		self.dataSource.apply(snapshot, animatingDifferences: true)
	}
}
