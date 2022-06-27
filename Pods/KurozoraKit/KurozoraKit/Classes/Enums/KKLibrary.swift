//
//  KKLibrary.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 16/03/2019.
//

import UIKit

/// The set of available enums for managing the user's library.
///
/// `KKLibrary` offers the [Status](x-source-tag://KKL-Status) enum for managing a show's status as well as populate a library view.
/// It also offers the [SortType](x-source-tag://KKL-SortType) enum for managing the way shows are sorted. Which in turn offers the [Options](x-source-tag://KKL-ST-Options) enum for managing the sorting order.
public enum KKLibrary {
	/// The set of available library status types.
	///
	/// ```
	/// case none = "None"
	/// case watching = "Watching"
	/// case planning = "Planning"
	/// case completed = "Completed"
	/// case onHold = "On-Hold"
	/// case dropped = "Dropped"
	/// ```
	///
	/// - Tag: KKL-Status
	public enum Status: String, Codable {
		// MARK: - Cases
		/// The library has no status.
		case none = "None"

		/// The library's watching list.
		case watching = "Watching"

		/// The library's planning list.
		case planning = "Planning"

		/// The library's completed list.
		case completed = "Completed"

		/// The library's on-hold list.
		case onHold = "On-Hold"

		/// The library's dropped list.
		case dropped = "Dropped"

		// MARK: - Properties
		/// An array containing all library status types.
		public static let all: [Status] = [.watching, .planning, .completed, .onHold, .dropped]

		/// The string value of a library status type.
		public var stringValue: String {
			return self.rawValue
		}

		/// The section value string of a library status type.
		public var sectionValue: String {
			switch self {
			case .onHold:
				return "OnHold"
			default:
				return self.stringValue
			}
		}
	}

	/// The set of available library sorting types.
	///
	/// ```
	/// case none = 0
	/// case alphabetically = 1
	/// ...
	/// ```
	///
	/// - Tag: KKL-SortType
	public enum SortType: Int {
		// MARK: - Cases
		/// Sorted by no specific type.
		case none = 0

		/// Sorted by alphabetical order.
		case alphabetically = 1

//		case popularity = 2
//		case nextAiringEpisode = 3
//		case nextEpisodeToWatch = 4

		/// Sorted by date.
		case date = 5

		/// Sorted by global rating.
		case rating = 6

		/// Sorted by user's rating.
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
	/// The set of available library sort type option types.
	///
	/// ```
	/// case none = 0
	/// case ascending, descending
	/// case newest, oldest
	/// case worst, best
	/// ```
	///
	/// - Tag: KKL-ST-Options
	public enum Options: Int {
		// MARK: - Cases
		/// Sorted by no options.
		case none = 0

		/// Sorted in ascending order.
		case ascending

		/// Sorted in descending order.
		case descending

		/// Sorted by newest first.
		case newest

		/// Sorted by oldest first.
		case oldest

		/// Sorted by worst first.
		case worst

		/// Sorted by best first
		case best

		// MARK: - Properties
		/// An array containing all sort type option types.
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
