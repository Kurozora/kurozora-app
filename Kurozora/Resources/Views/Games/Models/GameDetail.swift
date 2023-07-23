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
			case .language:
				return Trans.language
			}
		}

		/// The cell identifier string of a game badge section.
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
		/// - Parameter game: The object used to extract the infromation from.
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
			case .language:
				return game.attributes.languages.first?.attributes.code.uppercased()
			}
		}

		/// Returns the required secondary information from the given object.
		///
		/// - Parameter game: The object used to extract the infromation from.
		///
		/// - Returns: the required secondary information from the given object.
		func secondaryInformation(from game: Game? = nil) -> String? {
			switch self {
			case .rating:
				let ratingCount = game?.attributes.stats?.ratingCount ?? 0
				return ratingCount != 0 ? "\(ratingCount.kkFormatted) Ratings" : "Not enough ratings"
			case .season:
				return "Season"
			case .rank:
				return "Chart" // e.g. Thriller — game.attributes.popularity.genre
			case .tvRating:
				return "Rated"
			case .studio:
				return "Studio"
			case .language:
				let languages = game?.attributes.languages ?? []
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
		/// - Parameter game: The object used to extract the infromation from.
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
		case bar

		// MARK: - Properties
		/// The cell identifier string of a game rating section.
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
			case .editions:
				return "Editions"
			case .duration:
				return "Duration"
			case .publication:
				return "Publication"
			case .publicationDates:
				return "Published"
			case .rating:
				return "Rating"
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
			case .editions:
				return UIImage(systemName: "film")
			case .duration:
				return UIImage(systemName: "hourglass")
			case .publication:
				return UIImage(systemName: "calendar.badge.clock")
			case .publicationDates:
				return UIImage(systemName: "calendar")
			case .rating:
				return R.image.symbols.pgTv()
			case .languages:
				return UIImage(systemName: "globe")
//			case .studio:
//				return UIImage(systemName: "building.2")
//			case .network:
//				return UIImage(systemName: "dot.radiowaves.left.and.right")
			}
		}

		/// The cell identifier string of a game information section.
		var identifierString: String {
			switch self {
			case .type:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			case .source:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			case .genres:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			case .themes:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			case .editions:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			case .duration:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			case .publication:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			case .publicationDates:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			case .rating:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			case .languages:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
//			case .studio:
//				return R.reuseIdentifier.informationCollectionViewCell.identifier
//			case .network:
//				return R.reuseIdentifier.informationCollectionViewCell.identifier
			}
		}

		// MARK: - Functions
		/// Returns the required information from the given object.
		///
		/// - Parameter game: The object used to extract the infromation from.
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
				var publicationInfo = game.attributes.publicationDay ?? "-"
				if let publicationTime = game.attributes.publicationTime {
					publicationInfo += publicationTime.isEmpty ? "" : " at " + publicationTime + " UTC"
				}
				return publicationInfo
			case .publicationDates:
				guard let startedAt = game.attributes.startedAt?.formatted(date: .abbreviated, time: .omitted) else { return "-" }
				return "🚀 \(startedAt)"
			case .rating:
				return game.attributes.tvRating.name
			case .languages:
				let languages = game.attributes.languages.compactMap {
					$0.attributes.name
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
		/// - Parameter game: The object used to extract the infromation from.
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
		/// - Parameter game: The object used to extract the infromation from.
		///
		/// - Returns: the required secondary information from the given object.
		func secondaryInformation(from game: Game) -> String? {
			switch self {
			case .publicationDates:
				if game.attributes.type.name == "Movie" {
					return self.information(from: game)
				}
				guard let endedAt = game.attributes.endedAt?.formatted(date: .abbreviated, time: .omitted) else { return nil }
				return "\(endedAt) 🏁"
			default: return nil
			}
		}

		/// Returns the required primary image from the given object.
		///
		/// - Parameter game: The object used to extract the infromation from.
		///
		/// - Returns: the required primary image from the given object.
		func primaryImage(from game: Game) -> UIImage? {
			switch self {
			case .publicationDates:
				guard self.secondaryInformation(from: game) != nil else { return nil }
				return R.image.dotted_line()
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
			case .genres:
				return nil
			case .themes:
				return nil
			case .editions:
				let editionCount = game.attributes.editionCount <= 1 ? "one" : "\(game.attributes.editionCount)"
				let editionString = game.attributes.editionCount > 1 ? "editions" : "edition"
				return "Across \(editionCount) \(editionString)."
			case .duration:
				return "With a total of \(game.attributes.durationTotal)."
			case .publication:
				guard game.attributes.endedAt == nil else { return "The publicationing of this series has ended." }
				guard game.attributes.publicationDate == nil else { return nil }
				return "No publication data available at the moment."
			case .publicationDates:
				guard self.secondaryInformation(from: game) == nil else { return nil }
				return game.attributes.status.description
			case .rating:
				return game.attributes.tvRating.description
			case .languages:
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
