//
//  ReviewsListCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/04/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension ReviewsListCollectionViewController {
	/// The rating components shown for the list's object.
	var ratingComponents: [CharacterDetail.Rating] {
		switch self.listType {
		case .none:
			return []
		case .episode:
			return CharacterDetail.Rating.allCases.filter { $0 != .favoriteShare }
		default:
			return CharacterDetail.Rating.allCases
		}
	}

	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [
			RatingCollectionViewCell.self,
			RatingSentimentCollectionViewCell.self,
			RatingBarCollectionViewCell.self,
			ReviewCollectionViewCell.self,
			TapToRateCollectionViewCell.self,
			WriteAReviewCollectionViewCell.self,
			DisclosureToggleCollectionViewCell.self,
			EditorialCollectionViewCell.self
		]
	}

	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}

	override func configureDataSource() {
		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			guard let reviewSection = self.snapshot.sectionIdentifier(containingItem: itemKind) else { return nil }

			switch reviewSection {
			case .rating:
				let mediaStat: MediaStat?

				switch itemKind {
				case .character(let character, _):
					mediaStat = character.attributes.stats
				case .episode(let episode, _):
					mediaStat = episode.attributes.stats
				case .game(let game, _):
					mediaStat = game.attributes.stats
				case .literature(let literature, _):
					mediaStat = literature.attributes.stats
				case .person(let person, _):
					mediaStat = person.attributes.stats
				case .show(let show, _):
					mediaStat = show.attributes.stats
				case .song(let song, _):
					mediaStat = song.attributes.stats
				case .studio(let studio, _):
					mediaStat = studio.attributes.stats
				default:
					mediaStat = nil
				}

				let characterDetailRating = self.ratingComponents[safe: indexPath.item] ?? .average
				let ratingCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: characterDetailRating.identifierString, for: indexPath)

				if let stats = mediaStat {
					switch characterDetailRating {
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
			case .rateAndReview:
				let rateAndReview = RateAndReview(rawValue: indexPath.item) ?? .tapToRate
				let rateAndReviewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: rateAndReview.identifierString, for: indexPath)

				switch itemKind {
				case .rateAndReview(let rateAndReview, let rating):
					switch rateAndReview {
					case .tapToRate:
						(rateAndReviewCollectionViewCell as? TapToRateCollectionViewCell)?.delegate = self
						(rateAndReviewCollectionViewCell as? TapToRateCollectionViewCell)?.configure(using: rating)

					case .writeAReview:
						(rateAndReviewCollectionViewCell as? WriteAReviewCollectionViewCell)?.delegate = self
					}
				default: break
				}
				return rateAndReviewCollectionViewCell
			case .reviews, .shortReviews:
				switch itemKind {
				case .review(let review, _):
					let reviewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewCollectionViewCell.self, for: indexPath)
					reviewCollectionViewCell?.delegate = self
					reviewCollectionViewCell?.configureCell(using: review, isElevated: review.attributes.isElevated)
					return reviewCollectionViewCell
				case .editorial(let editorial, _):
					let editorialCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: EditorialCollectionViewCell.self, for: indexPath)
					editorialCollectionViewCell?.configure(using: editorial)
					return editorialCollectionViewCell
				default:
					return nil
				}
			case .shortReviewsToggle:
				let disclosureToggleCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: DisclosureToggleCollectionViewCell.self, for: indexPath)
				disclosureToggleCollectionViewCell?.configure(title: L10n.reviewsShowShort)
				return disclosureToggleCollectionViewCell
			}
		}

		self.dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			guard let self = self else { return nil }
			let reviewSection = self.snapshot.sectionIdentifiers[indexPath.section]

			let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
			titleHeaderCollectionReusableView.configure(withTitle: reviewSection.stringValue)
			return titleHeaderCollectionReusableView
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		SectionLayoutKind.allCases.forEach { [weak self] reviewSection in
			guard let self = self else { return }

			switch reviewSection {
			case .rating:
				self.snapshot.appendSections([reviewSection])

				switch self.listType {
				case .character(let character):
					self.ratingComponents.forEach { _ in
						self.snapshot.appendItems([.character(character)], toSection: reviewSection)
					}
				case .episode(let episode):
					self.ratingComponents.forEach { _ in
						self.snapshot.appendItems([.episode(episode)], toSection: reviewSection)
					}
				case .game(let game):
					self.ratingComponents.forEach { _ in
						self.snapshot.appendItems([.game(game)], toSection: reviewSection)
					}
				case .literature(let literature):
					self.ratingComponents.forEach { _ in
						self.snapshot.appendItems([.literature(literature)], toSection: reviewSection)
					}
				case .person(let person):
					self.ratingComponents.forEach { _ in
						self.snapshot.appendItems([.person(person)], toSection: reviewSection)
					}
				case .show(let show):
					self.ratingComponents.forEach { _ in
						self.snapshot.appendItems([.show(show)], toSection: reviewSection)
					}
				case .song(let song):
					self.ratingComponents.forEach { _ in
						self.snapshot.appendItems([.song(song)], toSection: reviewSection)
					}
				case .studio(let studio):
					self.ratingComponents.forEach { _ in
						self.snapshot.appendItems([.studio(studio)], toSection: reviewSection)
					}
				case .none:
					break
				}
			case .rateAndReview:
				self.snapshot.appendSections([reviewSection])

				let rating: Double? = self.givenRating

				RateAndReview.allCases.forEach { rateAndReview in
					self.snapshot.appendItems([.rateAndReview(rateAndReview, currentRating: rating)], toSection: reviewSection)
				}
			case .reviews:
				let hasEditorialContent = self.editorial != nil

				if !self.reviews.isEmpty || hasEditorialContent {
					self.snapshot.appendSections([reviewSection])

					if let editorial = self.editorial {
						self.snapshot.appendItems([.editorial(editorial)], toSection: reviewSection)
					}

					// The server already sorts low-effort reviews last, so filtering
					// preserves that order without any client-side re-sorting.
					let reviewItems: [ItemKind] = self.reviews.filter { !$0.attributes.isLowEffort }.map { review in
						return .review(review)
					}
					self.snapshot.appendItems(reviewItems, toSection: reviewSection)
				}
			case .shortReviewsToggle:
				guard !self.isShowingLowEffortReviews, self.reviews.contains(where: { $0.attributes.isLowEffort }) else { return }

				self.snapshot.appendSections([reviewSection])
				self.snapshot.appendItems([.lowEffortReviewsToggle(isExpanded: false)], toSection: reviewSection)
			case .shortReviews:
				guard self.isShowingLowEffortReviews else { return }

				let shortReviewItems: [ItemKind] = self.reviews.filter(\.attributes.isLowEffort).map { review in
					return .review(review)
				}
				guard !shortReviewItems.isEmpty else { return }

				self.snapshot.appendSections([reviewSection])
				self.snapshot.appendItems(shortReviewItems, toSection: reviewSection)
			}
		}

		self.dataSource.apply(self.snapshot, animatingDifferences: true)
	}
}
/// List of available show rate & review types.
enum RateAndReview: Int, CaseIterable {
	case tapToRate = 0
	case writeAReview

	// MARK: - Properties
	/// The cell identifier string of a show rate & review section.
	var identifierString: String {
		switch self {
		case .tapToRate:
			return TapToRateCollectionViewCell.reuseID
		case .writeAReview:
			return WriteAReviewCollectionViewCell.reuseID
		}
	}
}
