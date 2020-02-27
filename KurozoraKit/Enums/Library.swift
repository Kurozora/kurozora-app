//
//  Library.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

enum Library {
	/**
		List of library statuses.

		```
		case watching = 0
		case planning = 1
		case completed = 2
		case onHold = 3
		case dropped = 4
		```
	*/
	enum Status: Int {
		// MARK: - Cases
		/// The watching status of a show.
		case watching = 0

		/// The planning status of a show.
		case planning = 1

		/// The completed status of a show.
		case completed = 2

		/// The on-hold status of a show.
		case onHold = 3

		/// The dropped status of a show.
		case dropped = 4

		// MARK: - Properties
		/// An array containing all library statuses.
		static let all: [Status] = [.watching, .planning, .completed, .onHold, .dropped]

		/// The string value of a library status.
		var stringValue: String {
			switch self {
			case .watching:
				return "Watching"
			case .planning:
				return "Planning"
			case .completed:
				return "Completed"
			case .onHold:
				return "OnHold"
			case .dropped:
				return "Dropped"
			}
		}
	}

	/**
		List of library sorting types.

		```
		case none = 0
		case alphabetically = 1
		...
		```
	*/
	enum SortType: Int {
		// MARK: - Cases
		case none = 0
		case alphabetically = 1
//		case popularity = 2
//		case nextAiringEpisode = 3
//		case nextEpisodeToWatch = 4
		case date = 5
		case rating = 6
		case myRating = 7

		// MARK: - Properties
		/// An array containing all sort types.
		static let all: [Library.SortType] = [.alphabetically, /*.popularity, .nextAiringEpisode, .nextEpisodeToWatch,*/ .date, .rating, .myRating]

		/// The string value of a sort type.
		var stringValue: String {
			switch self {
			case .none:
				return "None"
			case .alphabetically:
				return "Alphabetically"
//			case .popularity:
//				return "Popularity"
//			case .nextAiringEpisode:
//				return "Next Episode to Air"
//			case .nextEpisodeToWatch:
//				return "Next Episode to Watch"
			case .date:
				return "Date"
			case .rating:
				return "Rating"
			case .myRating:
				return "My Rating"
			}
		}

		/// The parameter value of a sort type.
		var parameterValue: String {
			switch self {
			case .none:
				return ""
			case .alphabetically:
				return "title"
			case .date:
				return "age"
			case .rating:
				return "rating"
			case .myRating:
				return "my-rating"
			}
		}
	}
}

extension Library.SortType {
	/**
		List of library sorting type options.

		```
		case none = 0
		case ascending, descending
		case newest, oldest
		case worst, best
		```
	*/
	enum Options: Int {
		case none = 0
		case ascending, descending
		case newest, oldest
		case worst, best

		// MARK: - Properties
		/// An array containing all sort type options.
		static let all: [Library.SortType.Options] = [.ascending, .descending, .newest, .oldest, .worst, .best]

		/// The string value of a sort type option.
		var stringValue: String {
			switch self {
			case .none:
				return "None"
			case .ascending:
				return "A-Z"
			case .descending:
				return "Z-A"
			case .newest:
				return "Newest"
			case .oldest:
				return "Oldest"
			case .worst:
				return "Worst"
			case .best:
				return "Best"
			}
		}

		/// The parameter value of a sort type option.
		var parameterValue: String {
			switch self {
			case .none:
				return "()"
			case .ascending:
				return "(asc)"
			case .descending:
				return "(desc)"
			case .newest:
				return "(newest)"
			case .oldest:
				return "(oldest)"
			case .best:
				return "(best)"
			case .worst:
				return "(worst)"
			}
		}
	}
}
