//
//  CastCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension CastCollectionViewController {
	override func configureDataSource() {
		let castCellRegistration = UICollectionView.CellRegistration<CastCollectionViewCell, CastIdentity>(cellNib: UINib(resource: R.nib.castCollectionViewCell)) { [weak self] castCollectionViewCell, indexPath, castIdentity in
			guard let self = self else { return }
			let cast = self.fetchCast(at: indexPath)
			var dataRequest = self.prefetchingIndexPathOperations[indexPath] ?? castCollectionViewCell.dataRequest

			if dataRequest == nil && cast == nil {
				dataRequest = KService.getDetails(forCast: castIdentity) { result in
					switch result {
					case .success(let cast):
						self.cast[indexPath] = cast.first
						self.setCastNeedsUpdate(castIdentity)
					case .failure: break
					}
				}
			}

			castCollectionViewCell.dataRequest = dataRequest
			castCollectionViewCell.delegate = self
			castCollectionViewCell.configure(using: cast)
		}

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, CastIdentity>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, castIdentity: CastIdentity) -> UICollectionViewCell? in
			return collectionView.dequeueConfiguredReusableCell(using: castCellRegistration, for: indexPath, item: castIdentity)
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, CastIdentity>()
		self.snapshot.appendSections([.main])
		self.snapshot.appendItems(self.castIdentities, toSection: .main)
		self.dataSource.apply(self.snapshot)
	}

	func fetchCast(at indexPath: IndexPath) -> Cast? {
		guard let cast = self.cast[indexPath] else { return nil }
		return cast
	}

	func setCastNeedsUpdate(_ castIdentity: CastIdentity) {
		var snapshot = self.dataSource.snapshot()
		snapshot.reconfigureItems([castIdentity])
		self.dataSource.apply(snapshot, animatingDifferences: true)
	}
}
