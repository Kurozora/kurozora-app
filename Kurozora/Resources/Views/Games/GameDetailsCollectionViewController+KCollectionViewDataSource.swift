//
//  GameDetailsCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/02/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension GameDetailsCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [
			GameDetailHeaderCollectionViewCell.self,
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
		let studioGameCellConfiguration = self.getConfiguredStudioGameCell()
		let studioCellConfiguration = self.getConfiguredStudioCell()
		let relatedGameCellConfiguration = self.getConfiguredRelatedGameCell()
		let relatedShowCellConfiguration = self.getConfiguredRelatedShowCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }

			switch itemKind {
			case .game(let game):
				let gameDetailHeaderCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: GameDetailHeaderCollectionViewCell.self, for: indexPath)
				gameDetailHeaderCollectionViewCell?.delegate = self
				gameDetailHeaderCollectionViewCell?.mediaViewerDelegate = self
				gameDetailHeaderCollectionViewCell?.configure(using: game)
				return gameDetailHeaderCollectionViewCell
			case .badge(let gameDetailBadge):
				let badgeReuseIdentifier = gameDetailBadge == GameDetail.Badge.rating ? RatingBadgeCollectionViewCell.reuseID : BadgeCollectionViewCell.reuseID
				let badgeCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: badgeReuseIdentifier, for: indexPath) as? BadgeCollectionViewCell
				badgeCollectionViewCell?.configureCell(with: self.game, gameDetailBadge: gameDetailBadge)
				return badgeCollectionViewCell
			case .synopsis:
				let textViewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: TextViewCollectionViewCell.self, for: indexPath)
				textViewCollectionViewCell?.delegate = self
				textViewCollectionViewCell?.textViewCollectionViewCellType = .synopsis
				textViewCollectionViewCell?.textViewContent = self.game.attributes.synopsis
				return textViewCollectionViewCell
			case .rating(let gameDetailRating):
				let ratingCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: gameDetailRating.identifierString, for: indexPath)

				if let stats = self.game.attributes.stats {
					switch gameDetailRating {
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
			case .rateAndReview(let gameDetailRateAndReview):
				let rateAndReviewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: gameDetailRateAndReview.identifierString, for: indexPath)

				switch gameDetailRateAndReview {
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
			case .information(let gameDetailInformation):
				let informationCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: InformationCollectionViewCell.self, for: indexPath)
				informationCollectionViewCell?.configure(using: self.game, for: gameDetailInformation)
				return informationCollectionViewCell
			case .castIdentity:
				return collectionView.dequeueConfiguredReusableCell(using: castCellConfiguration, for: indexPath, item: itemKind)
			case .studioIdentity:
				return collectionView.dequeueConfiguredReusableCell(using: studioCellConfiguration, for: indexPath, item: itemKind)
			case .gameIdentity:
				return collectionView.dequeueConfiguredReusableCell(using: studioGameCellConfiguration, for: indexPath, item: itemKind)
			case .relatedGame:
				return collectionView.dequeueConfiguredReusableCell(using: relatedGameCellConfiguration, for: indexPath, item: itemKind)
			case .relatedShow, .relatedLiterature:
				return collectionView.dequeueConfiguredReusableCell(using: relatedShowCellConfiguration, for: indexPath, item: itemKind)
			case .sosumi:
				let sosumiCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: SosumiCollectionViewCell.self, for: indexPath)
				sosumiCollectionViewCell?.copyrightText = self.game.attributes.copyright
				return sosumiCollectionViewCell
			case .characterIdentity, .personIdentity:
				return nil
			}
		}

		self.dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			guard let self = self else { return nil }
			let gameDetailSection = self.snapshot.sectionIdentifiers[indexPath.section]
			let sectionTitle = gameDetailSection != .moreByStudio ? gameDetailSection.stringValue : "\(gameDetailSection.stringValue) \(self.game.attributes.studio ?? L10n.studio)"

			let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
			titleHeaderCollectionReusableView.delegate = self
			titleHeaderCollectionReusableView.configure(withTitle: sectionTitle, indexPath: indexPath, segueID: gameDetailSection.segueIdentifier)
			return titleHeaderCollectionReusableView
		}
	}

	override func updateDataSource() {
		// Built on a local value so the in-progress snapshot is never visible to `self.snapshot`
		// readers (cell/supplementary providers, the library observer) until it's fully assembled.
		var newSnapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		SectionLayoutKind.allCases.forEach { [weak self] gameDetailSection in
			guard let self = self else { return }
			switch gameDetailSection {
			case .header:
				newSnapshot.appendSections([gameDetailSection])
				newSnapshot.appendItems([.game(self.game)], toSection: gameDetailSection)
			case .badge:
				newSnapshot.appendSections([gameDetailSection])
				let badgeItems: [ItemKind] = GameDetail.Badge.allCases.map { gameDetailBadge in
					.badge(gameDetailBadge)
				}
				newSnapshot.appendItems(badgeItems, toSection: gameDetailSection)
			case .synopsis:
				if let synopsis = self.game.attributes.synopsis, !synopsis.isEmpty {
					newSnapshot.appendSections([gameDetailSection])
					newSnapshot.appendItems([.synopsis], toSection: gameDetailSection)
				}
			case .rating:
				newSnapshot.appendSections([gameDetailSection])
				let ratingItems: [ItemKind] = GameDetail.Rating.allCases.map { gameDetailRating in
					.rating(gameDetailRating)
				}
				newSnapshot.appendItems(ratingItems, toSection: gameDetailSection)
			case .rateAndReview:
				newSnapshot.appendSections([gameDetailSection])
				let rateAndReviewItems: [ItemKind] = GameDetail.RateAndReview.allCases.map { gameDetailRateAndReview in
					.rateAndReview(gameDetailRateAndReview)
				}
				newSnapshot.appendItems(rateAndReviewItems, toSection: gameDetailSection)
			case .reviews:
				let hasEditorialContent = self.editorial != nil

				if !self.reviews.isEmpty || hasEditorialContent {
					newSnapshot.appendSections([gameDetailSection])

					if let editorial = self.editorial {
						newSnapshot.appendItems([.editorial(editorial)], toSection: gameDetailSection)
					}

					let reviewItems: [ItemKind] = self.reviews.map { review in
						.review(review)
					}
					newSnapshot.appendItems(reviewItems, toSection: gameDetailSection)
				}
			case .information:
				newSnapshot.appendSections([gameDetailSection])
				let informationItems: [ItemKind] = GameDetail.Information.allCases.map { gameDetailInformation in
					.information(gameDetailInformation)
				}
				newSnapshot.appendItems(informationItems, toSection: gameDetailSection)
			case .cast:
				if !self.castIdentities.isEmpty {
					newSnapshot.appendSections([gameDetailSection])
					let castIdentityItems: [ItemKind] = self.castIdentities.map { castIdentity in
						.castIdentity(castIdentity)
					}
					newSnapshot.appendItems(castIdentityItems, toSection: gameDetailSection)
				}
			case .studios:
				if !self.studioIdentities.isEmpty {
					newSnapshot.appendSections([gameDetailSection])
					let studioIdentityItems: [ItemKind] = self.studioIdentities.map { studioIdentity in
						.studioIdentity(studioIdentity)
					}
					newSnapshot.appendItems(studioIdentityItems, toSection: gameDetailSection)
				}
			case .moreByStudio:
				if !self.studioGameIdentities.isEmpty {
					newSnapshot.appendSections([gameDetailSection])
					let studioGameIdentyItems: [ItemKind] = self.studioGameIdentities.map { studioGameIdentity in
						.gameIdentity(studioGameIdentity)
					}
					newSnapshot.appendItems(studioGameIdentyItems, toSection: gameDetailSection)
				}
			case .relatedGames:
				if !self.relatedGames.isEmpty {
					newSnapshot.appendSections([gameDetailSection])
					let relatedGameItems: [ItemKind] = self.relatedGames.map { relatedGame in
						.relatedGame(relatedGame)
					}
					newSnapshot.appendItems(relatedGameItems, toSection: gameDetailSection)
				}
			case .relatedShows:
				if !self.relatedShows.isEmpty {
					newSnapshot.appendSections([gameDetailSection])
					let relatedShowItems: [ItemKind] = self.relatedShows.map { relatedShow in
						.relatedShow(relatedShow)
					}
					newSnapshot.appendItems(relatedShowItems, toSection: gameDetailSection)
				}
			case .relatedLiteratures:
				if !self.relatedLiteratures.isEmpty {
					newSnapshot.appendSections([gameDetailSection])
					let relatedLiteratureItems: [ItemKind] = self.relatedLiteratures.map { relatedLiterature in
						.relatedLiterature(relatedLiterature)
					}
					newSnapshot.appendItems(relatedLiteratureItems, toSection: gameDetailSection)
				}
			case .sosumi:
				if let copyrightIsEmpty = self.game.attributes.copyright?.isEmpty, !copyrightIsEmpty {
					newSnapshot.appendSections([gameDetailSection])
					newSnapshot.appendItems([.sosumi], toSection: gameDetailSection)
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
