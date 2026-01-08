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
			guard let literatureDetailSection = self.snapshot.sectionIdentifier(containingItem: itemKind) else { return nil }

			switch literatureDetailSection {
			case .header:
				let literatureDetailHeaderCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: LiteratureDetailHeaderCollectionViewCell.self, for: indexPath)
				literatureDetailHeaderCollectionViewCell?.delegate = self
				switch itemKind {
				case .literature(let literature, _):
					literatureDetailHeaderCollectionViewCell?.configure(using: literature)
				default: break
				}
				return literatureDetailHeaderCollectionViewCell
			case .badge:
				let literatureDetailBadge = LiteratureDetail.Badge(rawValue: indexPath.item) ?? .rating
				let badgeReuseIdentifier = literatureDetailBadge == LiteratureDetail.Badge.rating ? RatingBadgeCollectionViewCell.reuseID : BadgeCollectionViewCell.reuseID
				let badgeCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: badgeReuseIdentifier, for: indexPath) as? BadgeCollectionViewCell
				switch itemKind {
				case .literature(let literature, _):
					badgeCollectionViewCell?.configureCell(with: literature, literatureDetailBadge: literatureDetailBadge)
				default: break
				}
				return badgeCollectionViewCell
			case .synopsis:
				let textViewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: TextViewCollectionViewCell.self, for: indexPath)
				textViewCollectionViewCell?.delegate = self
				textViewCollectionViewCell?.textViewCollectionViewCellType = .synopsis
				textViewCollectionViewCell?.textViewContent = self.literature.attributes.synopsis
				return textViewCollectionViewCell
			case .rating:
				let literatureDetailRating = LiteratureDetail.Rating(rawValue: indexPath.item) ?? .average
				let ratingCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: literatureDetailRating.identifierString, for: indexPath)

				switch itemKind {
				case .literature(let literature, _):
					if let stats = literature.attributes.stats {
						switch literatureDetailRating {
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
				let literatureDetailRateAndReview = LiteratureDetail.RateAndReview(rawValue: indexPath.item) ?? .tapToRate
				let rateAndReviewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: literatureDetailRateAndReview.identifierString, for: indexPath)

				switch literatureDetailRateAndReview {
				case .tapToRate:
					switch itemKind {
					case .literature(let literature, _):
						(rateAndReviewCollectionViewCell as? TapToRateCollectionViewCell)?.delegate = self
						(rateAndReviewCollectionViewCell as? TapToRateCollectionViewCell)?.configure(using: literature.attributes.library?.rating)
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
				case .literature(let literature, _):
					informationCollectionViewCell?.configure(using: literature, for: LiteratureDetail.Information(rawValue: indexPath.item) ?? .type)
				default: break
				}
				return informationCollectionViewCell
			case .cast:
				return collectionView.dequeueConfiguredReusableCell(using: castCellConfiguration, for: indexPath, item: itemKind)
			case .studios:
				return collectionView.dequeueConfiguredReusableCell(using: studioCellConfiguration, for: indexPath, item: itemKind)
			case .moreByStudio:
				return collectionView.dequeueConfiguredReusableCell(using: studioLiteratureCellConfiguration, for: indexPath, item: itemKind)
			case .relatedLiteratures, .relatedShows:
				return collectionView.dequeueConfiguredReusableCell(using: relatedLiteratureCellConfiguration, for: indexPath, item: itemKind)
			case .relatedGames:
				return collectionView.dequeueConfiguredReusableCell(using: relatedGameCellConfiguration, for: indexPath, item: itemKind)
			case .sosumi:
				let sosumiCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: SosumiCollectionViewCell.self, for: indexPath)
				switch itemKind {
				case .literature(let literature, _):
					sosumiCollectionViewCell?.copyrightText = literature.attributes.copyright
				default: break
				}
				return sosumiCollectionViewCell
			}
		}

		self.dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			guard let self = self else { return nil }
			let literatureDetailSection = self.snapshot.sectionIdentifiers[indexPath.section]
			let sectionTitle = literatureDetailSection != .moreByStudio ? literatureDetailSection.stringValue : "\(literatureDetailSection.stringValue) \(self.literature.attributes.studio ?? Trans.studio)"

			let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
			titleHeaderCollectionReusableView.delegate = self
			titleHeaderCollectionReusableView.configure(withTitle: sectionTitle, indexPath: indexPath, segueID: literatureDetailSection.segueIdentifier)
			return titleHeaderCollectionReusableView
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		SectionLayoutKind.allCases.forEach { [weak self] literatureDetailSection in
			guard let self = self else { return }
			switch literatureDetailSection {
			case .header:
				self.snapshot.appendSections([literatureDetailSection])
				self.snapshot.appendItems([.literature(self.literature)], toSection: literatureDetailSection)
			case .badge:
				self.snapshot.appendSections([literatureDetailSection])
				LiteratureDetail.Badge.allCases.forEach { literatureDetailBadge in
					switch literatureDetailBadge {
//					case .rating:
//						return
					default:
						self.snapshot.appendItems([.literature(self.literature)], toSection: literatureDetailSection)
					}
				}
			case .synopsis:
				if let synopsis = self.literature.attributes.synopsis, !synopsis.isEmpty {
					self.snapshot.appendSections([literatureDetailSection])
					self.snapshot.appendItems([.literature(self.literature)], toSection: literatureDetailSection)
				}
			case .rating:
				self.snapshot.appendSections([literatureDetailSection])
				LiteratureDetail.Rating.allCases.forEach { _ in
					self.snapshot.appendItems([.literature(self.literature)], toSection: literatureDetailSection)
				}
			case .rateAndReview:
				self.snapshot.appendSections([literatureDetailSection])
				LiteratureDetail.RateAndReview.allCases.forEach { _ in
					self.snapshot.appendItems([.literature(self.literature)], toSection: literatureDetailSection)
				}
			case .reviews:
				if !self.reviews.isEmpty {
					self.snapshot.appendSections([literatureDetailSection])
					let reviewItems: [ItemKind] = self.reviews.map { review in
						.review(review)
					}
					self.snapshot.appendItems(reviewItems, toSection: literatureDetailSection)
				}
			case .information:
				self.snapshot.appendSections([literatureDetailSection])
				LiteratureDetail.Information.allCases.forEach { _ in
					self.snapshot.appendItems([.literature(self.literature)], toSection: literatureDetailSection)
				}
			case .cast:
				if !self.castIdentities.isEmpty {
					self.snapshot.appendSections([literatureDetailSection])
					let castIdentityItems: [ItemKind] = self.castIdentities.map { castIdentity in
						.castIdentity(castIdentity)
					}
					self.snapshot.appendItems(castIdentityItems, toSection: literatureDetailSection)
				}
			case .studios:
				if !self.studioIdentities.isEmpty {
					self.snapshot.appendSections([literatureDetailSection])
					let studioIdentityItems: [ItemKind] = self.studioIdentities.map { studioIdentity in
						.studioIdentity(studioIdentity)
					}
					self.snapshot.appendItems(studioIdentityItems, toSection: literatureDetailSection)
				}
			case .moreByStudio:
				if !self.studioLiteratureIdentities.isEmpty {
					self.snapshot.appendSections([literatureDetailSection])
					let studioLiteratureIdentyItems: [ItemKind] = self.studioLiteratureIdentities.map { studioLiteratureIdentity in
						.literatureIdentity(studioLiteratureIdentity)
					}
					self.snapshot.appendItems(studioLiteratureIdentyItems, toSection: literatureDetailSection)
				}
			case .relatedLiteratures:
				if !self.relatedLiteratures.isEmpty {
					self.snapshot.appendSections([literatureDetailSection])
					let relatedLiteratureItems: [ItemKind] = self.relatedLiteratures.map { relatedLiterature in
						.relatedLiterature(relatedLiterature)
					}
					self.snapshot.appendItems(relatedLiteratureItems, toSection: literatureDetailSection)
				}
			case .relatedShows:
				if !self.relatedShows.isEmpty {
					self.snapshot.appendSections([literatureDetailSection])
					let relatedShowItems: [ItemKind] = self.relatedShows.map { relatedShow in
						.relatedShow(relatedShow)
					}
					self.snapshot.appendItems(relatedShowItems, toSection: literatureDetailSection)
				}
			case .relatedGames:
				if !self.relatedGames.isEmpty {
					self.snapshot.appendSections([literatureDetailSection])
					let relatedGameItems: [ItemKind] = self.relatedGames.map { relatedGame in
						.relatedGame(relatedGame)
					}
					self.snapshot.appendItems(relatedGameItems, toSection: literatureDetailSection)
				}
			case .sosumi:
				if let copyrightIsEmpty = self.literature.attributes.copyright?.isEmpty, !copyrightIsEmpty {
					self.snapshot.appendSections([literatureDetailSection])
					self.snapshot.appendItems([.literature(self.literature)], toSection: literatureDetailSection)
				}
			}
		}

		self.dataSource.apply(self.snapshot, animatingDifferences: false)
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
