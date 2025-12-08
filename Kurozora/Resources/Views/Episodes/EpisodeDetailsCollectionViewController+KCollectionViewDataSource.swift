//
//  EpisodeDetailsCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension EpisodeDetailsCollectionViewController {
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
			SosumiCollectionViewCell.self,
		]
	}

	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}

	override func configureDataSource() {
		let castCellConfiguration = self.getConfiguredCastCell()
		let episodeCellConfiguration = self.getConfiguredEpisodeCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }
			guard let episodeDetailSection = self.snapshot.sectionIdentifier(containingItem: itemKind) else { return nil }

			switch episodeDetailSection {
			case .header:
				let episodeDetailHeaderCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: EpisodeDetailHeaderCollectionViewCell.self, for: indexPath)
				episodeDetailHeaderCollectionViewCell?.delegate = self

				switch itemKind {
				case .episode(let episode, _):
					episodeDetailHeaderCollectionViewCell?.indexPath = indexPath
					episodeDetailHeaderCollectionViewCell?.configure(using: episode)
				default: break
				}
				return episodeDetailHeaderCollectionViewCell
			case .badge:
				let episodeDetailBadge = EpisodeDetail.Badge(rawValue: indexPath.item) ?? .rating
				let badgeReuseIdentifier = episodeDetailBadge == EpisodeDetail.Badge.rating ? RatingBadgeCollectionViewCell.reuseID : BadgeCollectionViewCell.reuseID
				let badgeCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: badgeReuseIdentifier, for: indexPath) as? BadgeCollectionViewCell
				switch itemKind {
				case .episode(let episode, _):
					badgeCollectionViewCell?.configureCell(with: episode, episodeDetailBadge: episodeDetailBadge)
				default: break
				}
				return badgeCollectionViewCell
			case .synopsis:
				let textViewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.textViewCollectionViewCell, for: indexPath)
				textViewCollectionViewCell?.delegate = self
				textViewCollectionViewCell?.textViewCollectionViewCellType = .synopsis
				textViewCollectionViewCell?.textViewContent = self.episode.attributes.synopsis
				return textViewCollectionViewCell
			case .rating:
				let episodeDetailRating = EpisodeDetail.Rating(rawValue: indexPath.item) ?? .average
				let ratingCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: episodeDetailRating.identifierString, for: indexPath)

				switch itemKind {
				case .episode(let episode, _):
					if let stats = episode.attributes.stats {
						switch episodeDetailRating {
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
				let episodeDetailRateAndReview = EpisodeDetail.RateAndReview(rawValue: indexPath.item) ?? .tapToRate
				let rateAndReviewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: episodeDetailRateAndReview.identifierString, for: indexPath)

				switch episodeDetailRateAndReview {
				case .tapToRate:
					switch itemKind {
					case .episode(let episode, _):
						(rateAndReviewCollectionViewCell as? TapToRateCollectionViewCell)?.delegate = self
						(rateAndReviewCollectionViewCell as? TapToRateCollectionViewCell)?.configure(using: episode.attributes.givenRating)
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
				case .episode(let episode, _):
					informationCollectionViewCell?.configure(using: episode, for: EpisodeDetail.Information(rawValue: indexPath.item) ?? .number)
				default: break
				}
				return informationCollectionViewCell
			case .cast:
				return collectionView.dequeueConfiguredReusableCell(using: castCellConfiguration, for: indexPath, item: itemKind)
			case .suggestedEpisodes:
				return collectionView.dequeueConfiguredReusableCell(using: episodeCellConfiguration, for: indexPath, item: itemKind)
			case .sosumi: return nil
//				let sosumiCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.sosumiCollectionViewCell, for: indexPath)
//				switch itemKind {
//				case .episode(let episode, _):
//					sosumiCollectionViewCell?.copyrightText = episode.attributes.copyright
//				default: break
//				}
//				return sosumiCollectionViewCell
			}
		}

		self.dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			guard let self = self else { return nil }
			let episodeDetailSection = self.snapshot.sectionIdentifiers[indexPath.section]
			let sectionTitle = episodeDetailSection.stringValue

			let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
			titleHeaderCollectionReusableView.delegate = self
			titleHeaderCollectionReusableView.configure(withTitle: sectionTitle, indexPath: indexPath, segueID: episodeDetailSection.segueIdentifier)
			return titleHeaderCollectionReusableView
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		SectionLayoutKind.allCases.forEach { [weak self] episodeDetailSection in
			guard let self = self else { return }
			switch episodeDetailSection {
			case .header:
				self.snapshot.appendSections([episodeDetailSection])
				self.snapshot.appendItems([.episode(self.episode)], toSection: episodeDetailSection)
			case .badge:
				self.snapshot.appendSections([episodeDetailSection])
				for episodeDetailBadge in EpisodeDetail.Badge.allCases {
					switch episodeDetailBadge {
//					case .rating:
//						return
					default:
						self.snapshot.appendItems([.episode(self.episode)], toSection: episodeDetailSection)
					}
				}
			case .synopsis:
				if let synopsis = self.episode.attributes.synopsis, !synopsis.isEmpty {
					self.snapshot.appendSections([episodeDetailSection])
					self.snapshot.appendItems([.episode(self.episode)], toSection: episodeDetailSection)
				}
			case .rating:
				self.snapshot.appendSections([episodeDetailSection])
				for _ in EpisodeDetail.Rating.allCases {
					self.snapshot.appendItems([.episode(self.episode)], toSection: episodeDetailSection)
				}
			case .rateAndReview:
				self.snapshot.appendSections([episodeDetailSection])
				for _ in EpisodeDetail.RateAndReview.allCases {
					self.snapshot.appendItems([.episode(self.episode)], toSection: episodeDetailSection)
				}
			case .reviews:
				if !self.reviews.isEmpty {
					self.snapshot.appendSections([episodeDetailSection])
					let reviewItems: [ItemKind] = self.reviews.map { review in
						.review(review)
					}
					self.snapshot.appendItems(reviewItems, toSection: episodeDetailSection)
				}
			case .information:
				self.snapshot.appendSections([episodeDetailSection])
				for _ in EpisodeDetail.Information.allCases {
					self.snapshot.appendItems([.episode(self.episode)], toSection: episodeDetailSection)
				}
			case .cast:
				if !self.castIdentities.isEmpty {
					self.snapshot.appendSections([episodeDetailSection])
					let castIdentityItems: [ItemKind] = self.castIdentities.map { castIdentity in
						.castIdentity(castIdentity)
					}
					self.snapshot.appendItems(castIdentityItems, toSection: episodeDetailSection)
				}
			case .suggestedEpisodes:
				if !self.suggestedEpisodes.isEmpty {
					self.snapshot.appendSections([episodeDetailSection])
					let episodeItems: [ItemKind] = self.suggestedEpisodes.map { episode in
						.episode(episode)
					}
					self.snapshot.appendItems(episodeItems, toSection: episodeDetailSection)
				}
			case .sosumi: break
//				if let copyrightIsEmpty = self.episode.attributes.copyright?.isEmpty, !copyrightIsEmpty {
//					self.snapshot.appendSections([episodeDetailSection])
//					self.snapshot.appendItems([.episode(self.episode)], toSection: episodeDetailSection)
//				}
			}
		}

		self.dataSource.apply(self.snapshot, animatingDifferences: false)
	}

	func fetchCast(at indexPath: IndexPath) -> Cast? {
		guard let cast = self.cast[indexPath] else { return nil }
		return cast
	}

	func setItemKindNeedsUpdate(_ itemKind: ItemKind) {
		var snapshot = self.dataSource.snapshot()
		guard snapshot.indexOfItem(itemKind) != nil else { return }
		snapshot.reconfigureItems([itemKind])
		self.dataSource.apply(snapshot, animatingDifferences: true)
	}
}

extension EpisodeDetailsCollectionViewController {
	func getConfiguredCastCell() -> UICollectionView.CellRegistration<CastCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<CastCollectionViewCell, ItemKind>(cellNib: CastCollectionViewCell.nib) { [weak self] castCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .castIdentity(let castIdentitiy, _):
				let cast = self.fetchCast(at: indexPath)

				if cast == nil {
					Task {
						do {
							let castResponse = try await KService.getDetails(forGameCast: castIdentitiy).value
							self.cast[indexPath] = castResponse.data.first
							self.setItemKindNeedsUpdate(itemKind)
						} catch {
							print(error.localizedDescription)
						}
					}
				}

				castCollectionViewCell.delegate = self
				castCollectionViewCell.configure(using: cast)
			default: return
			}
		}
	}

	func getConfiguredEpisodeCell() -> UICollectionView.CellRegistration<EpisodeLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<EpisodeLockupCollectionViewCell, ItemKind>(cellNib: EpisodeLockupCollectionViewCell.nib) { [weak self] episodeLockupCollectionViewCell, _, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .episode(let episode, _):
				episodeLockupCollectionViewCell.delegate = self
				episodeLockupCollectionViewCell.configure(using: episode)
			default: break
			}
		}
	}
}
