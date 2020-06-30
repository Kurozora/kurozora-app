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
		case related
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
			case .related:
				return "Related"
			case .sosumi:
				return "Copyright"
			}
		}

		/// The cell identifier string of a show section type.
		var identifierString: String {
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
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			case .seasons:
				return R.reuseIdentifier.lockupCollectionViewCell.identifier
			case .cast:
				return R.reuseIdentifier.castCollectionViewCell.identifier
			case .moreByStudio:
				return R.reuseIdentifier.smallLockupCollectionViewCell.identifier
			case .related:
				return "RelatedShowCollectionViewCell" // R.reuseIdentifier.relatedShowCollectionViewCell.identifier
			case .sosumi:
				return R.reuseIdentifier.sosumiShowCollectionViewCell.identifier
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
				return R.segue.showDetailCollectionViewController.seasonSegue.identifier
			case .cast:
				return R.segue.showDetailCollectionViewController.castSegue.identifier
			case .moreByStudio:
				return R.segue.showDetailCollectionViewController.studioSegue.identifier
			case .related:
				return "RelatedSegue" //R.segue.showDetailCollectionViewController.relatedSegue.identifier
			case .sosumi:
				return ""
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
		case id = 0
		case studio
		case network
		case type
		case aireDates
		case broadcast
		case genres
		case rating
		case seasonsCount
		case episodesCount
		case duration
		case languages

		// MARK: - Properties
		/// The string value of an information type.
		var stringValue: String {
			switch self {
			case .id:
				return "ID"
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
			case .seasonsCount:
				return "Seasons"
			case .episodesCount:
				return "Episodes"
			case .duration:
				return "Duration"
			case .languages:
				return "Languages"
			}
		}

		// MARK: - Functions
		/**
			Returns the required information from the given object.

			- Parameter showDetailselement: The object used to extract the infromation from.

			Returns: the required information from the given object.
		*/
		func information(from showDetailsElement: ShowDetailsElement) -> String {
			switch self {
			case .id:
				if let showID = showDetailsElement.id {
					return showID.string
				}
			case .studio:
				if let studioName = showDetailsElement.studio?.name, !studioName.isEmpty {
					return studioName
				}
			case .network:
				if let network = showDetailsElement.network, !network.isEmpty {
					return network
				}
			case .type:
				if let type = showDetailsElement.type, !type.isEmpty {
					return type
				}
			case .aireDates:
				var dateInfo: String = "-"
				if let startDateTime = showDetailsElement.startDateTime {
					dateInfo = startDateTime.isEmpty ? "N/A - " : startDateTime.mediumDate + " - "
				}
				if let endDateTime = showDetailsElement.endDateTime {
					dateInfo += endDateTime.isEmpty ? "N/A" : endDateTime.mediumDate
				}
				return dateInfo
			case .broadcast:
				var broadcastInfo: String = "-"
				if let airDay = showDetailsElement.airDay {
					broadcastInfo = Calendar.current.weekdaySymbols[airDay]
				}
				if let airTime = showDetailsElement.airTime {
					broadcastInfo += airTime.isEmpty ? "-" : " at " + airTime
				}
				return broadcastInfo
			case .genres:
				if let genres = showDetailsElement.genres, !genres.isEmpty {
					var genreText = ""
					for (index, genre) in genres.enumerated() {
						if let genreName = genre.name {
							if index == genres.count - 1 {
								genreText += "\(genreName)"
								continue
							}
							genreText += "\(genreName), "
						}
					}
					return genreText
				}
			case .rating:
				if let watchRating = showDetailsElement.watchRating, !watchRating.isEmpty {
					return watchRating
				}
			case .seasonsCount:
				if let seasons = showDetailsElement.seasons, seasons > 0 {
					return seasons.description
				}
			case .episodesCount:
				if let episode = showDetailsElement.episodes, episode > 0 {
					return episode.description
				}
			case .duration:
				if let duration = showDetailsElement.runtime, duration > 0 {
					return "\(duration) min"
				}
			case .languages:
				if let languages = showDetailsElement.languages, !languages.isEmpty {
					return languages
				}
			}
			return "-"
		}
	}

	/**
		List of extenral sites.

		```
		case aniDB = 0
		case aniList = 1
		case imdb = 2
		case kitsu = 3
		case mal = 4
		case tvdb = 5
		```
	*/
	enum ExternalSite: Int, CaseIterable {
		case aniDB = 0
		case aniList = 1
		case imdb = 2
		case kitsu = 3
		case mal = 4
		case tvdb = 5

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
