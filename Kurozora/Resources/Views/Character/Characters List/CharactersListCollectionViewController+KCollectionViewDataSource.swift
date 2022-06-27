//
//  CharactersListCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 03/04/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit

extension CharactersListCollectionViewController {
	override func configureDataSource() {
		let characterCellRegistration = UICollectionView.CellRegistration<CharacterLockupCollectionViewCell, CharacterIdentity>(cellNib: UINib(resource: R.nib.characterLockupCollectionViewCell)) { [weak self] characterLockupCollectionViewCell, indexPath, characterIdentity in
			guard let self = self else { return }
			let character = self.fetchCharacter(at: indexPath)
			var dataRequest = self.prefetchingIndexPathOperations[indexPath] ?? characterLockupCollectionViewCell.dataRequest

			if dataRequest == nil && character == nil {
				dataRequest = KService.getDetails(forCharacter: characterIdentity) { result in
					switch result {
					case .success(let characters):
						self.characters[indexPath] = characters.first
						self.setCharacterNeedsUpdate(characterIdentity)
					case .failure: break
					}
				}
			}

			characterLockupCollectionViewCell.dataRequest = dataRequest
			characterLockupCollectionViewCell.configure(using: character)
		}

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, CharacterIdentity>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, characterIdentity: CharacterIdentity) -> UICollectionViewCell? in
			return collectionView.dequeueConfiguredReusableCell(using: characterCellRegistration, for: indexPath, item: characterIdentity)
		}
	}

	override func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, CharacterIdentity>()
		snapshot.appendSections([.main])
		snapshot.appendItems(self.characterIdentities, toSection: .main)
		self.dataSource.apply(snapshot)
	}

	func fetchCharacter(at indexPath: IndexPath) -> Character? {
		guard let character = self.characters[indexPath] else { return nil }
		return character
	}

	func setCharacterNeedsUpdate(_ characterIdentity: CharacterIdentity) {
		var snapshot = self.dataSource.snapshot()
		guard snapshot.indexOfItem(characterIdentity) != nil else { return }
		snapshot.reconfigureItems([characterIdentity])
		self.dataSource.apply(snapshot, animatingDifferences: true)
	}
}
