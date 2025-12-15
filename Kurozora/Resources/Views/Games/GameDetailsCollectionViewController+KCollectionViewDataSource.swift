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
		let studioGameCellConfiguration = self.getConfiguredStudioGameCell()
		let studioCellConfiguration = self.getConfiguredStudioCell()
		let relatedGameCellConfiguration = self.getConfiguredRelatedGameCell()
		let relatedShowCellConfiguration = self.getConfiguredRelatedShowCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }
			guard let gameDetailSection = self.snapshot.sectionIdentifier(containingItem: itemKind) else { return nil }

			switch gameDetailSection {
			case .header:
				let showDetailHeaderCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: ShowDetailHeaderCollectionViewCell.self, for: indexPath)
				showDetailHeaderCollectionViewCell?.delegate = self
				switch itemKind {
				case .game(let game, _):
					showDetailHeaderCollectionViewCell?.configure(using: game)
				default: break
				}
				return showDetailHeaderCollectionViewCell
			case .badge:
				let gameDetailBadge = GameDetail.Badge(rawValue: indexPath.item) ?? .rating
				let badgeReuseIdentifier = gameDetailBadge == GameDetail.Badge.rating ? RatingBadgeCollectionViewCell.reuseID : BadgeCollectionViewCell.reuseID
				let badgeCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: badgeReuseIdentifier, for: indexPath) as? BadgeCollectionViewCell
				switch itemKind {
				case .game(let game, _):
					badgeCollectionViewCell?.configureCell(with: game, gameDetailBadge: gameDetailBadge)
				default: break
				}
				return badgeCollectionViewCell
			case .synopsis:
				let textViewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: TextViewCollectionViewCell.self, for: indexPath)
				textViewCollectionViewCell?.delegate = self
				textViewCollectionViewCell?.textViewCollectionViewCellType = .synopsis
				textViewCollectionViewCell?.textViewContent = self.game.attributes.synopsis
				return textViewCollectionViewCell
			case .rating:
				let gameDetailRating = GameDetail.Rating(rawValue: indexPath.item) ?? .average
				let ratingCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: gameDetailRating.identifierString, for: indexPath)

				switch itemKind {
				case .game(let game, _):
					if let stats = game.attributes.stats {
						switch gameDetailRating {
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
				let gameDetailRateAndReview = GameDetail.RateAndReview(rawValue: indexPath.item) ?? .tapToRate
				let rateAndReviewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: gameDetailRateAndReview.identifierString, for: indexPath)

				switch gameDetailRateAndReview {
				case .tapToRate:
					switch itemKind {
					case .game(let game, _):
						(rateAndReviewCollectionViewCell as? TapToRateCollectionViewCell)?.delegate = self
						(rateAndReviewCollectionViewCell as? TapToRateCollectionViewCell)?.configure(using: game.attributes.library?.rating)
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
				case .game(let game, _):
					informationCollectionViewCell?.configure(using: game, for: GameDetail.Information(rawValue: indexPath.item) ?? .type)
				default: break
				}
				return informationCollectionViewCell
			case .cast:
				return collectionView.dequeueConfiguredReusableCell(using: castCellConfiguration, for: indexPath, item: itemKind)
			case .studios:
				return collectionView.dequeueConfiguredReusableCell(using: studioCellConfiguration, for: indexPath, item: itemKind)
			case .moreByStudio:
				return collectionView.dequeueConfiguredReusableCell(using: studioGameCellConfiguration, for: indexPath, item: itemKind)
			case .relatedGames:
				return collectionView.dequeueConfiguredReusableCell(using: relatedGameCellConfiguration, for: indexPath, item: itemKind)
			case .relatedShows, .relatedLiteratures:
				return collectionView.dequeueConfiguredReusableCell(using: relatedShowCellConfiguration, for: indexPath, item: itemKind)
			case .sosumi:
				let sosumiCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: SosumiCollectionViewCell.self, for: indexPath)
				switch itemKind {
				case .game(let game, _):
					sosumiCollectionViewCell?.copyrightText = game.attributes.copyright
				default: break
				}
				return sosumiCollectionViewCell
			}
		}

		self.dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			guard let self = self else { return nil }
			let gameDetailSection = self.snapshot.sectionIdentifiers[indexPath.section]
			let sectionTitle = gameDetailSection != .moreByStudio ? gameDetailSection.stringValue : "\(gameDetailSection.stringValue) \(self.game.attributes.studio ?? Trans.studio)"

			let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
			titleHeaderCollectionReusableView.delegate = self
			titleHeaderCollectionReusableView.configure(withTitle: sectionTitle, indexPath: indexPath, segueID: gameDetailSection.segueIdentifier)
			return titleHeaderCollectionReusableView
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		SectionLayoutKind.allCases.forEach { [weak self] gameDetailSection in
			guard let self = self else { return }
			switch gameDetailSection {
			case .header:
				self.snapshot.appendSections([gameDetailSection])
				self.snapshot.appendItems([.game(self.game)], toSection: gameDetailSection)
			case .badge:
				self.snapshot.appendSections([gameDetailSection])
				GameDetail.Badge.allCases.forEach { gameDetailBadge in
					switch gameDetailBadge {
//					case .rating:
//						return
					default:
						self.snapshot.appendItems([.game(self.game)], toSection: gameDetailSection)
					}
				}
			case .synopsis:
				if let synopsis = self.game.attributes.synopsis, !synopsis.isEmpty {
					self.snapshot.appendSections([gameDetailSection])
					self.snapshot.appendItems([.game(self.game)], toSection: gameDetailSection)
				}
			case .rating:
				self.snapshot.appendSections([gameDetailSection])
				GameDetail.Rating.allCases.forEach { _ in
					self.snapshot.appendItems([.game(self.game)], toSection: gameDetailSection)
				}
			case .rateAndReview:
				self.snapshot.appendSections([gameDetailSection])
				GameDetail.RateAndReview.allCases.forEach { _ in
					self.snapshot.appendItems([.game(self.game)], toSection: gameDetailSection)
				}
			case .reviews:
				if !self.reviews.isEmpty {
					self.snapshot.appendSections([gameDetailSection])
					let reviewItems: [ItemKind] = self.reviews.map { review in
						.review(review)
					}
					self.snapshot.appendItems(reviewItems, toSection: gameDetailSection)
				}
			case .information:
				self.snapshot.appendSections([gameDetailSection])
				GameDetail.Information.allCases.forEach { _ in
					self.snapshot.appendItems([.game(self.game)], toSection: gameDetailSection)
				}
			case .cast:
				if !self.castIdentities.isEmpty {
					self.snapshot.appendSections([gameDetailSection])
					let castIdentityItems: [ItemKind] = self.castIdentities.map { castIdentity in
						.castIdentity(castIdentity)
					}
					self.snapshot.appendItems(castIdentityItems, toSection: gameDetailSection)
				}
			case .studios:
				if !self.studioIdentities.isEmpty {
					self.snapshot.appendSections([gameDetailSection])
					let studioIdentityItems: [ItemKind] = self.studioIdentities.map { studioIdentity in
						.studioIdentity(studioIdentity)
					}
					self.snapshot.appendItems(studioIdentityItems, toSection: gameDetailSection)
				}
			case .moreByStudio:
				if !self.studioGameIdentities.isEmpty {
					self.snapshot.appendSections([gameDetailSection])
					let studioGameIdentyItems: [ItemKind] = self.studioGameIdentities.map { studioGameIdentity in
						.gameIdentity(studioGameIdentity)
					}
					self.snapshot.appendItems(studioGameIdentyItems, toSection: gameDetailSection)
				}
			case .relatedGames:
				if !self.relatedGames.isEmpty {
					self.snapshot.appendSections([gameDetailSection])
					let relatedGameItems: [ItemKind] = self.relatedGames.map { relatedGame in
						.relatedGame(relatedGame)
					}
					self.snapshot.appendItems(relatedGameItems, toSection: gameDetailSection)
				}
			case .relatedShows:
				if !self.relatedShows.isEmpty {
					self.snapshot.appendSections([gameDetailSection])
					let relatedShowItems: [ItemKind] = self.relatedShows.map { relatedShow in
						.relatedShow(relatedShow)
					}
					self.snapshot.appendItems(relatedShowItems, toSection: gameDetailSection)
				}
			case .relatedLiteratures:
				if !self.relatedLiteratures.isEmpty {
					self.snapshot.appendSections([gameDetailSection])
					let relatedLiteratureItems: [ItemKind] = self.relatedLiteratures.map { relatedLiterature in
						.relatedLiterature(relatedLiterature)
					}
					self.snapshot.appendItems(relatedLiteratureItems, toSection: gameDetailSection)
				}
			case .sosumi:
				if let copyrightIsEmpty = self.game.attributes.copyright?.isEmpty, !copyrightIsEmpty {
					self.snapshot.appendSections([gameDetailSection])
					self.snapshot.appendItems([.game(self.game)], toSection: gameDetailSection)
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
