//
//  KKLibrary.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

public enum KKLibrary {
	/**
		List of library status.

		```
		case watching = 0
		case planning = 1
		case completed = 2
		case onHold = 3
		case dropped = 4
		```
	*/
	public enum Status: Int {
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
		/// An array containing all library status.
		public static let all: [Status] = [.watching, .planning, .completed, .onHold, .dropped]

		/// The string value of a library status.
		public var stringValue: String {
			switch self {
			case .watching:
				return "Watching"
			case .planning:
				return "Planning"
			case .completed:
				return "Completed"
			case .onHold:
				return "On-Hold"
			case .dropped:
				return "Dropped"
			}
		}

		// MARK: - Functions
		/**
			Returns the `KKLibrary.Status` value for the given string.

			To decide the returned value, the given string is lowercased and compared with the `stringValue` of the `KKLibrary.Status` cases.
			If no match is found then `.watching` is returned.

			- Parameter string: The string value by which the `KKLibrary.Status` value is determined.

			- Returns: the `KKLibrary.Status` value for the given string or `.watching` if no match is found.
		*/
		public static func fromString(_ string: String) -> KKLibrary.Status {
			switch string.lowercased() {
			case watching.stringValue.lowercased():
				return .watching
			case planning.stringValue.lowercased():
				return .planning
			case completed.stringValue.lowercased():
				return .completed
			case onHold.stringValue.lowercased():
				return .onHold
			case dropped.stringValue.lowercased():
				return .dropped
			default:
				return .watching
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
	public enum SortType: Int {
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
		public static let all: [KKLibrary.SortType] = [.alphabetically, /*.popularity, .nextAiringEpisode, .nextEpisodeToWatch,*/ .date, .rating, .myRating]

		/// The string value of a sort type.
		public var stringValue: String {
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
		public var parameterValue: String {
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

		/// An array containing all library sort type sub-options string value and its equivalent raw value.
		public var optionValue: [KKLibrary.SortType.Options] {
			switch self {
			case .none:
				return []
			case .alphabetically:
				return [.ascending, .descending]
			case .date:
				return [.newest, .oldest]
			case .rating:
				return [.best, .worst]
			case .myRating:
				return [.best, .worst]
			}
		}
	}
}

extension KKLibrary.SortType {
	/**
		List of library sorting type options.

		```
		case none = 0
		case ascending, descending
		case newest, oldest
		case worst, best
		```
	*/
	public enum Options: Int {
		case none = 0
		case ascending, descending
		case newest, oldest
		case worst, best

		// MARK: - Properties
		/// An array containing all sort type options.
		public static let all: [KKLibrary.SortType.Options] = [.ascending, .descending, .newest, .oldest, .worst, .best]

		/// The string value of a sort type option.
		public var stringValue: String {
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
		public var parameterValue: String {
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
