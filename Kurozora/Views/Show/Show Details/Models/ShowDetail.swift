//
//  ShowDetail.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/04/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class ShowDetail {
	/**
		List of show sections.

		```
		case header = 0
		case badge = 1
		case synopsis = 2
		case rating = 3
		case information = 4
		case seasons = 5
		case cast = 6
		case related = 7
		```
	*/
	enum Section: Int {
		case header = 0
		case badge = 1
		case synopsis = 2
		case rating = 3
		case information = 4
		case seasons = 5
		case cast = 6
		case related = 7

		// MARK: - Properties
		/// An array containing all show sections.
		static let all: [Section] = [.header, .badge, .synopsis, .rating, .information, .seasons, .cast, .related]

		/// The string value of a show section.
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
			case .related:
				return "Related"
			}
		}

		/// The cell identifier string of a show section.
		var identifierString: String {
			switch self {
			case .header:
				return R.reuseIdentifier.showDetailHeaderCollectionViewCell.identifier
			case .badge:
				return R.reuseIdentifier.badgeCollectionViewCell.identifier
			case .synopsis:
				return R.reuseIdentifier.synopsisCollectionViewCell.identifier
			case .rating:
				return R.reuseIdentifier.ratingCollectionViewCell.identifier
			case .information:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			case .seasons:
				return R.reuseIdentifier.lockupCollectionViewCell.identifier
			case .cast:
				return R.reuseIdentifier.castCollectionViewCell.identifier
			case .related:
				return "RelatedShowCollectionViewCell" // R.reuseIdentifier.relatedShowCollectionViewCell.identifier
			}
		}

		/// The string value of a show section segue identifier.
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
			case .related:
				return "RelatedSegue" //R.segue.showDetailCollectionViewController.relatedSegue.identifier
			}
		}
	}

	/**
		List of airing status.

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
		/// An array containing all airing status.
		static let all: [AiringStatus] = [.toBeAnnounced, .finishedAiring, .currentlyAiring]

		/// The string value of an airing status.
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

		/// The color value of an airing status.
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
		List of informations.

		```
		case id = 0
		case type = 1
		case seasonsCount = 2
		case episodesCount = 3
		case aireDates = 4
		case network = 5
		case duration = 6
		case rating = 7
		case languages = 8
		case genres = 9
		```
	*/
	enum Information: Int {
		case id = 0
		case type = 1
		case seasonsCount = 2
		case episodesCount = 3
		case aireDates = 4
		case network = 5
		case duration = 6
		case rating = 7
		case languages = 8
		case genres = 9

		// MARK: - Properties
		/// An array containing all informations.
		static let all: [Information] = [.id, .type, .seasonsCount, .episodesCount, .aireDates, .network, .duration, .rating, .languages, .genres]

		/// The string value of an informations.
		var stringValue: String {
			switch self {
			case .id:
				return "ID"
			case .type:
				return "Type"
			case .seasonsCount:
				return "Seasons"
			case .episodesCount:
				return "Episodes"
			case .aireDates:
				return "Aired"
			case .network:
				return "Network"
			case .duration:
				return "Duration"
			case .rating:
				return "Rating"
			case .languages:
				return "Languages"
			case .genres:
				return "Genres"
			}
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
	enum ExternalSite: Int {
		case aniDB = 0
		case aniList = 1
		case imdb = 2
		case kitsu = 3
		case mal = 4
		case tvdb = 5

		// MARK: - Properties
		/// An array containing all external sites.
		static let all: [ExternalSite] = [.aniDB, .aniList, .imdb, .kitsu, .mal, .tvdb]

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
