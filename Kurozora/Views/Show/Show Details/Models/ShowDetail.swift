//
//  ShowDetail.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/04/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class ShowDetail {
	/**
		Set of available show section types.
	*/
	enum Section: Int, CaseIterable {
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

		/// The row count of a character section layout kind.
		var rowCount: Int {
			switch self {
			case .header:
				return 1
			case .badge:
				return 1
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
			The cell identifier string of a character section.

			- Parameter row: The row integer used to determine the cell reuse identifier.

			- Returns: The cell identifier string of a show details section.
		*/
		func identifierString(for row: Int = 0) -> String {
			switch self {
			case .header:
				return R.reuseIdentifier.showDetailHeaderCollectionViewCell.identifier
			case .badge:
				return R.reuseIdentifier.badgeCollectionViewCell.identifier
			case .synopsis:
				return R.reuseIdentifier.textViewCollectionViewCell.identifier
			case .rating:
				return R.reuseIdentifier.ratingCollectionViewCell.identifier
			case .information:
				return ShowDetail.Information(rawValue: row)?.identifierString ?? ShowDetail.Information.studio.identifierString
			case .seasons:
				return R.reuseIdentifier.lockupCollectionViewCell.identifier
			case .cast:
				return R.reuseIdentifier.castCollectionViewCell.identifier
			case .moreByStudio:
				return R.reuseIdentifier.smallLockupCollectionViewCell.identifier
			case .relatedShows:
				return R.reuseIdentifier.lockupCollectionViewCell.identifier
			case .sosumi:
				return R.reuseIdentifier.sosumiShowCollectionViewCell.identifier
			}
		}
	}

	/**
		List of airing status types.

		```
		case toBeAnnounced = "Tba"
		case currentlyAiring = "Continuing"
		case finishedAiring = "Ended"
		```
	*/
	enum AiringStatus: String {
		/// No airing date has been announced.
		case toBeAnnounced = "Tba"

		/// The show is currently airing its episodes.
		case currentlyAiring = "Continuing"

		/// The show finished airing all of its episodes.
		case finishedAiring = "Ended"

		// MARK: - Properties
		/// An array containing all airing status type.
		static let all: [AiringStatus] = [.toBeAnnounced, .finishedAiring, .currentlyAiring]

		/// The string value of an airing status type.
		var stringValue: String {
			switch self {
			case .toBeAnnounced:
				return "To Be Announced"
			case .currentlyAiring:
				return "Currently Airing"
			case .finishedAiring:
				return "Finished Airing"
			}
		}

		/// The color value of an airing status type.
		var colorValue: UIColor {
			switch self {
			case .toBeAnnounced:
				return .toBeAnnounced
			case .currentlyAiring:
				return .currentlyAiring
			case .finishedAiring:
				return .finishedAiring
			}
		}
	}

	/**
		List of available show information types.
	*/
	enum Information: Int, CaseIterable {
		case studio = 0
		case network
		case type
		case aireDates
		case broadcast
		case genres
		case rating
		case seasonCount
		case episodeCount
		case duration
//		case languages

		// MARK: - Properties
		/// The string value of an information type.
		var stringValue: String {
			switch self {
			case .studio:
				return "Studio"
			case .network:
				return "Network"
			case .type:
				return "Type"
			case .aireDates:
				return "Aired"
			case .broadcast:
				return "Broadcast"
			case .genres:
				return "Genres"
			case .rating:
				return "Rating"
			case .seasonCount:
				return "Seasons"
			case .episodeCount:
				return "Episodes"
			case .duration:
				return "Duration"
//			case .languages:
//				return "Languages"
			}
		}

		/// The cell identifier string of a character information section.
		var identifierString: String {
			switch self {
			case .studio:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			case .network:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			case .type:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			case .aireDates:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			case .broadcast:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			case .genres:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			case .rating:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			case .seasonCount:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			case .episodeCount:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			case .duration:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			}
		}

		// MARK: - Functions
		/**
			Returns the required information from the given object.

			- Parameter show: The object used to extract the infromation from.

			Returns: the required information from the given object.
		*/
		func information(from show: Show) -> String {
			switch self {
			case .studio:
				if let studios = show.relationships?.studios?.data, studios.count != 0 {
					var studioNames = ""
					for (index, studio) in studios.enumerated() {
						let studioName = studio.attributes.name
						if index == studios.count - 1 {
							studioNames += "\(studioName)"
							continue
						}
						studioNames += "\(studioName), "
					}
					return studioNames
				}
			case .network:
				if let network = show.attributes.network {
					return network
				}
			case .type:
				return show.attributes.type
			case .aireDates:
				var dateInfo: String = "-"

				let startDateTime = show.attributes.startDateTime
				dateInfo = (startDateTime?.mediumDate ?? "N/A") + " - "

				let endDateTime = show.attributes.endDateTime
				dateInfo += (endDateTime?.mediumDate ?? "N/A")

				return dateInfo
			case .broadcast:
				var broadcastInfo = show.attributes.airDay ?? "-"
				if let airTime = show.attributes.airTime {
					broadcastInfo += airTime.isEmpty ? "" : " at " + airTime
				}
				return broadcastInfo
			case .genres:
				if let genres = show.relationships?.genres?.data, genres.count != 0 {
					var genreNames = ""
					for (index, genre) in genres.enumerated() {
						let genreName = genre.attributes.name
						if index == genres.count - 1 {
							genreNames += "\(genreName)"
							continue
						}
						genreNames += "\(genreName), "
					}
					return genreNames
				}
			case .rating:
				let watchRating = show.attributes.watchRating
				if !watchRating.isEmpty {
					return watchRating
				}
			case .seasonCount:
				let seasonCount = show.attributes.seasonCount
				if seasonCount > 0 {
					return "\(seasonCount)"
				}
			case .episodeCount:
				let episodeCount = show.attributes.episodeCount
				if episodeCount > 0 {
					return "\(episodeCount)"
				}
			case .duration:
				let duration = show.attributes.runtime
				if duration > 0 {
					return "\(duration) min"
				}
			}
			return "-"
		}
	}

	/**
		List of available extenral sites.
	*/
	enum ExternalSite: Int, CaseIterable {
		case aniDB = 0
		case aniList
		case imdb
		case kitsu
		case mal
		case tvdb

		// MARK: - Properties
		/// The string value of an external site.
		var stringValue: String {
			switch self {
			case .aniDB:
				return "AniDB"
			case .aniList:
				return "AniList"
			case .imdb:
				return "IMDB"
			case .kitsu:
				return "Kitsu"
			case .mal:
				return "MyAnimeList"
			case .tvdb:
				return "TheTVDB"
			}
		}
	}
	//	enum AiringStatus: Int {
	//		/// No airing date has been announced.
	//		case toBeAnnounced = 0
	//
	//		/// The show is currently airing its episodes.
	//		case currentlyAiring = 1
	//
	//		/// The show finished airing all of its episodes.
	//		case finishedAiring = 2
	//
	//		/// An array containing all airing status.
	//		static let all: [AiringStatus] = [.toBeAnnounced, .finishedAiring, .currentlyAiring]
	//
	//		/// The string value of an airing status.
	//		var stringValue: String {
	//			switch self {
	//			case .toBeAnnounced:
	//				return "To Be Announced"
	//			case .currentlyAiring:
	//				return "Currently Airing"
	//			case .finishedAiring:
	//				return "Finished Airing"
	//			default:
	//				return "To Be Announced"
	//			}
	//		}
	//
	//		/// The color value of an airing status.
	//		var colorValue: UIColor {
	//			switch self {
	//			case .toBeAnnounced:
	//				return .toBeAnnounced
	//			case .currentlyAiring:
	//				return .currentlyAiring
	//			case .finishedAiring:
	//				return .finishedAiring
	//			}
	//		}
	//	}
}
