//
//  StudiosListCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/06/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension StudiosListCollectionViewController {
	override func configureDataSource() {
		let studioCellRegistration = UICollectionView.CellRegistration<StudioLockupCollectionViewCell, StudioIdentity>(cellNib: UINib(resource: R.nib.studioLockupCollectionViewCell)) { [weak self] studioLockupCollectionViewCell, indexPath, studioIdentity in
			guard let self = self else { return }
			let studio = self.fetchStudio(at: indexPath)

			if studio == nil {
				Task {
					do {
						let studioResponse = try await KService.getDetails(forStudio: studioIdentity).value
						self.studios[indexPath] = studioResponse.data.first
						self.setStudioNeedsUpdate(studioIdentity)
					} catch {
						print(error.localizedDescription)
					}
				}
			}

			studioLockupCollectionViewCell.configure(using: studio)
		}

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, StudioIdentity>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, studioIdentity: StudioIdentity) -> UICollectionViewCell? in
			return collectionView.dequeueConfiguredReusableCell(using: studioCellRegistration, for: indexPath, item: studioIdentity)
		}
	}

	override func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, StudioIdentity>()
		snapshot.appendSections([.main])
		snapshot.appendItems(self.studioIdentities, toSection: .main)
		self.dataSource.apply(snapshot)
	}

	func fetchStudio(at indexPath: IndexPath) -> Studio? {
		guard let studio = self.studios[indexPath] else { return nil }
		return studio
	}

	func setStudioNeedsUpdate(_ studioIdentity: StudioIdentity) {
		var snapshot = self.dataSource.snapshot()
		guard snapshot.indexOfItem(studioIdentity) != nil else { return }
		snapshot.reconfigureItems([studioIdentity])
		self.dataSource.apply(snapshot, animatingDifferences: true)
	}
}
