//
//  GameDetail.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/03/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

struct GameDetail { }

// MARK: - Badge
extension GameDetail {
	/// List of available game badge types.
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
				return L10n.rating
			case .season:
				return L10n.season
			case .rank:
				return L10n.rank
			case .tvRating:
				return L10n.tvRating
			case .studio:
				return L10n.studio
			case .country:
				return L10n.country
			case .language:
				return L10n.language
			}
		}

		/// The cell identifier string of a game badge section.
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
		/// - Parameter game: The object used to extract the information from.
		///
		/// - Returns: the required primary information from the given object.
		func primaryInformation(from game: Game) -> String? {
			switch self {
			case .rating:
				return nil
			case .season:
				return game.attributes.publicationSeason ?? "-"
			case .rank:
				let rank = game.attributes.stats?.rankTotal ?? 0
				return rank > 0 ? "#\(rank)" : "-"
			case .tvRating:
				return game.attributes.tvRating.name
			case .studio:
				return game.attributes.studio ?? "-"
			case .country:
				return game.attributes.countryOfOrigin?.code.uppercased() ?? "-"
			case .language:
				return game.attributes.languages.first?.code.uppercased() ?? "-"
			}
		}

		/// Returns the required secondary information from the given object.
		///
		/// - Parameter game: The object used to extract the information from.
		///
		/// - Returns: the required secondary information from the given object.
		func secondaryInformation(from game: Game? = nil) -> String? {
			switch self {
			case .rating:
				let ratingCount = game?.attributes.stats?.ratingCount ?? 0
				return ratingCount != 0 ? L10n.ratingsCount(ratingCount.kkFormatted(precision: 0), count: ratingCount) : L10n.notEnoughRatings
			case .season:
				if let publicationYear = game?.attributes.startedAt?.components.year, game?.attributes.publicationSeason != nil {
					return "\(publicationYear)"
				}
				return L10n.season
			case .rank:
				return L10n.chart // e.g. Thriller — game.attributes.popularity.genre
			case .tvRating:
				return L10n.rated
			case .studio:
				return L10n.studio
			case .country:
				return L10n.country
			case .language:
				let languages = game?.attributes.languages ?? []
				switch languages.count - 1 {
				case 0:
					return L10n.language
				case 1:
					return L10n.oneMoreLanguage
				default:
					return L10n.moreLanguages(languages.count - 1)
				}
			}
		}

		/// Returns the required primary image from the given object.
		///
		/// - Parameter game: The object used to extract the information from.
		///
		/// - Returns: the required primary image from the given object.
		func primaryImage(from game: Game? = nil) -> UIImage? {
			switch self {
			case .rating:
				return nil
			case .season:
				switch game?.attributes.publicationSeason?.lowercased() {
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
				switch game?.attributes.tvRating.name.lowercased() {
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
extension GameDetail {
	/// List of available game rating types.
	enum Rating: Int, CaseIterable {
		case average = 0
		case sentiment
		case favoriteShare
		case bar

		// MARK: - Properties
		/// The cell identifier string of a game rating section.
		var identifierString: String {
			switch self {
			case .average:
				return RatingCollectionViewCell.reuseID
			case .sentiment, .favoriteShare:
				return RatingSentimentCollectionViewCell.reuseID
			case .bar:
				return RatingBarCollectionViewCell.reuseID
			}
		}
	}
}

// MARK: - Rating & Review
extension GameDetail {
	/// List of available game rate & review types.
	enum RateAndReview: Int, CaseIterable {
		case tapToRate = 0
		case writeAReview

		// MARK: - Properties
		/// The cell identifier string of a game rate & review section.
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
extension GameDetail {
	/// List of available game information types.
	enum Information: Int, CaseIterable {
		case type = 0
		case source
		case genres
		case themes
		case editions
		case duration
		case publication
		case publicationDates
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
				return L10n.columnType
			case .source:
				return L10n.source
			case .genres:
				return L10n.genres
			case .themes:
				return L10n.themes
			case .editions:
				return L10n.columnEditions
			case .duration:
				return L10n.duration
			case .publication:
				return L10n.publication
			case .publicationDates:
				return L10n.published
			case .rating:
				return L10n.rating
			case .countryOfOrigin:
				return L10n.countryOfOrigin
			case .languages:
				return L10n.language
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
			case .editions:
				return UIImage(systemName: "film")
			case .duration:
				return UIImage(systemName: "hourglass")
			case .publication:
				return UIImage(systemName: "calendar.badge.clock")
			case .publicationDates:
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

		/// The cell identifier string of a game information section.
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
		/// - Parameter game: The object used to extract the information from.
		///
		/// - Returns: the required information from the given object.
		func information(from game: Game) -> String? {
			switch self {
			case .type:
				return game.attributes.type.name
			case .source:
				return "\(game.attributes.source.name)"
			case .genres:
				return game.attributes.genres?.localizedJoined() ?? "-"
			case .themes:
				return game.attributes.themes?.localizedJoined() ?? "-"
			case .editions:
				return "\(game.attributes.editionCount)"
			case .duration:
				return game.attributes.duration
			case .publication:
				return game.attributes.publicationString ?? "-"
			case .publicationDates:
				guard let startedAt = game.attributes.startedAt?.appFormatted(date: .abbreviated, time: .omitted) else { return "-" }
				return "🚀 \(startedAt)"
			case .rating:
				return game.attributes.tvRating.name
			case .countryOfOrigin:
				return game.attributes.countryOfOrigin?.name ?? L10n.unknown
			case .languages:
				let languages = game.attributes.languages.compactMap {
					$0.name
				}
				return languages.localizedJoined()
//			case .studio:
//				if let studios = game.relationships?.studios?.data, studios.count != 0 {
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
//				if let network = game.attributes.network {
//					return network
//				}
			}
		}

		/// Returns the required primary information from the given object.
		///
		/// - Parameter game: The object used to extract the information from.
		///
		/// - Returns: the required primary information from the given object.
		func primaryInformation(from game: Game) -> String? {
			switch self {
			case .publication:
				guard game.attributes.endedAt == nil else { return nil }
				guard let publicationDate = game.attributes.publicationDate else { return nil }
				return publicationDate.formatted(.relative(presentation: .named, unitsStyle: .abbreviated))
			default: return nil
			}
		}

		/// Returns the required secondary information from the given object.
		///
		/// - Parameter game: The object used to extract the information from.
		///
		/// - Returns: the required secondary information from the given object.
		func secondaryInformation(from game: Game) -> String? {
			switch self {
			case .publicationDates:
				if game.attributes.type.name == "Movie" {
					return self.information(from: game)
				}
				guard let endedAt = game.attributes.endedAt?.appFormatted(date: .abbreviated, time: .omitted) else { return nil }
				return "\(endedAt) 🏁"
			default: return nil
			}
		}

		/// Returns the required primary image from the given object.
		///
		/// - Parameter game: The object used to extract the information from.
		///
		/// - Returns: the required primary image from the given object.
		func primaryImage(from game: Game) -> UIImage? {
			switch self {
			case .publicationDates:
				guard self.secondaryInformation(from: game) != nil else { return nil }
				return .lineDashed
			default: return nil
			}
		}

		/// Returns the footnote from the given object.
		///
		/// - Parameter game: The object used to extract the footnote from.
		///
		/// - Returns: the footnote from the given object.
		func footnote(from game: Game) -> String? {
			switch self {
			case .type:
				return game.attributes.type.description
			case .source:
				return game.attributes.source.description
			case .genres, .themes:
				return nil
			case .editions:
				let editionCount = game.attributes.editionCount <= 1 ? L10n.one : "\(game.attributes.editionCount)"
				let editionString = game.attributes.editionCount > 1 ? L10n.columnEditions.lowercased(with: .current) : L10n.edition.lowercased(with: .current)
				return L10n.across("\(editionCount) \(editionString)")
			case .duration:
				return L10n.withTotalOf(game.attributes.durationTotal)
			case .publication:
				guard game.attributes.endedAt == nil else { return L10n.publicationEnded }
				guard game.attributes.publicationDate == nil else { return nil }
				return L10n.noPublicationData
			case .publicationDates:
				guard self.secondaryInformation(from: game) == nil else { return nil }
				return game.attributes.status.description
			case .rating:
				return game.attributes.tvRating.description
			case .countryOfOrigin, .languages:
				return nil
//			case .studio:
//				if let studios = game.relationships?.studios?.data, studios.count != 0 {
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
//				if let network = game.attributes.network {
//					return network
//				}
			}
		}
	}
}

// MARK: - External Site
extension GameDetail {
	/// List of available extenral sites.
	enum ExternalSite: Int, CaseIterable {
		case igdbID = 0

		// MARK: - Properties
		/// The string value of an external site.
		var stringValue: String {
			switch self {
			case .igdbID:
				return "IGDB"
			}
		}
	}
}
