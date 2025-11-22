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
		let seasonCellConfiguration = self.getConfiguredSeasonCell()
		let castCellConfiguration = self.getConfiguredCastCell()
		let studioShowCellConfiguration = self.getConfiguredStudioShowCell()
		let studioCellConfiguration = self.getConfiguredStudioCell()
		let relatedShowCellConfiguration = self.getConfiguredRelatedShowCell()
		let relatedGameCellConfiguration = self.getConfiguredRelatedGameCell()
		let musicCellConfiguration = self.getConfiguredMusicCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }
			guard let showDetailSection = self.snapshot.sectionIdentifier(containingItem: itemKind) else { return nil }

			switch showDetailSection {
			case .header:
				let showDetailHeaderCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.showDetailHeaderCollectionViewCell, for: indexPath)
				showDetailHeaderCollectionViewCell?.delegate = self
				switch itemKind {
				case .show(let show, _):
					showDetailHeaderCollectionViewCell?.configure(using: show)
				default: break
				}
				return showDetailHeaderCollectionViewCell
			case .badges:
				let showDetailBadge = ShowDetail.Badge(rawValue: indexPath.item) ?? .rating
				let badgeCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: showDetailBadge.identifierString, for: indexPath) as? BadgeCollectionViewCell
				switch itemKind {
				case .show(let show, _):
					badgeCollectionViewCell?.configureCell(with: show, showDetailBadge: showDetailBadge)
				default: break
				}
				return badgeCollectionViewCell
			case .synopsis:
				let textViewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.textViewCollectionViewCell, for: indexPath)
				textViewCollectionViewCell?.delegate = self
				textViewCollectionViewCell?.textViewCollectionViewCellType = .synopsis
				textViewCollectionViewCell?.textViewContent = self.show.attributes.synopsis
				return textViewCollectionViewCell
			case .rating:
				let showDetailRating = ShowDetail.Rating(rawValue: indexPath.item) ?? .average
				let ratingCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: showDetailRating.identifierString, for: indexPath)

				switch itemKind {
				case .show(let show, _):
					if let stats = show.attributes.stats {
						switch showDetailRating {
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
				let showDetailRateAndReview = ShowDetail.RateAndReview(rawValue: indexPath.item) ?? .tapToRate
				let rateAndReviewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: showDetailRateAndReview.identifierString, for: indexPath)

				switch showDetailRateAndReview {
				case .tapToRate:
					switch itemKind {
					case .show(let show, _):
						(rateAndReviewCollectionViewCell as? TapToRateCollectionViewCell)?.delegate = self
						(rateAndReviewCollectionViewCell as? TapToRateCollectionViewCell)?.configure(using: show.attributes.library?.rating)
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
				case .show(let show, _):
					informationCollectionViewCell?.configure(using: show, for: ShowDetail.Information(rawValue: indexPath.item) ?? .type)
				default: break
				}
				return informationCollectionViewCell
			case .seasons:
				return collectionView.dequeueConfiguredReusableCell(using: seasonCellConfiguration, for: indexPath, item: itemKind)
			case .cast:
				return collectionView.dequeueConfiguredReusableCell(using: castCellConfiguration, for: indexPath, item: itemKind)
			case .songs:
				return collectionView.dequeueConfiguredReusableCell(using: musicCellConfiguration, for: indexPath, item: itemKind)
			case .studios:
				return collectionView.dequeueConfiguredReusableCell(using: studioCellConfiguration, for: indexPath, item: itemKind)
			case .moreByStudio:
				return collectionView.dequeueConfiguredReusableCell(using: studioShowCellConfiguration, for: indexPath, item: itemKind)
			case .relatedShows:
				return collectionView.dequeueConfiguredReusableCell(using: relatedShowCellConfiguration, for: indexPath, item: itemKind)
			case .relatedLiteratures:
				return collectionView.dequeueConfiguredReusableCell(using: relatedShowCellConfiguration, for: indexPath, item: itemKind)
			case .relatedGames:
				return collectionView.dequeueConfiguredReusableCell(using: relatedGameCellConfiguration, for: indexPath, item: itemKind)
			case .sosumi:
				let sosumiCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.sosumiCollectionViewCell, for: indexPath)
				switch itemKind {
				case .show(let show, _):
					sosumiCollectionViewCell?.copyrightText = show.attributes.copyright
				default: break
				}
				return sosumiCollectionViewCell
			}
		}

		self.dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			guard let self = self else { return nil }
			let showDetailSection = self.snapshot.sectionIdentifiers[indexPath.section]
			let sectionTitle = showDetailSection != .moreByStudio ? showDetailSection.stringValue : "\(showDetailSection.stringValue) \(self.show.attributes.studio ?? Trans.studio)"

			let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
			titleHeaderCollectionReusableView.delegate = self
			titleHeaderCollectionReusableView.configure(withTitle: sectionTitle, indexPath: indexPath, segueID: showDetailSection.segueIdentifier)
			return titleHeaderCollectionReusableView
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		SectionLayoutKind.allCases.forEach { [weak self] showDetailSection in
			guard let self = self else { return }
			switch showDetailSection {
			case .header:
				self.snapshot.appendSections([showDetailSection])
				self.snapshot.appendItems([.show(self.show)], toSection: showDetailSection)
			case .badges:
				self.snapshot.appendSections([showDetailSection])
				ShowDetail.Badge.allCases.forEach { showDetailBadge in
					switch showDetailBadge {
//					case .rating:
//						return
					default:
						self.snapshot.appendItems([.show(self.show)], toSection: showDetailSection)
					}
				}
			case .synopsis:
				if let synopsis = self.show.attributes.synopsis, !synopsis.isEmpty {
					self.snapshot.appendSections([showDetailSection])
					self.snapshot.appendItems([.show(self.show)], toSection: showDetailSection)
				}
			case .rating:
				self.snapshot.appendSections([showDetailSection])
				ShowDetail.Rating.allCases.forEach { _ in
					self.snapshot.appendItems([.show(self.show)], toSection: showDetailSection)
				}
			case .rateAndReview:
				self.snapshot.appendSections([showDetailSection])
				ShowDetail.RateAndReview.allCases.forEach { _ in
					self.snapshot.appendItems([.show(self.show)], toSection: showDetailSection)
				}
			case .reviews:
				if !self.reviews.isEmpty {
					self.snapshot.appendSections([showDetailSection])
					let reviewItems: [ItemKind] = self.reviews.map { review in
						.review(review)
					}
					self.snapshot.appendItems(reviewItems, toSection: showDetailSection)
				}
			case .information:
				self.snapshot.appendSections([showDetailSection])
				ShowDetail.Information.allCases.forEach { _ in
					self.snapshot.appendItems([.show(self.show)], toSection: showDetailSection)
				}
			case .seasons:
				if !self.seasonIdentities.isEmpty {
					self.snapshot.appendSections([showDetailSection])
					let seasonIdentityItems: [ItemKind] = self.seasonIdentities.map { seasonIdentity in
						.seasonIdentity(seasonIdentity)
					}
					self.snapshot.appendItems(seasonIdentityItems, toSection: showDetailSection)
				}
			case .cast:
				if !self.castIdentities.isEmpty {
					self.snapshot.appendSections([showDetailSection])
					let castIdentityItems: [ItemKind] = self.castIdentities.map { castIdentity in
						.castIdentity(castIdentity)
					}
					self.snapshot.appendItems(castIdentityItems, toSection: showDetailSection)
				}
			case .songs:
				if !self.showSongs.isEmpty {
					self.snapshot.appendSections([showDetailSection])
					let showSongItems: [ItemKind] = self.showSongs.map { showSong in
						.showSong(showSong)
					}
					self.snapshot.appendItems(showSongItems, toSection: showDetailSection)
				}
			case .studios:
				if !self.studioIdentities.isEmpty {
					self.snapshot.appendSections([showDetailSection])
					let studioIdentityItems: [ItemKind] = self.studioIdentities.map { studioIdentity in
						.studioIdentity(studioIdentity)
					}
					self.snapshot.appendItems(studioIdentityItems, toSection: showDetailSection)
				}
			case .moreByStudio:
				if !self.studioShowIdentities.isEmpty {
					self.snapshot.appendSections([showDetailSection])
					let studioShowIdentyItems: [ItemKind] = self.studioShowIdentities.map { studioShowIdentity in
						.showIdentity(studioShowIdentity)
					}
					self.snapshot.appendItems(studioShowIdentyItems, toSection: showDetailSection)
				}
			case .relatedShows:
				if !self.relatedShows.isEmpty {
					self.snapshot.appendSections([showDetailSection])
					let relatedShowItems: [ItemKind] = self.relatedShows.map { relatedShow in
						.relatedShow(relatedShow)
					}
					self.snapshot.appendItems(relatedShowItems, toSection: showDetailSection)
				}
			case .relatedLiteratures:
				if !self.relatedLiteratures.isEmpty {
					self.snapshot.appendSections([showDetailSection])
					let relatedLiteratureItems: [ItemKind] = self.relatedLiteratures.map { relatedLiterature in
						.relatedLiterature(relatedLiterature)
					}
					self.snapshot.appendItems(relatedLiteratureItems, toSection: showDetailSection)
				}
			case .relatedGames:
				if !self.relatedGames.isEmpty {
					self.snapshot.appendSections([showDetailSection])
					let relatedGameItems: [ItemKind] = self.relatedGames.map { relatedGame in
						.relatedGame(relatedGame)
					}
					self.snapshot.appendItems(relatedGameItems, toSection: showDetailSection)
				}
			case .sosumi:
				if let copyrightIsEmpty = self.show.attributes.copyright?.isEmpty, !copyrightIsEmpty {
					self.snapshot.appendSections([showDetailSection])
					self.snapshot.appendItems([.show(self.show)], toSection: showDetailSection)
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
