//
//  UsersListCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/06/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension UsersListCollectionViewController {
	override func configureDataSource() {
		let userCellRegistration = UICollectionView.CellRegistration<UserLockupCollectionViewCell, UserIdentity>(cellNib: UINib(resource: R.nib.userLockupCollectionViewCell)) { [weak self] userLockupCollectionViewCell, indexPath, userIdentity in
			guard let self = self else { return }
			let user = self.fetchUser(at: indexPath)
			var dataRequest = self.prefetchingIndexPathOperations[indexPath] ?? userLockupCollectionViewCell.dataRequest

			if dataRequest == nil && user == nil {
				dataRequest = KService.getDetails(forUser: userIdentity) { result in
					switch result {
					case .success(let users):
						self.users[indexPath] = users.first
						self.setUserNeedsUpdate(userIdentity)
					case .failure: break
					}
				}
			}

			userLockupCollectionViewCell.delegate = self
			userLockupCollectionViewCell.dataRequest = dataRequest
			userLockupCollectionViewCell.configure(using: user)
		}

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, UserIdentity>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, userIdentity: UserIdentity) -> UICollectionViewCell? in
			return collectionView.dequeueConfiguredReusableCell(using: userCellRegistration, for: indexPath, item: userIdentity)
		}
	}

	override func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, UserIdentity>()
		snapshot.appendSections([.main])
		snapshot.appendItems(self.userIdentities, toSection: .main)
		self.dataSource.apply(snapshot)
	}

	func fetchUser(at indexPath: IndexPath) -> User? {
		guard let user = self.users[indexPath] else { return nil }
		return user
	}

	func setUserNeedsUpdate(_ userIdentity: UserIdentity) {
		var snapshot = self.dataSource.snapshot()
		guard snapshot.indexOfItem(userIdentity) != nil else { return }
		snapshot.reconfigureItems([userIdentity])
		self.dataSource.apply(snapshot, animatingDifferences: true)
	}
}
