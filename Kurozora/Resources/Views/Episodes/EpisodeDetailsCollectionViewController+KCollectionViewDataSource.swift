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
			EpisodeDetailHeaderCollectionViewCell.self,
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

			switch itemKind {
			case .episode(let episode):
				let episodeDetailHeaderCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: EpisodeDetailHeaderCollectionViewCell.self, for: indexPath)
				episodeDetailHeaderCollectionViewCell?.delegate = self
				episodeDetailHeaderCollectionViewCell?.mediaViewerDelegate = self
				episodeDetailHeaderCollectionViewCell?.indexPath = indexPath
				episodeDetailHeaderCollectionViewCell?.configure(using: episode)
				return episodeDetailHeaderCollectionViewCell
			case .badge(let episodeDetailBadge):
				let badgeReuseIdentifier = episodeDetailBadge == EpisodeDetail.Badge.rating ? RatingBadgeCollectionViewCell.reuseID : BadgeCollectionViewCell.reuseID
				let badgeCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: badgeReuseIdentifier, for: indexPath) as? BadgeCollectionViewCell
				badgeCollectionViewCell?.configureCell(with: self.episode, episodeDetailBadge: episodeDetailBadge)
				return badgeCollectionViewCell
			case .synopsis:
				let textViewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: TextViewCollectionViewCell.self, for: indexPath)
				textViewCollectionViewCell?.delegate = self
				textViewCollectionViewCell?.textViewCollectionViewCellType = .synopsis
				textViewCollectionViewCell?.textViewContent = self.episode.attributes.synopsis
				return textViewCollectionViewCell
			case .rating(let episodeDetailRating):
				let ratingCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: episodeDetailRating.identifierString, for: indexPath)

				if let stats = self.episode.attributes.stats {
					switch episodeDetailRating {
					case .average:
						(ratingCollectionViewCell as? RatingCollectionViewCell)?.configure(using: stats)
					case .sentiment:
						(ratingCollectionViewCell as? RatingSentimentCollectionViewCell)?.configure(using: stats)
					case .bar:
						(ratingCollectionViewCell as? RatingBarCollectionViewCell)?.configure(using: stats)
					}
				}
				return ratingCollectionViewCell
			case .rateAndReview(let episodeDetailRateAndReview):
				let rateAndReviewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: episodeDetailRateAndReview.identifierString, for: indexPath)

				switch episodeDetailRateAndReview {
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
			case .information(let episodeDetailInformation):
				let informationCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: InformationCollectionViewCell.self, for: indexPath)
				informationCollectionViewCell?.configure(using: self.episode, for: episodeDetailInformation)
				return informationCollectionViewCell
			case .castIdentity:
				return collectionView.dequeueConfiguredReusableCell(using: castCellConfiguration, for: indexPath, item: itemKind)
			case .suggestedEpisode:
				return collectionView.dequeueConfiguredReusableCell(using: episodeCellConfiguration, for: indexPath, item: itemKind)
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
		// Built on a local value so the in-progress snapshot is never visible to `self.snapshot`
		// readers (cell/supplementary providers) until it's fully assembled.
		var newSnapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		SectionLayoutKind.allCases.forEach { [weak self] episodeDetailSection in
			guard let self = self else { return }
			switch episodeDetailSection {
			case .header:
				newSnapshot.appendSections([episodeDetailSection])
				newSnapshot.appendItems([.episode(self.episode)], toSection: episodeDetailSection)
			case .badge:
				newSnapshot.appendSections([episodeDetailSection])
				let badgeItems: [ItemKind] = EpisodeDetail.Badge.allCases.map { episodeDetailBadge in
					.badge(episodeDetailBadge)
				}
				newSnapshot.appendItems(badgeItems, toSection: episodeDetailSection)
			case .synopsis:
				if let synopsis = self.episode.attributes.synopsis, !synopsis.isEmpty {
					newSnapshot.appendSections([episodeDetailSection])
					newSnapshot.appendItems([.synopsis], toSection: episodeDetailSection)
				}
			case .rating:
				newSnapshot.appendSections([episodeDetailSection])
				let ratingItems: [ItemKind] = EpisodeDetail.Rating.allCases.map { episodeDetailRating in
					.rating(episodeDetailRating)
				}
				newSnapshot.appendItems(ratingItems, toSection: episodeDetailSection)
			case .rateAndReview:
				newSnapshot.appendSections([episodeDetailSection])
				let rateAndReviewItems: [ItemKind] = EpisodeDetail.RateAndReview.allCases.map { episodeDetailRateAndReview in
					.rateAndReview(episodeDetailRateAndReview)
				}
				newSnapshot.appendItems(rateAndReviewItems, toSection: episodeDetailSection)
			case .reviews:
				if !self.reviews.isEmpty {
					newSnapshot.appendSections([episodeDetailSection])
					let reviewItems: [ItemKind] = self.reviews.map { review in
						.review(review)
					}
					newSnapshot.appendItems(reviewItems, toSection: episodeDetailSection)
				}
			case .information:
				newSnapshot.appendSections([episodeDetailSection])
				let informationItems: [ItemKind] = EpisodeDetail.Information.allCases.map { episodeDetailInformation in
					.information(episodeDetailInformation)
				}
				newSnapshot.appendItems(informationItems, toSection: episodeDetailSection)
			case .cast:
				if !self.castIdentities.isEmpty {
					newSnapshot.appendSections([episodeDetailSection])
					let castIdentityItems: [ItemKind] = self.castIdentities.map { castIdentity in
						.castIdentity(castIdentity)
					}
					newSnapshot.appendItems(castIdentityItems, toSection: episodeDetailSection)
				}
			case .suggestedEpisodes:
				if !self.suggestedEpisodes.isEmpty {
					newSnapshot.appendSections([episodeDetailSection])
					let episodeItems: [ItemKind] = self.suggestedEpisodes.map { episode in
						.suggestedEpisode(episode)
					}
					newSnapshot.appendItems(episodeItems, toSection: episodeDetailSection)
				}
			case .sosumi:
				break
			}
		}

		self.snapshot = newSnapshot
		self.dataSource.apply(newSnapshot, animatingDifferences: false)
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
			case .castIdentity(let castIdentitiy):
				let cast = self.fetchCast(at: indexPath)

				if cast == nil {
					Task {
						do {
							let castResponse = try await KService.detail(castIdentitiy).response()
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
			case .suggestedEpisode(let episode):
				episodeLockupCollectionViewCell.delegate = self
				episodeLockupCollectionViewCell.configure(using: episode)
			default: break
			}
		}
	}
}
