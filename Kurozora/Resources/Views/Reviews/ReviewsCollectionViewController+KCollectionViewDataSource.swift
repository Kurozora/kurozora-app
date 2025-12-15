//
//  ReviewsCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/04/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension ReviewsCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [
			RatingCollectionViewCell.self,
			RatingSentimentCollectionViewCell.self,
			RatingBarCollectionViewCell.self,
			ReviewCollectionViewCell.self,
			TapToRateCollectionViewCell.self,
			WriteAReviewCollectionViewCell.self
		]
	}

	override func configureDataSource() {
		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			guard let reviewSection = self.snapshot.sectionIdentifier(containingItem: itemKind) else { return nil }

			switch reviewSection {
			case .rating:
				let characterDetailRating = CharacterDetail.Rating(rawValue: indexPath.item) ?? .average
				let ratingCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: characterDetailRating.identifierString, for: indexPath)

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

				if let stats = mediaStat {
					switch characterDetailRating {
					case .average:
						(ratingCollectionViewCell as? RatingCollectionViewCell)?.configure(using: stats)
					case .sentiment:
						(ratingCollectionViewCell as? RatingSentimentCollectionViewCell)?.configure(using: stats)
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
			case .reviews:
				let reviewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewCollectionViewCell.self, for: indexPath)
				switch itemKind {
				case .review(let review, _):
					reviewCollectionViewCell?.delegate = self
					reviewCollectionViewCell?.configureCell(using: review)
				default: break
				}
				return reviewCollectionViewCell
			}
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
					RatingComponent.allCases.forEach { _ in
						self.snapshot.appendItems([.character(character)], toSection: reviewSection)
					}
				case .episode(let episode):
					RatingComponent.allCases.forEach { _ in
						self.snapshot.appendItems([.episode(episode)], toSection: reviewSection)
					}
				case .game(let game):
					RatingComponent.allCases.forEach { _ in
						self.snapshot.appendItems([.game(game)], toSection: reviewSection)
					}
				case .literature(let literature):
					RatingComponent.allCases.forEach { _ in
						self.snapshot.appendItems([.literature(literature)], toSection: reviewSection)
					}
				case .person(let person):
					RatingComponent.allCases.forEach { _ in
						self.snapshot.appendItems([.person(person)], toSection: reviewSection)
					}
				case .show(let show):
					RatingComponent.allCases.forEach { _ in
						self.snapshot.appendItems([.show(show)], toSection: reviewSection)
					}
				case .song(let song):
					RatingComponent.allCases.forEach { _ in
						self.snapshot.appendItems([.song(song)], toSection: reviewSection)
					}
				case .studio(let studio):
					RatingComponent.allCases.forEach { _ in
						self.snapshot.appendItems([.studio(studio)], toSection: reviewSection)
					}
				case .none:
					break
				}
			case .rateAndReview:
				self.snapshot.appendSections([reviewSection])

				let rating: Double?

				switch self.listType {
				case .character(let character):
					rating = character.attributes.givenRating
				case .episode(let episode):
					rating = episode.attributes.givenRating
				case .game(let game):
					rating = game.attributes.library?.rating
				case .literature(let literature):
					rating = literature.attributes.library?.rating
				case .person(let person):
					rating = person.attributes.givenRating
				case .show(let show):
					rating = show.attributes.library?.rating
				case .song(let song):
					rating = song.attributes.library?.rating
				case .studio(let studio):
					rating = studio.attributes.library?.rating
				case .none:
					rating = nil
				}

				RateAndReview.allCases.forEach { rateAndReview in
					self.snapshot.appendItems([.rateAndReview(rateAndReview, currentRating: rating)], toSection: reviewSection)
				}
			case .reviews:
				if !self.reviews.isEmpty {
					self.snapshot.appendSections([reviewSection])
					let reviewItems: [ItemKind] = self.reviews.map { review in
						return .review(review)
					}
					self.snapshot.appendItems(reviewItems, toSection: reviewSection)
				}
			}
		}

		self.dataSource.apply(self.snapshot, animatingDifferences: true)
	}
}

/// List of available show rating types.
enum RatingComponent: Int, CaseIterable {
	case average = 0
	case sentiment
	case bar

	// MARK: - Properties
	/// The cell identifier string of a show rating section.
	var identifierString: String {
		switch self {
		case .average:
			return RatingCollectionViewCell.reuseID
		case .sentiment:
			return RatingSentimentCollectionViewCell.reuseID
		case .bar:
			return RatingBarCollectionViewCell.reuseID
		}
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
