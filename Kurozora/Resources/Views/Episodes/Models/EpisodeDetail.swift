//
//  EpisodeDetail.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/05/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit

struct EpisodeDetail {}

// MARK: - Badge
extension EpisodeDetail {
	/// List of available episode badge types.
	enum Badge: Int, CaseIterable {
		case rating = 0
		case season
		case rank
		case previousEpisode
		case nextEpisode
		case show

		// MARK: - Properties
		/// The string value of a badge type.
		var stringValue: String {
			switch self {
			case .rating:
				return Trans.rating
			case .season:
				return Trans.season
			case .rank:
				return Trans.rank
			case .previousEpisode:
				return Trans.previous
			case .nextEpisode:
				return Trans.next
			case .show:
				return Trans.anime
			}
		}

		/// The cell identifier string of a episode badge section.
		var identifierString: String {
			switch self {
			case .rating:
				return R.reuseIdentifier.ratingBadgeCollectionViewCell.identifier
			default:
				return R.reuseIdentifier.badgeCollectionViewCell.identifier
			}
		}

		// MARK: - Functions
		/// Returns the required primary information from the given object.
		///
		/// - Parameter episode: The object used to extract the information from.
		///
		/// - Returns: the required primary information from the given object.
		func primaryInformation(from episode: Episode) -> String? {
			switch self {
			case .rating:
				return nil
			case .season:
				return "#\(episode.attributes.seasonNumber)"
			case .rank:
				let rank = episode.attributes.stats?.rankTotal ?? 0
				return rank > 0 ? "#\(rank)" : "-"
			case .previousEpisode:
				return episode.attributes.previousEpisodeTitle ?? "-"
			case .nextEpisode:
				return episode.attributes.nextEpisodeTitle ?? "-"
			case .show:
				return episode.attributes.showTitle.truncated(toLength: 25)
			}
		}

		/// Returns the required secondary information from the given object.
		///
		/// - Parameter episode: The object used to extract the information from.
		///
		/// - Returns: the required secondary information from the given object.
		func secondaryInformation(from episode: Episode? = nil) -> String? {
			switch self {
			case .rating:
				let ratingCount = episode?.attributes.stats?.ratingCount ?? 0
				return ratingCount != 0 ? "\(ratingCount.kkFormatted(precision: 0)) Ratings" : "Not enough ratings"
			case .season:
				return Trans.season
			case .rank:
				return Trans.chart
			case .nextEpisode:
				return Trans.next
			case .previousEpisode:
				return Trans.previous
			case .show:
				return Trans.anime
			}
		}

		/// Returns the required primary image from the given object.
		///
		/// - Parameter episode: The object used to extract the information from.
		///
		/// - Returns: the required primary image from the given object.
		func primaryImage(from episode: Episode? = nil) -> UIImage? {
			switch self {
			case .rating:
				return nil
			case .season:
				return UIImage(systemName: "tv.fill")
			case .rank:
				return UIImage(systemName: "chart.bar.fill")
			case .previousEpisode:
				return UIImage(named: "arrowshape.turn.up.backward.tv.fill")
			case .nextEpisode:
				return UIImage(named: "arrowshape.turn.up.forward.tv.fill")
			case .show:
				return UIImage(systemName: "tv.fill")
			}
		}
	}
}

// MARK: - Ratings
extension EpisodeDetail {
	/// List of available rating types.
	enum Rating: Int, CaseIterable {
		case average = 0
		case sentiment
		case bar

		// MARK: - Properties
		/// The cell identifier string of a rating section.
		var identifierString: String {
			switch self {
			case .average:
				return R.reuseIdentifier.ratingCollectionViewCell.identifier
			case .sentiment:
				return R.reuseIdentifier.ratingSentimentCollectionViewCell.identifier
			case .bar:
				return R.reuseIdentifier.ratingBarCollectionViewCell.identifier
			}
		}
	}
}

// MARK: - Rating & Review
extension EpisodeDetail {
	/// List of available rate & review types.
	enum RateAndReview: Int, CaseIterable {
		case tapToRate = 0
		case writeAReview

		// MARK: - Properties
		/// The cell identifier string of a rate & review section.
		var identifierString: String {
			switch self {
			case .tapToRate:
				return R.reuseIdentifier.tapToRateCollectionViewCell.identifier
			case .writeAReview:
				return R.reuseIdentifier.writeAReviewCollectionViewCell.identifier
			}
		}
	}
}

// MARK: - Information
extension EpisodeDetail {
	/// List of available episode information types.
	enum Information: Int, CaseIterable {
		// MARK: - Cases
		/// The number of the episode.
		case number

		/// The duration of the episode.
		case duration

		/// The air date of the episode.
		case airDate

		// MARK: - Properties
		/// The string value of an information type.
		var stringValue: String {
			switch self {
			case .number:
				return Trans.number
			case .duration:
				return Trans.duration
			case .airDate:
				return Trans.aired
			}
		}

		/// The image value of a studio information type.
		var imageValue: UIImage? {
			switch self {
			case .number:
				return UIImage(systemName: "number")
			case .duration:
				return UIImage(systemName: "hourglass")
			case .airDate:
				return UIImage(systemName: "calendar")
			}
		}

		// MARK: - Functions
		/// Returns the required information from the given object.
		///
		/// - Parameter episode: The object used to extract the information from.
		///
		/// Returns: the required information from the given object.
		func information(from episode: Episode) -> String? {
			switch self {
			case .number:
				return "\(episode.attributes.numberTotal)"
			case .duration:
				return episode.attributes.duration
			case .airDate:
				return episode.attributes.startedAt?.appFormatted(date: .abbreviated, time: .omitted) ?? Trans.tba
			}
		}

		/// Returns the required primary information from the given object.
		///
		/// - Parameter episode: The object used to extract the information from.
		///
		/// - Returns: the required primary information from the given object.
		func primaryInformation(from episode: Episode) -> String? {
			switch self {
			default: return nil
			}
		}

		/// Returns the required secondary information from the given object.
		///
		/// - Parameter episode: The object used to extract the information from.
		///
		/// - Returns: the required secondary information from the given object.
		func secondaryInformation(from episode: Episode) -> String? {
			switch self {
			default: return nil
			}
		}

		/// Returns the required primary image from the given object.
		///
		/// - Parameter episode: The object used to extract the information from.
		///
		/// - Returns: the required primary image from the given object.
		func primaryImage(from episode: Episode) -> UIImage? {
			switch self {
			default: return nil
			}
		}

		/// Returns the footnote from the given object.
		///
		/// - Parameter episode: The object used to extract the footnote from.
		///
		/// - Returns: the footnote from the given object.
		func footnote(from episode: Episode) -> String? {
			switch self {
			case .number:
				return "#\(episode.attributes.number) in the current season."
			case .duration:
				return nil
			case .airDate:
				if let startedAt = episode.attributes.startedAt {
					let isInFuture = startedAt > Date()
					return isInFuture ? "The episode will air on the announced date." : "The episode has finished airing."
				}
				return "A release date has yet to be announced."
			}
		}
	}
}
