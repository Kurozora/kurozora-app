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
			ProfileHeaderCollectionViewCell.self,
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

			switch itemKind {
			case .character(let character):
				let profileHeaderCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileHeaderCollectionViewCell.self, for: indexPath)
				profileHeaderCollectionViewCell?.configure(using: character)
				profileHeaderCollectionViewCell?.mediaViewerDelegate = self
				return profileHeaderCollectionViewCell
			case .about:
				let textViewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: TextViewCollectionViewCell.self, for: indexPath)
				textViewCollectionViewCell?.delegate = self
				textViewCollectionViewCell?.textViewCollectionViewCellType = .about
				textViewCollectionViewCell?.textViewContent = self.character.attributes.about
				return textViewCollectionViewCell
			case .rating(let characterDetailRating):
				let ratingCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: characterDetailRating.identifierString, for: indexPath)

				if let stats = self.character.attributes.stats {
					switch characterDetailRating {
					case .average:
						(ratingCollectionViewCell as? RatingCollectionViewCell)?.configure(using: stats)
					case .sentiment:
						(ratingCollectionViewCell as? RatingSentimentCollectionViewCell)?.configure(using: stats)
					case .favoriteShare:
						(ratingCollectionViewCell as? RatingSentimentCollectionViewCell)?.configureFavoriteShare(using: stats)
					case .bar:
						(ratingCollectionViewCell as? RatingBarCollectionViewCell)?.configure(using: stats)
					}
				}
				return ratingCollectionViewCell
			case .rateAndReview(let characterDetailRateAndReview):
				let rateAndReviewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: characterDetailRateAndReview.identifierString, for: indexPath)

				switch characterDetailRateAndReview {
				case .tapToRate:
					(rateAndReviewCollectionViewCell as? TapToRateCollectionViewCell)?.delegate = self
					(rateAndReviewCollectionViewCell as? TapToRateCollectionViewCell)?.configure(using: self.libraryAttributes?.rating)
				case .writeAReview:
					(rateAndReviewCollectionViewCell as? WriteAReviewCollectionViewCell)?.delegate = self
				}
				return rateAndReviewCollectionViewCell
			case .review(let review):
				let currentReview = self.reviews.first { $0.id == review.id } ?? review
				let reviewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewCollectionViewCell.self, for: indexPath)
				reviewCollectionViewCell?.delegate = self
				reviewCollectionViewCell?.configureCell(using: currentReview, isElevated: currentReview.attributes.isElevated)
				return reviewCollectionViewCell
			case .information(let characterDetailInformation):
				let informationCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: InformationCollectionViewCell.self, for: indexPath)
				informationCollectionViewCell?.configure(using: self.character, for: characterDetailInformation)
				return informationCollectionViewCell
			case .personIdentity:
				return collectionView.dequeueConfiguredReusableCell(using: personCellRegistration, for: indexPath, item: itemKind)
			case .showIdentity, .literatureIdentity:
				return collectionView.dequeueConfiguredReusableCell(using: smallCellRegistration, for: indexPath, item: itemKind)
			case .gameIdentity:
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
		// Built on a local value so the in-progress snapshot is never visible to `self.snapshot`
		// readers (cell/supplementary providers) until it's fully assembled.
		var newSnapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		SectionLayoutKind.allCases.forEach { [weak self] characterDetailSection in
			guard let self = self else { return }

			switch characterDetailSection {
			case .header:
				newSnapshot.appendSections([characterDetailSection])
				newSnapshot.appendItems([.character(self.character)], toSection: characterDetailSection)
			case .about:
				if let about = self.character.attributes.about, !about.isEmpty {
					newSnapshot.appendSections([characterDetailSection])
					newSnapshot.appendItems([.about], toSection: characterDetailSection)
				}
			case .rating:
				newSnapshot.appendSections([characterDetailSection])
				let ratingItems: [ItemKind] = CharacterDetail.Rating.allCases.map { characterDetailRating in
					.rating(characterDetailRating)
				}
				newSnapshot.appendItems(ratingItems, toSection: characterDetailSection)
			case .rateAndReview:
				newSnapshot.appendSections([characterDetailSection])
				let rateAndReviewItems: [ItemKind] = CharacterDetail.RateAndReview.allCases.map { characterDetailRateAndReview in
					.rateAndReview(characterDetailRateAndReview)
				}
				newSnapshot.appendItems(rateAndReviewItems, toSection: characterDetailSection)
			case .reviews:
				if !self.reviews.isEmpty {
					newSnapshot.appendSections([characterDetailSection])
					let reviewItems: [ItemKind] = self.reviews.map { review in
						.review(review)
					}
					newSnapshot.appendItems(reviewItems, toSection: characterDetailSection)
				}
			case .information:
				newSnapshot.appendSections([characterDetailSection])
				let informationItems: [ItemKind] = CharacterDetail.Information.allCases.map { characterDetailInformation in
					.information(characterDetailInformation)
				}
				newSnapshot.appendItems(informationItems, toSection: characterDetailSection)
			case .people:
				if !self.personIdentities.isEmpty {
					newSnapshot.appendSections([characterDetailSection])
					let personIdentityItems: [ItemKind] = self.personIdentities.map { personIdentity in
						.personIdentity(personIdentity)
					}
					newSnapshot.appendItems(personIdentityItems, toSection: characterDetailSection)
				}
			case .shows:
				if !self.showIdentities.isEmpty {
					newSnapshot.appendSections([characterDetailSection])
					let showIdentityItems: [ItemKind] = self.showIdentities.map { showIdentity in
						.showIdentity(showIdentity)
					}
					newSnapshot.appendItems(showIdentityItems, toSection: characterDetailSection)
				}
			case .literatures:
				if !self.literatureIdentities.isEmpty {
					newSnapshot.appendSections([characterDetailSection])
					let literatureIdentityItems: [ItemKind] = self.literatureIdentities.map { literatureIdentity in
						.literatureIdentity(literatureIdentity)
					}
					newSnapshot.appendItems(literatureIdentityItems, toSection: characterDetailSection)
				}
			case .games:
				if !self.gameIdentities.isEmpty {
					newSnapshot.appendSections([characterDetailSection])
					let gameIdentityItems: [ItemKind] = self.gameIdentities.map { gameIdentity in
						.gameIdentity(gameIdentity)
					}
					newSnapshot.appendItems(gameIdentityItems, toSection: characterDetailSection)
				}
			}
		}

		self.snapshot = newSnapshot
		self.dataSource.apply(newSnapshot)
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
