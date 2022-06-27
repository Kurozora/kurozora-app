//
//  PeopleListCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 03/04/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension PeopleListCollectionViewController {
	override func configureDataSource() {
		let personCellRegistration = UICollectionView.CellRegistration<PersonLockupCollectionViewCell, PersonIdentity>(cellNib: UINib(resource: R.nib.personLockupCollectionViewCell)) { [weak self] personLockupCollectionViewCell, indexPath, personIdentity in
			guard let self = self else { return }
			let person = self.fetchPerson(at: indexPath)
			var dataRequest = self.prefetchingIndexPathOperations[indexPath] ?? personLockupCollectionViewCell.dataRequest

			if dataRequest == nil && person == nil {
				dataRequest = KService.getDetails(forPerson: personIdentity) { result in
					switch result {
					case .success(let people):
						self.people[indexPath] = people.first
						self.setPersonNeedsUpdate(personIdentity)
					case .failure: break
					}
				}
			}

			personLockupCollectionViewCell.dataRequest = dataRequest
			personLockupCollectionViewCell.configure(using: person)
		}

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, PersonIdentity>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, personIdentity: PersonIdentity) -> UICollectionViewCell? in
			return collectionView.dequeueConfiguredReusableCell(using: personCellRegistration, for: indexPath, item: personIdentity)
		}
	}

	override func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, PersonIdentity>()
		snapshot.appendSections([.main])
		snapshot.appendItems(self.personIdentities, toSection: .main)
		self.dataSource.apply(snapshot)
	}

	func fetchPerson(at indexPath: IndexPath) -> Person? {
		guard let person = self.people[indexPath] else { return nil }
		return person
	}

	func setPersonNeedsUpdate(_ personIdentity: PersonIdentity) {
		var snapshot = self.dataSource.snapshot()
		guard snapshot.indexOfItem(personIdentity) != nil else { return }
		snapshot.reconfigureItems([personIdentity])
		self.dataSource.apply(snapshot, animatingDifferences: true)
	}
}
