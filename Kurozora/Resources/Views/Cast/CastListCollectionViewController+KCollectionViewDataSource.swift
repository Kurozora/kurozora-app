//
//  CastListCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension CastListCollectionViewController {
	override func configureDataSource() {
		let castCellRegistration = self.getCastCellRegistration()
		let characterCellRegistration = self.getCharacterCellRegistration()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, CastIdentity>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, castIdentity: CastIdentity) -> UICollectionViewCell? in
			guard let self = self else { return nil }

			switch self.castKind {
			case .show, .game:
				return collectionView.dequeueConfiguredReusableCell(using: castCellRegistration, for: indexPath, item: castIdentity)
			case .literature:
				return collectionView.dequeueConfiguredReusableCell(using: characterCellRegistration, for: indexPath, item: castIdentity)
			}
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

extension CastListCollectionViewController {
	func getCastCellRegistration() -> UICollectionView.CellRegistration<CastCollectionViewCell, CastIdentity> {
		return UICollectionView.CellRegistration<CastCollectionViewCell, CastIdentity>(cellNib: UINib(resource: R.nib.castCollectionViewCell)) { [weak self] castCollectionViewCell, indexPath, castIdentity in
			guard let self = self else { return }
			let cast = self.fetchCast(at: indexPath)

			if cast == nil {
				switch self.castKind {
				case .show:
					Task {
						do {
							let castResponse = try await KService.getDetails(forShowCast: castIdentity).value
							self.cast[indexPath] = castResponse.data.first
							self.setCastNeedsUpdate(castIdentity)
						} catch {
							print(error.localizedDescription)
						}
					}
				case .game:
					Task {
						do {
							let castResponse = try await KService.getDetails(forGameCast: castIdentity).value
							self.cast[indexPath] = castResponse.data.first
							self.setCastNeedsUpdate(castIdentity)
						} catch {
							print(error.localizedDescription)
						}
					}
				case .literature: break
				}
			}

			castCollectionViewCell.delegate = self
			castCollectionViewCell.configure(using: cast)
		}
	}

	func getCharacterCellRegistration() -> UICollectionView.CellRegistration<CharacterLockupCollectionViewCell, CastIdentity> {
		return UICollectionView.CellRegistration<CharacterLockupCollectionViewCell, CastIdentity>(cellNib: UINib(resource: R.nib.characterLockupCollectionViewCell)) { [weak self] characterLockupCollctionViewcell, indexPath, castIdentity in
			guard let self = self else { return }
			let cast = self.fetchCast(at: indexPath)

			if cast == nil {
				Task {
					do {
						let castResponse = try await KService.getDetails(forLiteratureCast: castIdentity).value
						self.cast[indexPath] = castResponse.data.first
						self.setCastNeedsUpdate(castIdentity)
					} catch {
						print(error.localizedDescription)
					}
				}
			}

			characterLockupCollctionViewcell.configure(using: cast?.relationships.characters.data.first, role: cast?.attributes.role)
		}
	}
}
