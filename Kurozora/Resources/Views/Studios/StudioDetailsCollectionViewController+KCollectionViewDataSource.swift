//
//  StudioDetailsCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension StudioDetailsCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [
			ProfileHeaderCollectionViewCell.self,
			BadgeCollectionViewCell.self,
			RatingBadgeCollectionViewCell.self,
			TextViewCollectionViewCell.self,
			RatingCollectionViewCell.self,
			RatingSentimentCollectionViewCell.self,
			RatingBarCollectionViewCell.self,
			ReviewCollectionViewCell.self,
			TapToRateCollectionViewCell.self,
			WriteAReviewCollectionViewCell.self,
			InformationCollectionViewCell.self,
			InformationButtonCollectionViewCell.self
		]
	}

	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}

	override func configureDataSource() {
		let smallCellRegistration = self.getConfiguredSmallCell()
		let gameCellRegistration = self.getConfiguredGameCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }

			switch itemKind {
			case .studio(let studio):
				let profileHeaderCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileHeaderCollectionViewCell.self, for: indexPath)
				profileHeaderCollectionViewCell?.configure(using: studio)
				profileHeaderCollectionViewCell?.mediaViewerDelegate = self
				return profileHeaderCollectionViewCell
			case .badge(let studioDetailBadge):
				let badgeCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: studioDetailBadge.identifierString, for: indexPath) as? BadgeCollectionViewCell
				badgeCollectionViewCell?.configureCell(with: self.studio, studioDetailBadge: studioDetailBadge)
				return badgeCollectionViewCell
			case .about:
				let textViewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: TextViewCollectionViewCell.reuseID, for: indexPath) as? TextViewCollectionViewCell
				textViewCollectionViewCell?.delegate = self
				textViewCollectionViewCell?.textViewCollectionViewCellType = .about
				textViewCollectionViewCell?.textViewContent = self.studio.attributes.about
				return textViewCollectionViewCell
			case .rating(let studioDetailRating):
				let ratingCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: studioDetailRating.identifierString, for: indexPath)

				if let stats = self.studio.attributes.stats {
					switch studioDetailRating {
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
			case .rateAndReview(let studioDetailRateAndReview):
				let rateAndReviewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: studioDetailRateAndReview.identifierString, for: indexPath)

				switch studioDetailRateAndReview {
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
			case .information(let studioDetailInformation):
				let informationCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: studioDetailInformation.identifierString, for: indexPath)

				switch studioDetailInformation {
				case .socials, .websites:
					(informationCollectionViewCell as? InformationButtonCollectionViewCell)?.configure(for: self.studio, using: studioDetailInformation)
				default:
					(informationCollectionViewCell as? InformationCollectionViewCell)?.configure(using: self.studio, for: studioDetailInformation)
				}
				return informationCollectionViewCell
			case .showIdentity, .literatureIdentity:
				return collectionView.dequeueConfiguredReusableCell(using: smallCellRegistration, for: indexPath, item: itemKind)
			case .gameIdentity:
				return collectionView.dequeueConfiguredReusableCell(using: gameCellRegistration, for: indexPath, item: itemKind)
			}
		}

		self.dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			guard let self = self else { return nil }
			let studioDetailSection = self.snapshot.sectionIdentifiers[indexPath.section]
			let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
			titleHeaderCollectionReusableView.delegate = self
			titleHeaderCollectionReusableView.configure(withTitle: studioDetailSection.stringValue, indexPath: indexPath, segueID: studioDetailSection.segueIdentifier)
			return titleHeaderCollectionReusableView
		}
	}

	override func updateDataSource() {
		// Built on a local value so the in-progress snapshot is never visible to `self.snapshot`
		// readers (cell/supplementary providers) until it's fully assembled.
		var newSnapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		SectionLayoutKind.allCases.forEach { [weak self] studioDetailSection in
			guard let self = self else { return }

			switch studioDetailSection {
			case .header:
				newSnapshot.appendSections([studioDetailSection])
				newSnapshot.appendItems([.studio(self.studio)], toSection: studioDetailSection)
			case .badges:
				newSnapshot.appendSections([studioDetailSection])
				let badgeItems: [ItemKind] = self.badges.map { studioDetailBadge in
					.badge(studioDetailBadge)
				}
				newSnapshot.appendItems(badgeItems, toSection: studioDetailSection)
			case .about:
				if let about = self.studio.attributes.about, !about.isEmpty {
					newSnapshot.appendSections([studioDetailSection])
					newSnapshot.appendItems([.about], toSection: studioDetailSection)
				}
			case .rating:
				newSnapshot.appendSections([studioDetailSection])
				let ratingItems: [ItemKind] = StudioDetail.Rating.allCases.map { studioDetailRating in
					.rating(studioDetailRating)
				}
				newSnapshot.appendItems(ratingItems, toSection: studioDetailSection)
			case .rateAndReview:
				newSnapshot.appendSections([studioDetailSection])
				let rateAndReviewItems: [ItemKind] = StudioDetail.RateAndReview.allCases.map { studioDetailRateAndReview in
					.rateAndReview(studioDetailRateAndReview)
				}
				newSnapshot.appendItems(rateAndReviewItems, toSection: studioDetailSection)
			case .reviews:
				if !self.reviews.isEmpty {
					newSnapshot.appendSections([studioDetailSection])
					let reviewItems: [ItemKind] = self.reviews.map { review in
						.review(review)
					}
					newSnapshot.appendItems(reviewItems, toSection: studioDetailSection)
				}
			case .information:
				newSnapshot.appendSections([studioDetailSection])
				let informationItems: [ItemKind] = StudioDetail.Information.allCases.map { studioDetailInformation in
					.information(studioDetailInformation)
				}
				newSnapshot.appendItems(informationItems, toSection: studioDetailSection)
			case .shows:
				if !self.showIdentities.isEmpty {
					newSnapshot.appendSections([studioDetailSection])
					let showIdentityItems: [ItemKind] = self.showIdentities.map { showIdentity in
						.showIdentity(showIdentity)
					}
					newSnapshot.appendItems(showIdentityItems, toSection: studioDetailSection)
				}
			case .literatures:
				if !self.literatureIdentities.isEmpty {
					newSnapshot.appendSections([studioDetailSection])
					let literatureIdentityItems: [ItemKind] = self.literatureIdentities.map { literatureIdentity in
						.literatureIdentity(literatureIdentity)
					}
					newSnapshot.appendItems(literatureIdentityItems, toSection: studioDetailSection)
				}
			case .games:
				if !self.gameIdentities.isEmpty {
					newSnapshot.appendSections([studioDetailSection])
					let gameIdentityItems: [ItemKind] = self.gameIdentities.map { gameIdentity in
						.gameIdentity(gameIdentity)
					}
					newSnapshot.appendItems(gameIdentityItems, toSection: studioDetailSection)
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
