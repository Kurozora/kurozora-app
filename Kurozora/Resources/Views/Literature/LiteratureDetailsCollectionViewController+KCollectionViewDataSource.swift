//
//  LiteratureDetailsCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/02/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension LiteratureDetailsCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [
			LiteratureDetailHeaderCollectionViewCell.self,
			BadgeCollectionViewCell.self,
			RatingBadgeCollectionViewCell.self,
			TextViewCollectionViewCell.self,
			RatingCollectionViewCell.self,
			RatingSentimentCollectionViewCell.self,
			RatingBarCollectionViewCell.self,
			ReviewCollectionViewCell.self,
			EditorialCollectionViewCell.self,
			TapToRateCollectionViewCell.self,
			WriteAReviewCollectionViewCell.self,
			InformationCollectionViewCell.self,
			MusicLockupCollectionViewCell.self,
			SosumiCollectionViewCell.self
		]
	}

	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}

	override func configureDataSource() {
		let castCellConfiguration = self.getConfiguredCastCell()
		let studioLiteratureCellConfiguration = self.getConfiguredStudioLiteratureCell()
		let studioCellConfiguration = self.getConfiguredStudioCell()
		let relatedLiteratureCellConfiguration = self.getConfiguredRelatedLiteratureCell()
		let relatedGameCellConfiguration = self.getConfiguredRelatedGameCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }

			switch itemKind {
			case .literature(let literature):
				let literatureDetailHeaderCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: LiteratureDetailHeaderCollectionViewCell.self, for: indexPath)
				literatureDetailHeaderCollectionViewCell?.delegate = self
				literatureDetailHeaderCollectionViewCell?.mediaViewerDelegate = self
				literatureDetailHeaderCollectionViewCell?.configure(using: literature)
				return literatureDetailHeaderCollectionViewCell
			case .badge(let literatureDetailBadge):
				let badgeReuseIdentifier = literatureDetailBadge == LiteratureDetail.Badge.rating ? RatingBadgeCollectionViewCell.reuseID : BadgeCollectionViewCell.reuseID
				let badgeCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: badgeReuseIdentifier, for: indexPath) as? BadgeCollectionViewCell
				badgeCollectionViewCell?.configureCell(with: self.literature, literatureDetailBadge: literatureDetailBadge)
				return badgeCollectionViewCell
			case .synopsis:
				let textViewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: TextViewCollectionViewCell.self, for: indexPath)
				textViewCollectionViewCell?.delegate = self
				textViewCollectionViewCell?.textViewCollectionViewCellType = .synopsis
				textViewCollectionViewCell?.textViewContent = self.literature.attributes.synopsis
				return textViewCollectionViewCell
			case .rating(let literatureDetailRating):
				let ratingCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: literatureDetailRating.identifierString, for: indexPath)

				if let stats = self.literature.attributes.stats {
					switch literatureDetailRating {
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
			case .rateAndReview(let literatureDetailRateAndReview):
				let rateAndReviewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: literatureDetailRateAndReview.identifierString, for: indexPath)

				switch literatureDetailRateAndReview {
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
			case .editorial(let editorial):
				let editorialCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: EditorialCollectionViewCell.self, for: indexPath)
				editorialCollectionViewCell?.configure(using: editorial)
				return editorialCollectionViewCell
			case .information(let literatureDetailInformation):
				let informationCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: InformationCollectionViewCell.self, for: indexPath)
				informationCollectionViewCell?.configure(using: self.literature, for: literatureDetailInformation)
				return informationCollectionViewCell
			case .castIdentity:
				return collectionView.dequeueConfiguredReusableCell(using: castCellConfiguration, for: indexPath, item: itemKind)
			case .studioIdentity:
				return collectionView.dequeueConfiguredReusableCell(using: studioCellConfiguration, for: indexPath, item: itemKind)
			case .literatureIdentity:
				return collectionView.dequeueConfiguredReusableCell(using: studioLiteratureCellConfiguration, for: indexPath, item: itemKind)
			case .relatedLiterature, .relatedShow:
				return collectionView.dequeueConfiguredReusableCell(using: relatedLiteratureCellConfiguration, for: indexPath, item: itemKind)
			case .relatedGame:
				return collectionView.dequeueConfiguredReusableCell(using: relatedGameCellConfiguration, for: indexPath, item: itemKind)
			case .sosumi:
				let sosumiCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: SosumiCollectionViewCell.self, for: indexPath)
				sosumiCollectionViewCell?.copyrightText = self.literature.attributes.copyright
				return sosumiCollectionViewCell
			case .characterIdentity, .personIdentity:
				return nil
			}
		}

		self.dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			guard let self = self else { return nil }
			let literatureDetailSection = self.snapshot.sectionIdentifiers[indexPath.section]
			let sectionTitle = literatureDetailSection != .moreByStudio ? literatureDetailSection.stringValue : "\(literatureDetailSection.stringValue) \(self.literature.attributes.studio ?? L10n.studio)"

			let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
			titleHeaderCollectionReusableView.delegate = self
			titleHeaderCollectionReusableView.configure(withTitle: sectionTitle, indexPath: indexPath, segueID: literatureDetailSection.segueIdentifier)
			return titleHeaderCollectionReusableView
		}
	}

	override func updateDataSource() {
		// Built on a local value so the in-progress snapshot is never visible to `self.snapshot`
		// readers (cell/supplementary providers, the library observer) until it's fully assembled.
		var newSnapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		SectionLayoutKind.allCases.forEach { [weak self] literatureDetailSection in
			guard let self = self else { return }
			switch literatureDetailSection {
			case .header:
				newSnapshot.appendSections([literatureDetailSection])
				newSnapshot.appendItems([.literature(self.literature)], toSection: literatureDetailSection)
			case .badge:
				newSnapshot.appendSections([literatureDetailSection])
				let badgeItems: [ItemKind] = LiteratureDetail.Badge.allCases.map { literatureDetailBadge in
					.badge(literatureDetailBadge)
				}
				newSnapshot.appendItems(badgeItems, toSection: literatureDetailSection)
			case .synopsis:
				if let synopsis = self.literature.attributes.synopsis, !synopsis.isEmpty {
					newSnapshot.appendSections([literatureDetailSection])
					newSnapshot.appendItems([.synopsis], toSection: literatureDetailSection)
				}
			case .rating:
				newSnapshot.appendSections([literatureDetailSection])
				let ratingItems: [ItemKind] = LiteratureDetail.Rating.allCases.map { literatureDetailRating in
					.rating(literatureDetailRating)
				}
				newSnapshot.appendItems(ratingItems, toSection: literatureDetailSection)
			case .rateAndReview:
				newSnapshot.appendSections([literatureDetailSection])
				let rateAndReviewItems: [ItemKind] = LiteratureDetail.RateAndReview.allCases.map { literatureDetailRateAndReview in
					.rateAndReview(literatureDetailRateAndReview)
				}
				newSnapshot.appendItems(rateAndReviewItems, toSection: literatureDetailSection)
			case .reviews:
				let hasEditorialContent = self.editorial != nil

				if !self.reviews.isEmpty || hasEditorialContent {
					newSnapshot.appendSections([literatureDetailSection])

					if let editorial = self.editorial {
						newSnapshot.appendItems([.editorial(editorial)], toSection: literatureDetailSection)
					}

					let reviewItems: [ItemKind] = self.reviews.map { review in
						.review(review)
					}
					newSnapshot.appendItems(reviewItems, toSection: literatureDetailSection)
				}
			case .information:
				newSnapshot.appendSections([literatureDetailSection])
				let informationItems: [ItemKind] = LiteratureDetail.Information.allCases.map { literatureDetailInformation in
					.information(literatureDetailInformation)
				}
				newSnapshot.appendItems(informationItems, toSection: literatureDetailSection)
			case .cast:
				if !self.castIdentities.isEmpty {
					newSnapshot.appendSections([literatureDetailSection])
					let castIdentityItems: [ItemKind] = self.castIdentities.map { castIdentity in
						.castIdentity(castIdentity)
					}
					newSnapshot.appendItems(castIdentityItems, toSection: literatureDetailSection)
				}
			case .studios:
				if !self.studioIdentities.isEmpty {
					newSnapshot.appendSections([literatureDetailSection])
					let studioIdentityItems: [ItemKind] = self.studioIdentities.map { studioIdentity in
						.studioIdentity(studioIdentity)
					}
					newSnapshot.appendItems(studioIdentityItems, toSection: literatureDetailSection)
				}
			case .moreByStudio:
				if !self.studioLiteratureIdentities.isEmpty {
					newSnapshot.appendSections([literatureDetailSection])
					let studioLiteratureIdentyItems: [ItemKind] = self.studioLiteratureIdentities.map { studioLiteratureIdentity in
						.literatureIdentity(studioLiteratureIdentity)
					}
					newSnapshot.appendItems(studioLiteratureIdentyItems, toSection: literatureDetailSection)
				}
			case .relatedLiteratures:
				if !self.relatedLiteratures.isEmpty {
					newSnapshot.appendSections([literatureDetailSection])
					let relatedLiteratureItems: [ItemKind] = self.relatedLiteratures.map { relatedLiterature in
						.relatedLiterature(relatedLiterature)
					}
					newSnapshot.appendItems(relatedLiteratureItems, toSection: literatureDetailSection)
				}
			case .relatedShows:
				if !self.relatedShows.isEmpty {
					newSnapshot.appendSections([literatureDetailSection])
					let relatedShowItems: [ItemKind] = self.relatedShows.map { relatedShow in
						.relatedShow(relatedShow)
					}
					newSnapshot.appendItems(relatedShowItems, toSection: literatureDetailSection)
				}
			case .relatedGames:
				if !self.relatedGames.isEmpty {
					newSnapshot.appendSections([literatureDetailSection])
					let relatedGameItems: [ItemKind] = self.relatedGames.map { relatedGame in
						.relatedGame(relatedGame)
					}
					newSnapshot.appendItems(relatedGameItems, toSection: literatureDetailSection)
				}
			case .sosumi:
				if let copyrightIsEmpty = self.literature.attributes.copyright?.isEmpty, !copyrightIsEmpty {
					newSnapshot.appendSections([literatureDetailSection])
					newSnapshot.appendItems([.sosumi], toSection: literatureDetailSection)
				}
			}
		}

		self.snapshot = newSnapshot
		self.dataSource.apply(newSnapshot, animatingDifferences: false)
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
