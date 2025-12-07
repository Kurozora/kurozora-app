//
//  ShowDetail.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/04/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

struct ShowDetail {}

// MARK: - Badge
extension ShowDetail {
	/// List of available show badge types.
	enum Badge: Int, CaseIterable {
		case rating = 0
		case season
		case rank
		case tvRating
		case studio
		case country
		case language

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
			case .tvRating:
				return Trans.tvRating
			case .studio:
				return Trans.studio
			case .country:
				return Trans.country
			case .language:
				return Trans.language
			}
		}

		/// The cell identifier string of a show information section.
		var identifierString: String {
			switch self {
			case .rating:
				return RatingBadgeCollectionViewCell.reuseID
			default:
				return BadgeCollectionViewCell.reuseID
			}
		}

		// MARK: - Functions
		/// Returns the required primary information from the given object.
		///
		/// - Parameter show: The object used to extract the information from.
		///
		/// - Returns: the required primary information from the given object.
		func primaryInformation(from show: Show) -> String? {
			switch self {
			case .rating:
				return nil
			case .season:
				return show.attributes.airSeason ?? "-"
			case .rank:
				let rank = show.attributes.stats?.rankTotal ?? 0
				return rank > 0 ? "#\(rank)" : "-"
			case .tvRating:
				return show.attributes.tvRating.name
			case .studio:
				return show.attributes.studio ?? "-"
			case .country:
				return show.attributes.countryOfOrigin?.code.uppercased() ?? "-"
			case .language:
				return show.attributes.languages.first?.code.uppercased() ?? "-"
			}
		}

		/// Returns the required secondary information from the given object.
		///
		/// - Parameter show: The object used to extract the information from.
		///
		/// - Returns: the required secondary information from the given object.
		func secondaryInformation(from show: Show? = nil) -> String? {
			switch self {
			case .rating:
				let ratingCount = show?.attributes.stats?.ratingCount ?? 0
				return ratingCount != 0 ? "\(ratingCount.kkFormatted(precision: 0)) Ratings" : "Not enough ratings"
			case .season:
				return Trans.season
			case .rank:
				return Trans.chart // e.g. Thriller — show.attributes.popularity.genre
			case .tvRating:
				return "Rated"
			case .studio:
				return Trans.studio
			case .country:
				return Trans.country
			case .language:
				let languages = show?.attributes.languages ?? []
				switch languages.count - 1 {
				case 0:
					return "Language"
				case 1:
					return "+1 More Language"
				default:
					return "+\(languages.count - 1) More Languages"
				}
			}
		}

		/// Returns the required primary image from the given object.
		///
		/// - Parameter show: The object used to extract the information from.
		///
		/// - Returns: the required primary image from the given object.
		func primaryImage(from show: Show? = nil) -> UIImage? {
			switch self {
			case .rating:
				return nil
			case .season:
				switch show?.attributes.airSeason?.lowercased() {
				case "spring":
					return UIImage(systemName: "leaf.fill")
				case "summer":
					return UIImage(systemName: "sun.max.fill")
				case "fall":
					return UIImage(systemName: "wind")
				default:
					return UIImage(systemName: "snowflake")
				}
			case .rank:
				return UIImage(systemName: "chart.bar.fill")
			case .tvRating:
				switch show?.attributes.tvRating.name.lowercased() {
				default:
					return UIImage(systemName: "tv.fill")
				}
			case .studio:
				return UIImage(systemName: "building.2.fill")
			case .country:
				return UIImage(systemName: "globe")
			case .language:
				return UIImage(systemName: "character.bubble.fill")
			}
		}
	}
}

// MARK: - Ratings
extension ShowDetail {
	/// List of available show rating types.
	enum Rating: Int, CaseIterable {
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
}

// MARK: - Rating & Review
extension ShowDetail {
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
}

// MARK: - Information
extension ShowDetail {
	/// List of available show information types.
	enum Information: Int, CaseIterable {
		case type = 0
		case source
		case genres
		case themes
		case episodes
		case duration
		case broadcast
		case airDates
		case rating
		case countryOfOrigin
		case languages
//		case studio
//		case network

		// MARK: - Properties
		/// The string value of an information type.
		var stringValue: String {
			switch self {
			case .type:
				return "Type"
			case .source:
				return "Source"
			case .genres:
				return "Genres"
			case .themes:
				return "Themes"
			case .episodes:
				return Trans.episodes
			case .duration:
				return Trans.duration
			case .broadcast:
				return "Broadcast"
			case .airDates:
				return Trans.aired
			case .rating:
				return Trans.rating
			case .countryOfOrigin:
				return "Country of Origin"
			case .languages:
				return "Languages"
//			case .studio:
//				return "Studio"
//			case .network:
//				return "Network"
			}
		}

		/// The image value of an information type.
		var imageValue: UIImage? {
			switch self {
			case .type:
				return UIImage(systemName: "tv.and.mediabox")
			case .source:
				return UIImage(systemName: "target")
			case .genres:
				return UIImage(systemName: "theatermasks")
			case .themes:
				return UIImage(systemName: "crown")
			case .episodes:
				return UIImage(systemName: "film")
			case .duration:
				return UIImage(systemName: "hourglass")
			case .broadcast:
				return UIImage(systemName: "calendar.badge.clock")
			case .airDates:
				return UIImage(systemName: "calendar")
			case .rating:
				return .Symbols.pgTv
			case .countryOfOrigin:
				return UIImage(systemName: "globe")
			case .languages:
				return UIImage(systemName: "character.bubble")
//			case .studio:
//				return UIImage(systemName: "building.2")
//			case .network:
//				return UIImage(systemName: "dot.radiowaves.left.and.right")
			}
		}

		/// The cell identifier string of a show information section.
		var identifierString: String {
			switch self {
			default:
				return InformationCollectionViewCell.reuseID
//			case .studio:
//				return InformationCollectionViewCell.reuseID
//			case .network:
//				return InformationCollectionViewCell.reuseID
			}
		}

		// MARK: - Functions
		/// Returns the required information from the given object.
		///
		/// - Parameter show: The object used to extract the information from.
		///
		/// - Returns: the required information from the given object.
		func information(from show: Show) -> String? {
			switch self {
			case .type:
				return show.attributes.type.name
			case .source:
				return "\(show.attributes.source.name)"
			case .genres:
				return show.attributes.genres?.localizedJoined() ?? "-"
			case .themes:
				return show.attributes.themes?.localizedJoined() ?? "-"
			case .episodes:
				return "\(show.attributes.episodeCount)"
			case .duration:
				return show.attributes.duration
			case .broadcast:
				return show.attributes.broadcastString ?? "-"
			case .airDates:
				guard let startedAt = show.attributes.startedAt?.appFormatted(date: .abbreviated, time: .omitted) else { return "-" }
				return "🚀 \(startedAt)"
			case .rating:
				return show.attributes.tvRating.name
			case .countryOfOrigin:
				return show.attributes.countryOfOrigin?.name ?? "Unknown"
			case .languages:
				let languages = show.attributes.languages.compactMap {
					$0.name
				}
				return languages.localizedJoined()
//			case .studio:
//				if let studios = show.relationships?.studios?.data, studios.count != 0 {
//					var studioNames = ""
//					for (index, studio) in studios.enumerated() {
//						let studioName = studio.attributes.name
//						if index == studios.count - 1 {
//							studioNames += "\(studioName)"
//							continue
//						}
//						studioNames += "\(studioName), "
//					}
//					return studioNames
//				}
//			case .network:
//				if let network = show.attributes.network {
//					return network
//				}
			}
		}

		/// Returns the required primary information from the given object.
		///
		/// - Parameter show: The object used to extract the information from.
		///
		/// - Returns: the required primary information from the given object.
		func primaryInformation(from show: Show) -> String? {
			switch self {
			case .broadcast:
				guard show.attributes.endedAt == nil else { return nil }
				guard let nextBroadcastAt = show.attributes.nextBroadcastAt else { return nil }
				return nextBroadcastAt.formatted(.relative(presentation: .named, unitsStyle: .abbreviated))
			default: return nil
			}
		}

		/// Returns the required secondary information from the given object.
		///
		/// - Parameter show: The object used to extract the information from.
		///
		/// - Returns: the required secondary information from the given object.
		func secondaryInformation(from show: Show) -> String? {
			switch self {
			case .airDates:
				if show.attributes.type.name == "Movie" {
					return self.information(from: show)
				}
				guard let endedAt = show.attributes.endedAt?.appFormatted(date: .abbreviated, time: .omitted) else { return nil }
				return "\(endedAt) 🏁"
			default: return nil
			}
		}

		/// Returns the required primary image from the given object.
		///
		/// - Parameter show: The object used to extract the information from.
		///
		/// - Returns: the required primary image from the given object.
		func primaryImage(from show: Show) -> UIImage? {
			switch self {
			case .airDates:
				guard self.secondaryInformation(from: show) != nil else { return nil }
                return .dottedLine
			default: return nil
			}
		}

		/// Returns the footnote from the given object.
		///
		/// - Parameter show: The object used to extract the footnote from.
		///
		/// - Returns: the footnote from the given object.
		func footnote(from show: Show) -> String? {
			switch self {
			case .type:
				return show.attributes.type.description
			case .source:
				return show.attributes.source.description
			case .genres, .themes:
				return nil
			case .episodes:
				let seasonCount = show.attributes.seasonCount <= 1 ? "one" : "\(show.attributes.seasonCount)"
				let seasonString = show.attributes.seasonCount > 1 ? Trans.seasons : Trans.season
				return "Across \(seasonCount) \(seasonString.lowercased())."
			case .duration:
				return "With a total of \(show.attributes.durationTotal)."
			case .broadcast:
				guard show.attributes.endedAt == nil else { return "The broadcasting of this series has ended." }
				guard show.attributes.nextBroadcastAt == nil else { return nil }
				return "No broadcast data available at the moment."
			case .airDates:
				guard self.secondaryInformation(from: show) == nil else { return nil }
				return show.attributes.status.description
			case .rating:
				return show.attributes.tvRating.description
			case .countryOfOrigin, .languages:
				return nil
//			case .studio:
//				if let studios = show.relationships?.studios?.data, studios.count != 0 {
//					var studioNames = ""
//					for (index, studio) in studios.enumerated() {
//						let studioName = studio.attributes.name
//						if index == studios.count - 1 {
//							studioNames += "\(studioName)"
//							continue
//						}
//						studioNames += "\(studioName), "
//					}
//					return studioNames
//				}
//			case .network:
//				if let network = show.attributes.network {
//					return network
//				}
			}
		}
	}
}

// MARK: - External Site
extension ShowDetail {
	/// List of available extenral sites.
	enum ExternalSite: Int, CaseIterable {
		case anidbID = 0
		case anilistID
		case imdbID
		case kitsuID
		case malID
		case notifyID
		case syoboiID
		case traktID
		case tvdbID

		// MARK: - Properties
		/// The string value of an external site.
		var stringValue: String {
			switch self {
			case .anidbID:
				return "AniDB"
			case .anilistID:
				return "AniList"
			case .imdbID:
				return "IMDB"
			case .kitsuID:
				return "Kitsu"
			case .malID:
				return "MyAnimeList"
			case .notifyID:
				return "Notify Moe"
			case .syoboiID:
				return "Syoboi"
			case .traktID:
				return "Trakt TV"
			case .tvdbID:
				return "TheTVDB"
			}
		}
	}
}
