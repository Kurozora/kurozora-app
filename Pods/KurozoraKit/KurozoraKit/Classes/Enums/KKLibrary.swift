//
//  KKLibrary.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 16/03/2019.
//

import UIKit

/// The set of available enums for managing the user's library.
///
/// `KKLibrary` offers:
/// - [Kind](x-source-tag://KKL-Kind) enum for managing a specific user library.
/// - [Status](x-source-tag://KKL-Status) enum for managing an item's status as well as populate a library view.
/// - [SortType](x-source-tag://KKL-SortType) enum for managing the way items are sorted.
///     - This in turn offers the [Options](x-source-tag://KKL-ST-Options) enum for managing the sorting order.
public enum KKLibrary {
	/// The set of available library types.
	///
	/// ```
	/// case anime = 0
	/// case literature = 1
	/// case game = 3
	/// ```
	///
	/// - Tag: KKL-Kind
	public enum Kind: Int, CaseIterable {
		// MARK: - Cases
		/// The shows library of the user.
		case shows = 0

		/// The literature library of the user.
		case literatures = 1

		/// The games library of the user.
		case games = 3

		// MARK: - Properties
		/// The string value of a library type.
		public var stringValue: String {
			switch self {
			case .shows:
				return "Shows"
			case .literatures:
				return "Literatures"
			case .games:
				return "Games"
			}
		}
	}

	/// The set of available library status types.
	///
	/// ```
	/// case none = -1
	/// case inProgress = 0
	/// case planning = 2
	/// case completed = 3
	/// case onHold = 4
	/// case dropped = 1
	/// ```
	///
	/// - Tag: KKL-Status
	public enum Status: Int, Codable {
		// MARK: - Cases
		/// The library has no status.
		case none = -1

		/// The library's watching list.
		case inProgress = 0

		/// The library's planning list.
		case planning = 2

		/// The library's completed list.
		case completed = 3

		/// The library's on-hold list.
		case onHold = 4

		/// The library's dropped list.
		case dropped = 1

		// MARK: - Properties
		/// An array containing all library status types.
		public static let all: [Status] = [.inProgress, .planning, .completed, .onHold, .dropped]

		/// The string value of a library status type.
		public var stringValue: String {
			switch self {
			case .none:
				return "None"
			case .inProgress:
				return "In Progress"
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

		/// The section value string of a library status type.
		public var sectionValue: String {
			switch self {
			case .inProgress:
				return "InProgress"
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
