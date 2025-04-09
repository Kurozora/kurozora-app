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
			RatingCollectionViewCell.self,
			RatingSentimentCollectionViewCell.self,
			RatingBarCollectionViewCell.self,
			ReviewCollectionViewCell.self,
			TapToRateCollectionViewCell.self,
			WriteAReviewCollectionViewCell.self,
			InformationCollectionViewCell.self
		]
	}

	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}

	override func configureDataSource() {
		let smallCellRegistration = self.getConfiguredSmallCell()
		let gameCellRegistration = self.getConfiguredGameCell()
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
			case .rating:
				let characterDetailRating = CharacterDetail.Rating(rawValue: indexPath.item) ?? .average
				let ratingCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: characterDetailRating.identifierString, for: indexPath)

				switch itemKind {
				case .character(let character, _):
					if let stats = character.attributes.stats {
						switch characterDetailRating {
						case .average:
							(ratingCollectionViewCell as? RatingCollectionViewCell)?.configure(using: stats)
						case .sentiment:
							(ratingCollectionViewCell as? RatingSentimentCollectionViewCell)?.configure(using: stats)
						case .bar:
							(ratingCollectionViewCell as? RatingBarCollectionViewCell)?.configure(using: stats)
						}
					}
				default: break
				}
				return ratingCollectionViewCell
			case .rateAndReview:
				let characterDetailRateAndReview = CharacterDetail.RateAndReview(rawValue: indexPath.item) ?? .tapToRate
				let rateAndReviewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: characterDetailRateAndReview.identifierString, for: indexPath)

				switch characterDetailRateAndReview {
				case .tapToRate:
					switch itemKind {
					case .character(let character, _):
						(rateAndReviewCollectionViewCell as? TapToRateCollectionViewCell)?.delegate = self
						(rateAndReviewCollectionViewCell as? TapToRateCollectionViewCell)?.configure(using: character.attributes.givenRating)
					default: break
					}
				case .writeAReview:
					(rateAndReviewCollectionViewCell as? WriteAReviewCollectionViewCell)?.delegate = self
				}
				return rateAndReviewCollectionViewCell
			case .reviews:
				let reviewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.reviewCollectionViewCell, for: indexPath)
				switch itemKind {
				case .review(let review, _):
					reviewCollectionViewCell?.delegate = self
					reviewCollectionViewCell?.configureCell(using: review)
				default: break
				}
				return reviewCollectionViewCell
			case .information:
				let informationCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.informationCollectionViewCell, for: indexPath)
				switch itemKind {
				case .character(let character, _):
					informationCollectionViewCell?.configure(using: character, for: CharacterDetail.Information(rawValue: indexPath.item) ?? .debut)
				default: break
				}
				return informationCollectionViewCell
			case .people:
				return collectionView.dequeueConfiguredReusableCell(using: personCellRegistration, for: indexPath, item: itemKind)
			case .shows:
				return collectionView.dequeueConfiguredReusableCell(using: smallCellRegistration, for: indexPath, item: itemKind)
			case .literatures:
				return collectionView.dequeueConfiguredReusableCell(using: smallCellRegistration, for: indexPath, item: itemKind)
			case .games:
				return collectionView.dequeueConfiguredReusableCell(using: gameCellRegistration, for: indexPath, item: itemKind)
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
			case .rating:
				self.snapshot.appendSections([characterDetailSection])
				CharacterDetail.Rating.allCases.forEach { _ in
					self.snapshot.appendItems([.character(self.character)], toSection: characterDetailSection)
				}
			case .rateAndReview:
				self.snapshot.appendSections([characterDetailSection])
				CharacterDetail.RateAndReview.allCases.forEach { _ in
					self.snapshot.appendItems([.character(self.character)], toSection: characterDetailSection)
				}
			case .reviews:
				if !self.reviews.isEmpty {
					self.snapshot.appendSections([characterDetailSection])
					let reviewItems: [ItemKind] = self.reviews.map { review in
						return .review(review)
					}
					self.snapshot.appendItems(reviewItems, toSection: characterDetailSection)
				}
			case .information:
				self.snapshot.appendSections([characterDetailSection])
				CharacterDetail.Information.allCases.forEach { _ in
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
			case .literatures:
				if !self.literatureIdentities.isEmpty {
					self.snapshot.appendSections([characterDetailSection])
					let literatureIdentityItems: [ItemKind] = self.literatureIdentities.map { literatureIdentity in
						return .literatureIdentity(literatureIdentity)
					}
					self.snapshot.appendItems(literatureIdentityItems, toSection: characterDetailSection)
				}
			case .games:
				if !self.gameIdentities.isEmpty {
					self.snapshot.appendSections([characterDetailSection])
					let gameIdentityItems: [ItemKind] = self.gameIdentities.map { gameIdentity in
						return .gameIdentity(gameIdentity)
					}
					self.snapshot.appendItems(gameIdentityItems, toSection: characterDetailSection)
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

			switch itemKind {
			case .showIdentity(let showIdentity, _):
				let show = self.fetchShow(at: indexPath)

				if show == nil {
					Task {
						do {
							let showResponse = try await KService.getDetails(forShow: showIdentity).value

							self.shows[indexPath] = showResponse.data.first
							self.setItemKindNeedsUpdate(itemKind)
						} catch {
							print(error.localizedDescription)
						}
					}
				}

				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.configure(using: show)
			case .literatureIdentity(let literatureIdentity, _):
				let literature = self.fetchLiterature(at: indexPath)

				if literature == nil {
					Task {
						do {
							let literatureResponse = try await KService.getDetails(forLiterature: literatureIdentity).value

							self.literatures[indexPath] = literatureResponse.data.first
							self.setItemKindNeedsUpdate(itemKind)
						} catch {
							print(error.localizedDescription)
						}
					}
				}

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

				if game == nil {
					Task {
						do {
							let gameResponse = try await KService.getDetails(forGame: gameIdentity).value

							self.games[indexPath] = gameResponse.data.first
							self.setItemKindNeedsUpdate(itemKind)
						} catch {
							print(error.localizedDescription)
						}
					}
				}

				gameLockupCollectionViewCell.delegate = self
				gameLockupCollectionViewCell.configure(using: game)
			default: break
			}
		}
	}

	func getConfiguredPersonCell() -> UICollectionView.CellRegistration<PersonLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<PersonLockupCollectionViewCell, ItemKind>(cellNib: UINib(resource: R.nib.personLockupCollectionViewCell)) { [weak self] personLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }
			let person = self.fetchPerson(at: indexPath)

			switch itemKind {
			case .personIdentity(let personIdentity, _):
				if person == nil {
					Task {
						do {
							let personResponse = try await KService.getDetails(forPerson: personIdentity).value

							self.people[indexPath] = personResponse.data.first
							self.setItemKindNeedsUpdate(itemKind)
						} catch {
							print(error.localizedDescription)
						}
					}
				}

				personLockupCollectionViewCell.configure(using: person)
			default: break
			}
		}
	}
}
