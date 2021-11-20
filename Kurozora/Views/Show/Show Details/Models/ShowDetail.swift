//
//  ShowDetail.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/04/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

struct ShowDetail {
	/**
		List of available show section types.
	*/
	enum Section: Int, CaseIterable {
		// MARK: - Cases
		case header = 0
		case badge
		case synopsis
		case rating
		case information
		case seasons
		case cast
		case moreByStudio
		case relatedShows
		case sosumi

		// MARK: - Properties
		/// The string value of a show section type.
		var stringValue: String {
			switch self {
			case .header:
				return "Header"
			case .badge:
				return "Badges"
			case .synopsis:
				return "Synopsis"
			case .rating:
				return "Ratings"
			case .information:
				return "Information"
			case .seasons:
				return "Seasons"
			case .cast:
				return "Cast"
			case .moreByStudio:
				return "More by "
			case .relatedShows:
				return "Related"
			case .sosumi:
				return "Copyright"
			}
		}

		/// The row count of a  show section type.
		var rowCount: Int {
			switch self {
			case .header:
				return 1
			case .badge:
				return ShowDetail.Badge.allCases.count
			case .synopsis:
				return 1
			case .rating:
				return 1
			case .information:
				return ShowDetail.Information.allCases.count
			case .seasons:
				return 0
			case .cast:
				return 0
			case .moreByStudio:
				return 0
			case .relatedShows:
				return 0
			case .sosumi:
				return 1
			}
		}

		/// The string value of a show section type segue identifier.
		var segueIdentifier: String {
			switch self {
			case .header:
				return ""
			case .badge:
				return ""
			case .synopsis:
				return ""
			case .rating:
				return ""
			case .information:
				return ""
			case .seasons:
				return R.segue.showDetailsCollectionViewController.seasonSegue.identifier
			case .cast:
				return R.segue.showDetailsCollectionViewController.castSegue.identifier
			case .moreByStudio:
				return R.segue.showDetailsCollectionViewController.studioSegue.identifier
			case .relatedShows:
				return R.segue.showDetailsCollectionViewController.showsListSegue.identifier
			case .sosumi:
				return ""
			}
		}

		// MARK: - Functions
		/**
			The cell identifier string of a show section.

			- Parameter row: The row integer used to determine the cell reuse identifier.

			- Returns: The cell identifier string of a show section.
		*/
		func identifierString(for row: Int = 0) -> String {
			switch self {
			case .header:
				return R.reuseIdentifier.showDetailHeaderCollectionViewCell.identifier
			case .badge:
				return ShowDetail.Badge(rawValue: row)?.identifierString ?? ShowDetail.Badge.season.identifierString
			case .synopsis:
				return R.reuseIdentifier.textViewCollectionViewCell.identifier
			case .rating:
				return R.reuseIdentifier.ratingCollectionViewCell.identifier
			case .information:
				return ShowDetail.Information(rawValue: row)?.identifierString ?? ShowDetail.Information.type.identifierString
			case .seasons:
				return R.reuseIdentifier.posterLockupCollectionViewCell.identifier
			case .cast:
				return R.reuseIdentifier.castCollectionViewCell.identifier
			case .moreByStudio:
				return R.reuseIdentifier.smallLockupCollectionViewCell.identifier
			case .relatedShows:
				return R.reuseIdentifier.smallLockupCollectionViewCell.identifier
			case .sosumi:
				return R.reuseIdentifier.sosumiShowCollectionViewCell.identifier
			}
		}
	}
}

// MARK: - Badge
extension ShowDetail {
	/**
		List of available show badge types.
	*/
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
				return "Rating"
			case .season:
				return "Season"
			case .rank:
				return "Rank"
			case .tvRating:
				return "TV Rating"
			case .studio:
				return "Studio"
			case .language:
				return "Language"
			}
		}

		/// The cell identifier string of a character information section.
		var identifierString: String {
			switch self {
			case .rating:
				return R.reuseIdentifier.ratingBadgeCollectionViewCell.identifier
			default:
				return R.reuseIdentifier.badgeCollectionViewCell.identifier
			}
		}

		// MARK: - Functions
		/**
			Returns the required primary information from the given object.

			- Parameter show: The object used to extract the infromation from.

			- Returns: the required primary information from the given object.
		*/
		func primaryInformation(from show: Show) -> String? {
			switch self {
			case .rating:
				return nil
			case .season:
				return show.attributes.airSeason ?? "-"
			case .rank:
				return "#13" // show.attributes.popularity.rank
			case .tvRating:
				return show.attributes.tvRating.name
			case .studio:
				return show.relationships?.studios?.data.first { studio in
					studio.attributes.isStudio ?? false
				}?.attributes.name ?? show.relationships?.studios?.data.first?.attributes.name ?? "-"
			case .language:
				return show.attributes.languages.first?.attributes.code.uppercased()
			}
		}

		/**
			Returns the required secondary information from the given object.

			- Parameter show: The object used to extract the infromation from.

			- Returns: the required secondary information from the given object.
		*/
		func secondaryInformation(from show: Show) -> String? {
			switch self {
			case .rating:
				let ratingAverage = show.attributes.stats.ratingAverage
				let ratingCount = show.attributes.stats.ratingCount
				return ratingAverage >= 0.00 ? "Not enough ratings" : "\(ratingCount) Ratings"
			case .season:
				return "Season"
			case .rank:
				return "Thriller" // show.attributes.popularity.genre
			case .tvRating:
				return "Rated"
			case .studio:
				return "Studio"
			case .language:
				let languages = show.attributes.languages
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
	}
}

// MARK: - Information
extension ShowDetail {
	/**
		List of available show information types.
	*/
	enum Information: Int, CaseIterable {
//		case studio = 0
//		case network
		case type = 0
		case source
		case genres
		case episodes
		case duration
		case broadcast
		case airDates
		case rating
		case languages

		// MARK: - Properties
		/// The string value of an information type.
		var stringValue: String {
			switch self {
//			case .studio:
//				return "Studio"
//			case .network:
//				return "Network"
			case .type:
				return "Type"
			case .source:
				return "Source"
			case .genres:
				return "Genres"
			case .episodes:
				return "Episodes"
			case .duration:
				return "Duration"
			case .broadcast:
				return "Broadcast"
			case .airDates:
				return "Aired"
			case .rating:
				return "Rating"
			case .languages:
				return "Languages"
			}
		}

		/// The image value of an information type.
		var imageValue: UIImage? {
			switch self {
//			case .studio:
//				return UIImage(systemName: "building.2")
//			case .network:
//				return UIImage(systemName: "dot.radiowaves.left.and.right")
			case .type:
				return UIImage(systemName: "tv.and.mediabox")
			case .source:
				return UIImage(systemName: "target")
			case .genres:
				return UIImage(systemName: "theatermasks")
			case .episodes:
				return UIImage(systemName: "film")
			case .duration:
				return UIImage(systemName: "hourglass")
			case .broadcast:
				return UIImage(systemName: "calendar.badge.clock")
			case .airDates:
				return UIImage(systemName: "calendar")
			case .rating:
				return R.image.symbols.pgTv()
			case .languages:
				return UIImage(systemName: "globe")
			}
		}

		/// The cell identifier string of a character information section.
		var identifierString: String {
			switch self {
//			case .studio:
//				return R.reuseIdentifier.informationCollectionViewCell.identifier
//			case .network:
//				return R.reuseIdentifier.informationCollectionViewCell.identifier
			case .type:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			case .source:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			case .genres:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			case .episodes:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			case .duration:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			case .broadcast:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			case .airDates:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			case .rating:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			case .languages:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			}
		}

		// MARK: - Functions
		/**
			Returns the required information from the given object.

			- Parameter show: The object used to extract the infromation from.

			- Returns: the required information from the given object.
		*/
		func information(from show: Show) -> String? {
			switch self {
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
			case .type:
				return show.attributes.type.name
			case .source:
				return "\(show.attributes.source.name)"
			case .genres:
				return show.attributes.genres?.localizedJoined() ?? "-"
			case .episodes:
				return "\(show.attributes.episodeCount)"
			case .duration:
				return show.attributes.duration
			case .broadcast:
				var broadcastInfo = show.attributes.airDay ?? "-"
				if let airTime = show.attributes.airTime {
					broadcastInfo += airTime.isEmpty ? "" : " at " + airTime + " UTC"
				}
				return broadcastInfo
			case .airDates:
				guard let firstAired = show.attributes.firstAired?.formatted(date: .abbreviated, time: .omitted) else { return "-" }
				return "🚀 \(firstAired)"
			case .rating:
				return show.attributes.tvRating.name
			case .languages:
				let languages = show.attributes.languages.compactMap {
					$0.attributes.name
				}
				return languages.localizedJoined()
			}
		}

		/**
			Returns the required primary information from the given object.

			- Parameter show: The object used to extract the infromation from.

			- Returns: the required primary information from the given object.
		*/
		func primaryInformation(from show: Show) -> String? {
			switch self {
			case .broadcast:
				guard show.attributes.lastAired == nil else { return nil }
				guard let broadcastDate = show.attributes.broadcastDate else { return nil }
				return broadcastDate.formatted(.relative(presentation: .named, unitsStyle: .abbreviated))
			default: return nil
			}
		}

		/**
			Returns the required secondary information from the given object.

			- Parameter show: The object used to extract the infromation from.

			- Returns: the required secondary information from the given object.
		*/
		func secondaryInformation(from show: Show) -> String? {
			switch self {
			case .airDates:
				if show.attributes.type.name == "Movie" {
					return self.information(from: show)
				}
				guard let lastAired = show.attributes.lastAired?.formatted(date: .abbreviated, time: .omitted) else { return nil }
				return "\(lastAired) 🏁"
			default: return nil
			}
		}

		/**
			Returns the required primary image from the given object.

			- Parameter show: The object used to extract the infromation from.

			- Returns: the required primary image from the given object.
		*/
		func primaryImage(from show: Show) -> UIImage? {
			switch self {
			case .airDates:
				guard self.secondaryInformation(from: show) != nil else { return nil }
				return R.image.dotted_line()
			default: return nil
			}
		}

		/**
			Returns the footnote from the given object.

			- Parameter show: The object used to extract the footnote from.

			- Returns: the footnote from the given object.
		*/
		func footnote(from show: Show) -> String? {
			switch self {
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
			case .type:
				return show.attributes.type.description
			case .source:
				return show.attributes.source.description
			case .genres:
				return nil
			case .episodes:
				let episodeCount = show.attributes.seasonCount <= 1 ? "one" : "\(show.attributes.seasonCount)"
				let seasonString = show.attributes.seasonCount > 1 ? "seasons" : "season"
				return "Across \(episodeCount) \(seasonString)."
			case .duration:
				return "With a total of \(show.attributes.durationTotal)."
			case .broadcast:
				guard show.attributes.lastAired == nil else { return "The broadcasting of this series has ended." }
				guard show.attributes.broadcastDate == nil else { return nil }
				return "No broadcast data available at the moment."
			case .airDates:
				guard self.secondaryInformation(from: show) == nil else { return nil }
				return show.attributes.status.description
			case .rating:
				return show.attributes.tvRating.description
			case .languages:
				return nil
			}
		}
	}
}

// MARK: - External Site
extension ShowDetail {
	/**
		List of available extenral sites.
	*/
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
