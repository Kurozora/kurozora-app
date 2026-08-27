//
//  ShowDetailsCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension ShowDetailsCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [
			ShowDetailHeaderCollectionViewCell.self,
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
		let seasonCellConfiguration = self.getConfiguredSeasonCell()
		let castCellConfiguration = self.getConfiguredCastCell()
		let studioShowCellConfiguration = self.getConfiguredStudioShowCell()
		let studioCellConfiguration = self.getConfiguredStudioCell()
		let relatedShowCellConfiguration = self.getConfiguredRelatedShowCell()
		let relatedGameCellConfiguration = self.getConfiguredRelatedGameCell()
		let musicCellConfiguration = self.getConfiguredMusicCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }

			switch itemKind {
			case .show(let show):
				let showDetailHeaderCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: ShowDetailHeaderCollectionViewCell.self, for: indexPath)
				showDetailHeaderCollectionViewCell?.delegate = self
				showDetailHeaderCollectionViewCell?.mediaViewerDelegate = self
				showDetailHeaderCollectionViewCell?.configure(using: show)
				return showDetailHeaderCollectionViewCell
			case .badge(let showDetailBadge):
				let badgeCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: showDetailBadge.identifierString, for: indexPath) as? BadgeCollectionViewCell
				badgeCollectionViewCell?.configureCell(with: self.show, showDetailBadge: showDetailBadge)
				return badgeCollectionViewCell
			case .synopsis:
				let textViewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: TextViewCollectionViewCell.self, for: indexPath)
				textViewCollectionViewCell?.delegate = self
				textViewCollectionViewCell?.textViewCollectionViewCellType = .synopsis
				textViewCollectionViewCell?.textViewContent = self.show.attributes.synopsis
				return textViewCollectionViewCell
			case .rating(let showDetailRating):
				let ratingCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: showDetailRating.identifierString, for: indexPath)

				if let stats = self.show.attributes.stats {
					switch showDetailRating {
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
			case .rateAndReview(let showDetailRateAndReview):
				let rateAndReviewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: showDetailRateAndReview.identifierString, for: indexPath)

				switch showDetailRateAndReview {
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
			case .information(let showDetailInformation):
				let informationCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: InformationCollectionViewCell.self, for: indexPath)
				informationCollectionViewCell?.configure(using: self.show, for: showDetailInformation)
				return informationCollectionViewCell
			case .seasonIdentity:
				return collectionView.dequeueConfiguredReusableCell(using: seasonCellConfiguration, for: indexPath, item: itemKind)
			case .castIdentity:
				return collectionView.dequeueConfiguredReusableCell(using: castCellConfiguration, for: indexPath, item: itemKind)
			case .showSong:
				return collectionView.dequeueConfiguredReusableCell(using: musicCellConfiguration, for: indexPath, item: itemKind)
			case .studioIdentity:
				return collectionView.dequeueConfiguredReusableCell(using: studioCellConfiguration, for: indexPath, item: itemKind)
			case .showIdentity:
				return collectionView.dequeueConfiguredReusableCell(using: studioShowCellConfiguration, for: indexPath, item: itemKind)
			case .relatedShow, .relatedLiterature:
				return collectionView.dequeueConfiguredReusableCell(using: relatedShowCellConfiguration, for: indexPath, item: itemKind)
			case .relatedGame:
				return collectionView.dequeueConfiguredReusableCell(using: relatedGameCellConfiguration, for: indexPath, item: itemKind)
			case .sosumi:
				let sosumiCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: SosumiCollectionViewCell.self, for: indexPath)
				sosumiCollectionViewCell?.copyrightText = self.show.attributes.copyright
				return sosumiCollectionViewCell
			case .characterIdentity, .personIdentity:
				return nil
			}
		}

		self.dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			guard let self = self else { return nil }
			let showDetailSection = self.snapshot.sectionIdentifiers[indexPath.section]
			let sectionTitle = showDetailSection != .moreByStudio ? showDetailSection.stringValue : "\(showDetailSection.stringValue) \(self.show.attributes.studio ?? L10n.studio)"

			let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
			titleHeaderCollectionReusableView.delegate = self
			titleHeaderCollectionReusableView.configure(withTitle: sectionTitle, indexPath: indexPath, segueID: showDetailSection.segueIdentifier)
			return titleHeaderCollectionReusableView
		}
	}

	override func updateDataSource() {
		// Built on a local value so the in-progress snapshot is never visible to `self.snapshot`
		// readers (cell/supplementary providers, the library observer) until it's fully assembled.
		var newSnapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		SectionLayoutKind.allCases.forEach { [weak self] showDetailSection in
			guard let self = self else { return }
			switch showDetailSection {
			case .header:
				newSnapshot.appendSections([showDetailSection])
				newSnapshot.appendItems([.show(self.show)], toSection: showDetailSection)
			case .badges:
				newSnapshot.appendSections([showDetailSection])
				let badgeItems: [ItemKind] = ShowDetail.Badge.allCases.map { showDetailBadge in
					.badge(showDetailBadge)
				}
				newSnapshot.appendItems(badgeItems, toSection: showDetailSection)
			case .synopsis:
				if let synopsis = self.show.attributes.synopsis, !synopsis.isEmpty {
					newSnapshot.appendSections([showDetailSection])
					newSnapshot.appendItems([.synopsis], toSection: showDetailSection)
				}
			case .rating:
				newSnapshot.appendSections([showDetailSection])
				let ratingItems: [ItemKind] = ShowDetail.Rating.allCases.map { showDetailRating in
					.rating(showDetailRating)
				}
				newSnapshot.appendItems(ratingItems, toSection: showDetailSection)
			case .rateAndReview:
				newSnapshot.appendSections([showDetailSection])
				let rateAndReviewItems: [ItemKind] = ShowDetail.RateAndReview.allCases.map { showDetailRateAndReview in
					.rateAndReview(showDetailRateAndReview)
				}
				newSnapshot.appendItems(rateAndReviewItems, toSection: showDetailSection)
			case .reviews:
				let hasEditorialContent = self.editorial != nil

				if !self.reviews.isEmpty || hasEditorialContent {
					newSnapshot.appendSections([showDetailSection])

					if let editorial = self.editorial {
						newSnapshot.appendItems([.editorial(editorial)], toSection: showDetailSection)
					}

					let reviewItems: [ItemKind] = self.reviews.map { review in
						.review(review)
					}
					newSnapshot.appendItems(reviewItems, toSection: showDetailSection)
				}
			case .information:
				newSnapshot.appendSections([showDetailSection])
				let informationItems: [ItemKind] = ShowDetail.Information.allCases.map { showDetailInformation in
					.information(showDetailInformation)
				}
				newSnapshot.appendItems(informationItems, toSection: showDetailSection)
			case .seasons:
				if !self.seasonIdentities.isEmpty {
					newSnapshot.appendSections([showDetailSection])
					let seasonIdentityItems: [ItemKind] = self.seasonIdentities.map { seasonIdentity in
						.seasonIdentity(seasonIdentity)
					}
					newSnapshot.appendItems(seasonIdentityItems, toSection: showDetailSection)
				}
			case .cast:
				if !self.castIdentities.isEmpty {
					newSnapshot.appendSections([showDetailSection])
					let castIdentityItems: [ItemKind] = self.castIdentities.map { castIdentity in
						.castIdentity(castIdentity)
					}
					newSnapshot.appendItems(castIdentityItems, toSection: showDetailSection)
				}
			case .songs:
				if !self.showSongs.isEmpty {
					newSnapshot.appendSections([showDetailSection])
					let showSongItems: [ItemKind] = self.showSongs.map { showSong in
						.showSong(showSong)
					}
					newSnapshot.appendItems(showSongItems, toSection: showDetailSection)
				}
			case .studios:
				if !self.studioIdentities.isEmpty {
					newSnapshot.appendSections([showDetailSection])
					let studioIdentityItems: [ItemKind] = self.studioIdentities.map { studioIdentity in
						.studioIdentity(studioIdentity)
					}
					newSnapshot.appendItems(studioIdentityItems, toSection: showDetailSection)
				}
			case .moreByStudio:
				if !self.studioShowIdentities.isEmpty {
					newSnapshot.appendSections([showDetailSection])
					let studioShowIdentyItems: [ItemKind] = self.studioShowIdentities.map { studioShowIdentity in
						.showIdentity(studioShowIdentity)
					}
					newSnapshot.appendItems(studioShowIdentyItems, toSection: showDetailSection)
				}
			case .relatedShows:
				if !self.relatedShows.isEmpty {
					newSnapshot.appendSections([showDetailSection])
					let relatedShowItems: [ItemKind] = self.relatedShows.map { relatedShow in
						.relatedShow(relatedShow)
					}
					newSnapshot.appendItems(relatedShowItems, toSection: showDetailSection)
				}
			case .relatedLiteratures:
				if !self.relatedLiteratures.isEmpty {
					newSnapshot.appendSections([showDetailSection])
					let relatedLiteratureItems: [ItemKind] = self.relatedLiteratures.map { relatedLiterature in
						.relatedLiterature(relatedLiterature)
					}
					newSnapshot.appendItems(relatedLiteratureItems, toSection: showDetailSection)
				}
			case .relatedGames:
				if !self.relatedGames.isEmpty {
					newSnapshot.appendSections([showDetailSection])
					let relatedGameItems: [ItemKind] = self.relatedGames.map { relatedGame in
						.relatedGame(relatedGame)
					}
					newSnapshot.appendItems(relatedGameItems, toSection: showDetailSection)
				}
			case .sosumi:
				if let copyrightIsEmpty = self.show.attributes.copyright?.isEmpty, !copyrightIsEmpty {
					newSnapshot.appendSections([showDetailSection])
					newSnapshot.appendItems([.sosumi], toSection: showDetailSection)
				}
			}
		}

		self.snapshot = newSnapshot
		self.dataSource.apply(newSnapshot, animatingDifferences: false)
	}
}
