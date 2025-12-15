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
			guard let studioDetailSection = self.snapshot.sectionIdentifier(containingItem: itemKind) else { return nil }

			switch studioDetailSection {
			case .header:
				let studioHeaderCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: StudioHeaderCollectionViewCell.self, for: indexPath)
				switch itemKind {
				case .studio(let studio, _):
					studioHeaderCollectionViewCell?.configure(using: studio)
				default: break
				}
				return studioHeaderCollectionViewCell
			case .badges:
				let studioDetailBadge = StudioDetail.Badge(rawValue: indexPath.item) ?? .tvRating
				let badgeCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: studioDetailBadge.identifierString, for: indexPath) as? BadgeCollectionViewCell
				switch itemKind {
				case .studio(let studio, _):
					badgeCollectionViewCell?.configureCell(with: studio, studioDetailBadge: studioDetailBadge)
				default: break
				}
				return badgeCollectionViewCell
			case .about:
				let textViewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: TextViewCollectionViewCell.reuseID, for: indexPath) as? TextViewCollectionViewCell
				textViewCollectionViewCell?.delegate = self
				textViewCollectionViewCell?.textViewCollectionViewCellType = .about
				switch itemKind {
				case .studio(let studio, _):
					textViewCollectionViewCell?.textViewContent = studio.attributes.about
				default: break
				}
				return textViewCollectionViewCell
			case .rating:
				let studioDetailRating = StudioDetail.Rating(rawValue: indexPath.item) ?? .average
				let ratingCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: studioDetailRating.identifierString, for: indexPath)

				switch itemKind {
				case .studio(let studio, _):
					if let stats = studio.attributes.stats {
						switch studioDetailRating {
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
				let studioDetailRateAndReview = StudioDetail.RateAndReview(rawValue: indexPath.item) ?? .tapToRate
				let rateAndReviewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: studioDetailRateAndReview.identifierString, for: indexPath)

				switch studioDetailRateAndReview {
				case .tapToRate:
					switch itemKind {
					case .studio(let studio, _):
						(rateAndReviewCollectionViewCell as? TapToRateCollectionViewCell)?.delegate = self
						(rateAndReviewCollectionViewCell as? TapToRateCollectionViewCell)?.configure(using: studio.attributes.library?.rating)
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
				let studioDetailInformation = StudioDetail.Information(rawValue: indexPath.item) ?? .websites
				let informationCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: studioDetailInformation.identifierString, for: indexPath)

				switch itemKind {
				case .studio(let studio, _):
					switch studioDetailInformation {
					case .socials, .websites:
						(informationCollectionViewCell as? InformationButtonCollectionViewCell)?.configure(for: studio, using: studioDetailInformation)
					default:
						(informationCollectionViewCell as? InformationCollectionViewCell)?.configure(using: studio, for: studioDetailInformation)
					}
				default: break
				}
				return informationCollectionViewCell
			case .shows, .literatures:
				return collectionView.dequeueConfiguredReusableCell(using: smallCellRegistration, for: indexPath, item: itemKind)
			case .games:
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
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		SectionLayoutKind.allCases.forEach { [weak self] studioDetailSection in
			guard let self = self else { return }

			switch studioDetailSection {
			case .header:
				self.snapshot.appendSections([studioDetailSection])
				self.snapshot.appendItems([.studio(self.studio)], toSection: studioDetailSection)
			case .badges:
				self.snapshot.appendSections([studioDetailSection])
				StudioDetail.Badge.allCases.forEach { studioDetailBadge in
					switch studioDetailBadge {
//					case .rating:
//						return
					default:
						self.snapshot.appendItems([.studio(self.studio)], toSection: studioDetailSection)
					}
				}
			case .about:
				if let about = self.studio.attributes.about, !about.isEmpty {
					self.snapshot.appendSections([studioDetailSection])
					self.snapshot.appendItems([.studio(self.studio)], toSection: studioDetailSection)
				}
			case .rating:
				self.snapshot.appendSections([studioDetailSection])
				StudioDetail.Rating.allCases.forEach { _ in
					self.snapshot.appendItems([.studio(self.studio)], toSection: studioDetailSection)
				}
			case .rateAndReview:
				self.snapshot.appendSections([studioDetailSection])
				StudioDetail.RateAndReview.allCases.forEach { _ in
					self.snapshot.appendItems([.studio(self.studio)], toSection: studioDetailSection)
				}
			case .reviews:
				if !self.reviews.isEmpty {
					self.snapshot.appendSections([studioDetailSection])
					let reviewItems: [ItemKind] = self.reviews.map { review in
						.review(review)
					}
					self.snapshot.appendItems(reviewItems, toSection: studioDetailSection)
				}
			case .information:
				self.snapshot.appendSections([studioDetailSection])
				StudioDetail.Information.allCases.forEach { _ in
					self.snapshot.appendItems([.studio(self.studio)], toSection: studioDetailSection)
				}
			case .shows:
				if !self.showIdentities.isEmpty {
					self.snapshot.appendSections([studioDetailSection])
					let showIdentityItems: [ItemKind] = self.showIdentities.map { showIdentity in
						.showIdentity(showIdentity)
					}
					self.snapshot.appendItems(showIdentityItems, toSection: studioDetailSection)
				}
			case .literatures:
				if !self.literatureIdentities.isEmpty {
					self.snapshot.appendSections([studioDetailSection])
					let literatureIdentityItems: [ItemKind] = self.literatureIdentities.map { literatureIdentity in
						.literatureIdentity(literatureIdentity)
					}
					self.snapshot.appendItems(literatureIdentityItems, toSection: studioDetailSection)
				}
			case .games:
				if !self.gameIdentities.isEmpty {
					self.snapshot.appendSections([studioDetailSection])
					let gameIdentityItems: [ItemKind] = self.gameIdentities.map { gameIdentity in
						.gameIdentity(gameIdentity)
					}
					self.snapshot.appendItems(gameIdentityItems, toSection: studioDetailSection)
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
