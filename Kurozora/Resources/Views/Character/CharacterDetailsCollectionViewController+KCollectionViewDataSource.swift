//
//  CharacterDetailsCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

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
				let characterHeaderCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: CharacterHeaderCollectionViewCell.self, for: indexPath)
				switch itemKind {
				case .character(let character, _):
					characterHeaderCollectionViewCell?.character = character
				default: break
				}
				return characterHeaderCollectionViewCell
			case .about:
				let textViewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: TextViewCollectionViewCell.self, for: indexPath)
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
				let reviewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewCollectionViewCell.self, for: indexPath)
				switch itemKind {
				case .review(let review, _):
					reviewCollectionViewCell?.delegate = self
					reviewCollectionViewCell?.configureCell(using: review)
				default: break
				}
				return reviewCollectionViewCell
			case .information:
				let informationCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: InformationCollectionViewCell.self, for: indexPath)
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
						.review(review)
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
						.personIdentity(personIdentity)
					}
					self.snapshot.appendItems(characterIdentityItems, toSection: characterDetailSection)
				}
			case .shows:
				if !self.showIdentities.isEmpty {
					self.snapshot.appendSections([characterDetailSection])
					let showIdentityItems: [ItemKind] = self.showIdentities.map { showIdentity in
						.showIdentity(showIdentity)
					}
					self.snapshot.appendItems(showIdentityItems, toSection: characterDetailSection)
				}
			case .literatures:
				if !self.literatureIdentities.isEmpty {
					self.snapshot.appendSections([characterDetailSection])
					let literatureIdentityItems: [ItemKind] = self.literatureIdentities.map { literatureIdentity in
						.literatureIdentity(literatureIdentity)
					}
					self.snapshot.appendItems(literatureIdentityItems, toSection: characterDetailSection)
				}
			case .games:
				if !self.gameIdentities.isEmpty {
					self.snapshot.appendSections([characterDetailSection])
					let gameIdentityItems: [ItemKind] = self.gameIdentities.map { gameIdentity in
						.gameIdentity(gameIdentity)
					}
					self.snapshot.appendItems(gameIdentityItems, toSection: characterDetailSection)
				}
			}
		}

		self.dataSource.apply(self.snapshot)
	}

	func fetchModel<M: KurozoraItem>(at indexPath: IndexPath) -> M? {
		return self.cache[indexPath] as? M
	}

	func setSectionNeedsUpdate(_ section: SectionLayoutKind) {
		var snapshot = self.dataSource.snapshot()
		guard snapshot.indexOfSection(section) != nil else { return }
		let itemsInSection = snapshot.itemIdentifiers(inSection: section)
		snapshot.reconfigureItems(itemsInSection)
		self.dataSource.apply(snapshot, animatingDifferences: true)
	}
}
