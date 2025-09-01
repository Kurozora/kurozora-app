//
//  LiteratureDetail.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/02/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

struct LiteratureDetail { }

// MARK: - Badge
extension LiteratureDetail {
	/// List of available literature badge types.
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

		/// The cell identifier string of a literature badge section.
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
		/// - Parameter literature: The object used to extract the information from.
		///
		/// - Returns: the required primary information from the given object.
		func primaryInformation(from literature: Literature) -> String? {
			switch self {
			case .rating:
				return nil
			case .season:
				return literature.attributes.publicationSeason ?? "-"
			case .rank:
				let rank = literature.attributes.stats?.rankTotal ?? 0
				return rank > 0 ? "#\(rank)" : "-"
			case .tvRating:
				return literature.attributes.tvRating.name
			case .studio:
				return literature.attributes.studio ?? "-"
			case .country:
				return literature.attributes.countryOfOrigin?.code.uppercased() ?? "-"
			case .language:
				return literature.attributes.languages.first?.code.uppercased() ?? "-"
			}
		}

		/// Returns the required secondary information from the given object.
		///
		/// - Parameter literature: The object used to extract the information from.
		///
		/// - Returns: the required secondary information from the given object.
		func secondaryInformation(from literature: Literature? = nil) -> String? {
			switch self {
			case .rating:
				let ratingCount = literature?.attributes.stats?.ratingCount ?? 0
				return ratingCount != 0 ? "\(ratingCount.kkFormatted(precision: 0)) Ratings" : "Not enough ratings"
			case .season:
				return Trans.season
			case .rank:
				return Trans.chart // e.g. Thriller — literature.attributes.popularity.genre
			case .tvRating:
				return "Rated"
			case .studio:
				return Trans.studio
			case .country:
				return Trans.country
			case .language:
				let languages = literature?.attributes.languages ?? []
				switch languages.count - 1 {
				case 0:
					return Trans.language
				case 1:
					return "+1 More Language"
				default:
					return "+\(languages.count - 1) More Languages"
				}
			}
		}

		/// Returns the required primary image from the given object.
		///
		/// - Parameter literature: The object used to extract the information from.
		///
		/// - Returns: the required primary image from the given object.
		func primaryImage(from literature: Literature? = nil) -> UIImage? {
			switch self {
			case .rating:
				return nil
			case .season:
				switch literature?.attributes.publicationSeason?.lowercased() {
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
				switch literature?.attributes.tvRating.name.lowercased() {
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
extension LiteratureDetail {
	/// List of available literature rating types.
	enum Rating: Int, CaseIterable {
		case average = 0
		case sentiment
		case bar

		// MARK: - Properties
		/// The cell identifier string of a literature rating section.
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
extension LiteratureDetail {
	/// List of available literature rate & review types.
	enum RateAndReview: Int, CaseIterable {
		case tapToRate = 0
		case writeAReview

		// MARK: - Properties
		/// The cell identifier string of a literature rate & review section.
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
extension LiteratureDetail {
	/// List of available literature information types.
	enum Information: Int, CaseIterable {
		case type = 0
		case source
		case genres
		case themes
		case chapters
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
				return "Type"
			case .source:
				return "Source"
			case .genres:
				return "Genres"
			case .themes:
				return "Themes"
			case .chapters:
				return "Chapters"
			case .duration:
				return "Duration"
			case .publication:
				return "Publication"
			case .publicationDates:
				return "Published"
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
			case .chapters:
				return UIImage(systemName: "film")
			case .duration:
				return UIImage(systemName: "hourglass")
			case .publication:
				return UIImage(systemName: "calendar.badge.clock")
			case .publicationDates:
				return UIImage(systemName: "calendar")
			case .rating:
				return R.image.symbols.pgTv()
			case .countryOfOrigin:
				return UIImage(systemName: "globe")
			case .languages:
				return UIImage(systemName: "charcater.bubble")
//			case .studio:
//				return UIImage(systemName: "building.2")
//			case .network:
//				return UIImage(systemName: "dot.radiowaves.left.and.right")
			}
		}

		/// The cell identifier string of a literature information section.
		var identifierString: String {
			switch self {
			default:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			}
		}

		// MARK: - Functions
		/// Returns the required information from the given object.
		///
		/// - Parameter literature: The object used to extract the information from.
		///
		/// - Returns: the required information from the given object.
		func information(from literature: Literature) -> String? {
			switch self {
			case .type:
				return literature.attributes.type.name
			case .source:
				return "\(literature.attributes.source.name)"
			case .genres:
				return literature.attributes.genres?.localizedJoined() ?? "-"
			case .themes:
				return literature.attributes.themes?.localizedJoined() ?? "-"
			case .chapters:
				return "\(literature.attributes.chapterCount)"
			case .duration:
				return literature.attributes.duration
			case .publication:
				var publicationInfo = literature.attributes.publicationDay ?? "-"
				if let publicationTime = literature.attributes.publicationTime {
					publicationInfo += publicationTime.isEmpty ? "" : " at " + publicationTime + " UTC"
				}
				return publicationInfo
			case .publicationDates:
				guard let startedAt = literature.attributes.startedAt?.appFormatted(date: .abbreviated, time: .omitted) else { return "-" }
				return "🚀 \(startedAt)"
			case .rating:
				return literature.attributes.tvRating.name
			case .countryOfOrigin:
				return literature.attributes.countryOfOrigin?.name ?? "Unknown"
			case .languages:
				let languages = literature.attributes.languages.compactMap {
					$0.name
				}
				return languages.localizedJoined()
//			case .studio:
//				if let studios = literature.relationships?.studios?.data, studios.count != 0 {
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
//				if let network = literature.attributes.network {
//					return network
//				}
			}
		}

		/// Returns the required primary information from the given object.
		///
		/// - Parameter literature: The object used to extract the information from.
		///
		/// - Returns: the required primary information from the given object.
		func primaryInformation(from literature: Literature) -> String? {
			switch self {
			case .publication:
				guard literature.attributes.endedAt == nil else { return nil }
				guard let publicationDate = literature.attributes.publicationDate else { return nil }
				return publicationDate.formatted(.relative(presentation: .named, unitsStyle: .abbreviated))
			default: return nil
			}
		}

		/// Returns the required secondary information from the given object.
		///
		/// - Parameter literature: The object used to extract the information from.
		///
		/// - Returns: the required secondary information from the given object.
		func secondaryInformation(from literature: Literature) -> String? {
			switch self {
			case .publicationDates:
				if literature.attributes.type.name == "Movie" {
					return self.information(from: literature)
				}
				guard let endedAt = literature.attributes.endedAt?.appFormatted(date: .abbreviated, time: .omitted) else { return nil }
				return "\(endedAt) 🏁"
			default: return nil
			}
		}

		/// Returns the required primary image from the given object.
		///
		/// - Parameter literature: The object used to extract the information from.
		///
		/// - Returns: the required primary image from the given object.
		func primaryImage(from literature: Literature) -> UIImage? {
			switch self {
			case .publicationDates:
				guard self.secondaryInformation(from: literature) != nil else { return nil }
				return R.image.dotted_line()
			default: return nil
			}
		}

		/// Returns the footnote from the given object.
		///
		/// - Parameter literature: The object used to extract the footnote from.
		///
		/// - Returns: the footnote from the given object.
		func footnote(from literature: Literature) -> String? {
			switch self {
			case .type:
				return literature.attributes.type.description
			case .source:
				return literature.attributes.source.description
			case .genres, .themes:
				return nil
			case .chapters:
				let chapterCount = literature.attributes.volumeCount <= 1 ? "one" : "\(literature.attributes.volumeCount)"
				let volumeString = literature.attributes.volumeCount > 1 ? "volumes" : "volume"
				return "Across \(chapterCount) \(volumeString)."
			case .duration:
				return "With a total of \(literature.attributes.durationTotal)."
			case .publication:
				guard literature.attributes.endedAt == nil else { return "The publicationing of this series has ended." }
				guard literature.attributes.publicationDate == nil else { return nil }
				return "No publication data available at the moment."
			case .publicationDates:
				guard self.secondaryInformation(from: literature) == nil else { return nil }
				return literature.attributes.status.description
			case .rating:
				return literature.attributes.tvRating.description
			case .countryOfOrigin, .languages:
				return nil
//			case .studio:
//				if let studios = literature.relationships?.studios?.data, studios.count != 0 {
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
//				if let network = literature.attributes.network {
//					return network
//				}
			}
		}
	}
}

// MARK: - External Site
extension LiteratureDetail {
	/// List of available extenral sites.
	enum ExternalSite: Int, CaseIterable {
		case anidbID = 0
		case anilistID
		case kitsuID
		case malID

		// MARK: - Properties
		/// The string value of an external site.
		var stringValue: String {
			switch self {
			case .anidbID:
				return "AniDB"
			case .anilistID:
				return "AniList"
			case .kitsuID:
				return "Kitsu"
			case .malID:
				return "MyAnimeList"
			}
		}
	}
}
