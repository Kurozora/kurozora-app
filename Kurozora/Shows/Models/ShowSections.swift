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
		case synopsis = 1
		case rating = 2
		case information = 3
		case seasons = 4
		case cast = 5
		case related = 6
		```
	*/
	enum Section: Int {
		case header = 0
		case synopsis = 1
		case rating = 2
		case information = 3
		case seasons = 4
		case cast = 5
		case related = 6

		/// An array containing all show sections.
		static let all: [Section] = [.header, .synopsis, .rating, .information, .seasons, .cast, .related]

		/// The string value of a show section.
		var stringValue: String {
			switch self {
			case .header:
				return "Header"
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
				return "ShowDetailHeaderCollectionViewCell"
			case .synopsis:
				return "SynopsisCollectionViewCell"
			case .rating:
				return "RatingCollectionViewCell"
			case .information:
				return "InformationCollectionViewCell"
			case .seasons:
				return "SeasonCollectionViewCell"
			case .cast:
				return "CastCollectionViewCell"
			case .related:
				return "RelatedShowCollectionViewCell"
			}
		}

		/// The string value of a show section segue identifier.
		var segueIdentifier: String {
			switch self {
			case .header:
				return ""
			case .synopsis:
				return ""
			case .rating:
				return ""
			case .information:
				return ""
			case .seasons:
				return "SeasonSegue"
			case .cast:
				return "CastSegue"
			case .related:
				return "RelatedSegue"
			}
		}
	}

	/**
		List of airing statuses.

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

		/// An array containing all airing statuses.
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
	//		/// An array containing all airing statuses.
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
