//
//  PersonDetailsCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension PersonDetailsCollectionViewController {
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
		let gameCellRegistration = self.getConfiguredGameCell()
		let characterCellRegistration = self.getConfiguredCharacterCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }
			guard let personDetailSection = self.snapshot.sectionIdentifier(containingItem: itemKind) else { return nil }

			switch personDetailSection {
			case .header:
				let personHeaderCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.personHeaderCollectionViewCell, for: indexPath)
				switch itemKind {
				case .person(let person, _):
					personHeaderCollectionViewCell?.person = person
				default: break
				}
				return personHeaderCollectionViewCell
			case .about:
				let textViewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.textViewCollectionViewCell, for: indexPath)
				textViewCollectionViewCell?.delegate = self
				textViewCollectionViewCell?.textViewCollectionViewCellType = .about
				switch itemKind {
				case .person(let person, _):
					textViewCollectionViewCell?.textViewContent = person.attributes.about
				default: break
				}
				return textViewCollectionViewCell
			case .information:
				let informationCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.informationCollectionViewCell, for: indexPath)
				switch itemKind {
				case .person(let person, _):
					informationCollectionViewCell?.configure(using: person, for: PersonInformation(rawValue: indexPath.item) ?? .aliases)
				default: break
				}
				return informationCollectionViewCell
			case .characters:
				return collectionView.dequeueConfiguredReusableCell(using: characterCellRegistration, for: indexPath, item: itemKind)
			case .shows, .literatures:
				return collectionView.dequeueConfiguredReusableCell(using: smallCellRegistration, for: indexPath, item: itemKind)
			case .games:
				return collectionView.dequeueConfiguredReusableCell(using: gameCellRegistration, for: indexPath, item: itemKind)
			}
		}

		self.dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			guard let self = self else { return nil }
			let personDetailSection = self.snapshot.sectionIdentifiers[indexPath.section]
			let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
			titleHeaderCollectionReusableView.delegate = self
			titleHeaderCollectionReusableView.configure(withTitle: personDetailSection.stringValue, indexPath: indexPath, segueID: personDetailSection.segueIdentifier)
			return titleHeaderCollectionReusableView
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		SectionLayoutKind.allCases.forEach { personDetailSection in
			switch personDetailSection {
			case .header:
				self.snapshot.appendSections([personDetailSection])
				self.snapshot.appendItems([.person(self.person)], toSection: personDetailSection)
			case .about:
				if let about = self.person.attributes.about, !about.isEmpty {
					self.snapshot.appendSections([personDetailSection])
					self.snapshot.appendItems([.person(self.person)], toSection: personDetailSection)
				}
			case .information:
				self.snapshot.appendSections([personDetailSection])
				PersonInformation.allCases.forEach { _ in
					self.snapshot.appendItems([.person(self.person)], toSection: personDetailSection)
				}
			case .characters:
				if !self.characterIdentities.isEmpty {
					self.snapshot.appendSections([personDetailSection])
					let characterIdentityItems: [ItemKind] = self.characterIdentities.map { characterIdentity in
						return .characterIdentity(characterIdentity)
					}
					self.snapshot.appendItems(characterIdentityItems, toSection: personDetailSection)
				}
			case .shows:
				if !self.showIdentities.isEmpty {
					self.snapshot.appendSections([personDetailSection])
					let showIdentityItems: [ItemKind] = self.showIdentities.map { showIdentity in
						return .showIdentity(showIdentity)
					}
					self.snapshot.appendItems(showIdentityItems, toSection: personDetailSection)
				}
			case .literatures:
				if !self.literatureIdentities.isEmpty {
					self.snapshot.appendSections([personDetailSection])
					let literatureIdentityItems: [ItemKind] = self.literatureIdentities.map { literatureIdentity in
						return .literatureIdentity(literatureIdentity)
					}
					self.snapshot.appendItems(literatureIdentityItems, toSection: personDetailSection)
				}
			case .games:
				if !self.gameIdentities.isEmpty {
					self.snapshot.appendSections([personDetailSection])
					let gameIdentityItems: [ItemKind] = self.gameIdentities.map { gameIdentity in
						return .gameIdentity(gameIdentity)
					}
					self.snapshot.appendItems(gameIdentityItems, toSection: personDetailSection)
				}
			}
		}

		self.dataSource.apply(self.snapshot)
	}

	func fetchShow(at indexPath: IndexPath) -> Show? {
		guard let show = self.shows[indexPath] else { return nil }
		return show
	}

	func fetchLiterature(at indexPath: IndexPath) -> Literature? {
		guard let literature = self.literatures[indexPath] else { return nil }
		return literature
	}

	func fetchGame(at indexPath: IndexPath) -> Game? {
		guard let game = self.games[indexPath] else { return nil }
		return game
	}

	func fetchCharacter(at indexPath: IndexPath) -> Character? {
		guard let character = self.characters[indexPath] else { return nil }
		return character
	}

	func setItemKindNeedsUpdate(_ itemKind: ItemKind) {
		var snapshot = self.dataSource.snapshot()
		guard snapshot.indexOfItem(itemKind) != nil else { return }
		snapshot.reconfigureItems([itemKind])
		self.dataSource.apply(snapshot, animatingDifferences: true)
	}
}

extension PersonDetailsCollectionViewController {
	func getConfiguredSmallCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.smallLockupCollectionViewCell)) { [weak self] smallLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .showIdentity(let showIdentity, _):
				let show = self.fetchShow(at: indexPath)
				var dataRequest = self.prefetchingIndexPathOperations[indexPath] ?? smallLockupCollectionViewCell.dataRequest

				if dataRequest == nil && show == nil {
					dataRequest = KService.getDetails(forShow: showIdentity) { result in
						switch result {
						case .success(let shows):
							self.shows[indexPath] = shows.first
							self.setItemKindNeedsUpdate(itemKind)
						case .failure: break
						}
					}
				}

				smallLockupCollectionViewCell.dataRequest = dataRequest
				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.configure(using: show)
			case .literatureIdentity(let literatureIdentity, _):
				let literature = self.fetchLiterature(at: indexPath)
				var dataRequest = self.prefetchingIndexPathOperations[indexPath] ?? smallLockupCollectionViewCell.dataRequest

				if dataRequest == nil && literature == nil {
					dataRequest = KService.getDetails(forLiterature: literatureIdentity) { result in
						switch result {
						case .success(let literatures):
							self.literatures[indexPath] = literatures.first
							self.setItemKindNeedsUpdate(itemKind)
						case .failure: break
						}
					}
				}

				smallLockupCollectionViewCell.dataRequest = dataRequest
				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.configure(using: literature)
			default: break
			}
		}
	}

	func getConfiguredGameCell() -> UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.gameLockupCollectionViewCell)) { [weak self] gameLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .gameIdentity(let gameIdentity, _):
				let game = self.fetchGame(at: indexPath)
				var dataRequest = self.prefetchingIndexPathOperations[indexPath] ?? gameLockupCollectionViewCell.dataRequest

				if dataRequest == nil && game == nil {
					dataRequest = KService.getDetails(forGame: gameIdentity) { result in
						switch result {
						case .success(let games):
							self.games[indexPath] = games.first
							self.setItemKindNeedsUpdate(itemKind)
						case .failure: break
						}
					}
				}

				gameLockupCollectionViewCell.dataRequest = dataRequest
				gameLockupCollectionViewCell.delegate = self
				gameLockupCollectionViewCell.configure(using: game)
			default: break
			}
		}
	}

	func getConfiguredCharacterCell() -> UICollectionView.CellRegistration<CharacterLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<CharacterLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.characterLockupCollectionViewCell)) { [weak self] characterLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }
			let character = self.fetchCharacter(at: indexPath)
			var dataRequest = self.prefetchingIndexPathOperations[indexPath] ?? characterLockupCollectionViewCell.dataRequest

			if dataRequest == nil && character == nil {
				switch itemKind {
				case .characterIdentity(let characterIdentity, _):
					dataRequest = KService.getDetails(forCharacter: characterIdentity) { result in
						switch result {
						case .success(let characters):
							self.characters[indexPath] = characters.first
							self.setItemKindNeedsUpdate(itemKind)
						case .failure: break
						}
					}
				default: break
				}
			}

			characterLockupCollectionViewCell.dataRequest = dataRequest
			characterLockupCollectionViewCell.configure(using: character)
		}
	}
}
