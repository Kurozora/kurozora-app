//
//  CharacterDetailsCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension CharacterDetailsCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [
			TextViewCollectionViewCell.self,
			InformationCollectionViewCell.self
		]
	}

	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}

	override func configureDataSource() {
		let smallCellRegistration = self.getConfiguredSmallCell()
		let personCellRegistration = self.getConfiguredPersonCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }
			guard let characterDetailSection = self.snapshot.sectionIdentifier(containingItem: itemKind) else { return nil }

			switch characterDetailSection {
			case .header:
				let characterHeaderCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.characterHeaderCollectionViewCell, for: indexPath)
				switch itemKind {
				case .character(let character, _):
					characterHeaderCollectionViewCell?.character = character
				default: break
				}
				return characterHeaderCollectionViewCell
			case .about:
				let textViewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.textViewCollectionViewCell, for: indexPath)
				textViewCollectionViewCell?.delegate = self
				textViewCollectionViewCell?.textViewCollectionViewCellType = .about
				switch itemKind {
				case .character(let character, _):
					textViewCollectionViewCell?.textViewContent = character.attributes.about
				default: break
				}
				return textViewCollectionViewCell
			case .information:
				let informationCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.informationCollectionViewCell, for: indexPath)
				switch itemKind {
				case .character(let character, _):
					informationCollectionViewCell?.configure(using: character, for: CharacterInformation(rawValue: indexPath.item) ?? .debut)
				default: break
				}
				return informationCollectionViewCell
			case .people:
				return collectionView.dequeueConfiguredReusableCell(using: personCellRegistration, for: indexPath, item: itemKind)
			case .shows:
				return collectionView.dequeueConfiguredReusableCell(using: smallCellRegistration, for: indexPath, item: itemKind)
			}
		}

		self.dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			guard let self = self else { return nil }
			let characterDetailSection = self.snapshot.sectionIdentifiers[indexPath.section]
			let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
			titleHeaderCollectionReusableView.delegate = self
			titleHeaderCollectionReusableView.configure(withTitle: characterDetailSection.stringValue, indexPath: indexPath, segueID: characterDetailSection.segueIdentifier)
			return titleHeaderCollectionReusableView
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		SectionLayoutKind.allCases.forEach { [weak self] characterDetailSection in
			guard let self = self else { return }

			switch characterDetailSection {
			case .header:
				self.snapshot.appendSections([characterDetailSection])
				self.snapshot.appendItems([.character(self.character)], toSection: characterDetailSection)
			case .about:
				if let about = self.character.attributes.about, !about.isEmpty {
					self.snapshot.appendSections([characterDetailSection])
					self.snapshot.appendItems([.character(self.character)], toSection: characterDetailSection)
				}
			case .information:
				self.snapshot.appendSections([characterDetailSection])
				CharacterInformation.allCases.forEach { _ in
					self.snapshot.appendItems([.character(self.character)], toSection: characterDetailSection)
				}
			case .people:
				if !self.personIdentities.isEmpty {
					self.snapshot.appendSections([characterDetailSection])
					let characterIdentityItems: [ItemKind] = self.personIdentities.map { personIdentity in
						return .personIdentity(personIdentity)
					}
					self.snapshot.appendItems(characterIdentityItems, toSection: characterDetailSection)
				}
			case .shows:
				if !self.showIdentities.isEmpty {
					self.snapshot.appendSections([characterDetailSection])
					let showIdentityItems: [ItemKind] = self.showIdentities.map { showIdentity in
						return .showIdentity(showIdentity)
					}
					self.snapshot.appendItems(showIdentityItems, toSection: characterDetailSection)
				}
			}
		}

		self.dataSource.apply(self.snapshot)
	}

	func fetchShow(at indexPath: IndexPath) -> Show? {
		guard let show = self.shows[indexPath] else { return nil }
		return show
	}

	func fetchPerson(at indexPath: IndexPath) -> Person? {
		guard let character = self.people[indexPath] else { return nil }
		return character
	}

	func setItemKindNeedsUpdate(_ itemKind: ItemKind) {
		var snapshot = self.dataSource.snapshot()
		guard snapshot.indexOfItem(itemKind) != nil else { return }
		snapshot.reconfigureItems([itemKind])
		self.dataSource.apply(snapshot, animatingDifferences: true)
	}
}

extension CharacterDetailsCollectionViewController {
	func getConfiguredSmallCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.smallLockupCollectionViewCell)) { [weak self] smallLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }
			let show = self.fetchShow(at: indexPath)
			var dataRequest = self.prefetchingIndexPathOperations[indexPath] ?? smallLockupCollectionViewCell.dataRequest

			if dataRequest == nil && show == nil {
				switch itemKind {
				case .showIdentity(let showIdentity, _):
					dataRequest = KService.getDetails(forShow: showIdentity) { result in
						switch result {
						case .success(let shows):
							self.shows[indexPath] = shows.first
							self.setItemKindNeedsUpdate(itemKind)
						case .failure: break
						}
					}
				default: break
				}
			}

			smallLockupCollectionViewCell.dataRequest = dataRequest
			smallLockupCollectionViewCell.delegate = self
			smallLockupCollectionViewCell.configure(using: show)
		}
	}

	func getConfiguredPersonCell() -> UICollectionView.CellRegistration<PersonLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<PersonLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.personLockupCollectionViewCell)) { [weak self] personLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }
			let person = self.fetchPerson(at: indexPath)
			var dataRequest = self.prefetchingIndexPathOperations[indexPath] ?? personLockupCollectionViewCell.dataRequest

			if dataRequest == nil && person == nil {
				switch itemKind {
				case .personIdentity(let personIdentity, _):
					dataRequest = KService.getDetails(forPerson: personIdentity) { result in
						switch result {
						case .success(let persons):
							self.people[indexPath] = persons.first
							self.setItemKindNeedsUpdate(itemKind)
						case .failure: break
						}
					}
				default: break
				}
			}

			personLockupCollectionViewCell.dataRequest = dataRequest
			personLockupCollectionViewCell.configure(using: person)
		}
	}
}