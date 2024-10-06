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
///     - This in turn offers the [Option](x-source-tag://KKL-ST-Option) enum for managing the sorting order.
public enum KKLibrary {
	/// The set of available library types.
	///
	/// ```
	/// case shows = 0
	/// case literature = 1
	/// case game = 2
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
		case games = 2

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
	/// case interested = 6
	/// case ignored = 5
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

		/// The library's interested list.
		case interested = 6

		/// The library's ignored list.
		case ignored = 5

		// MARK: - Properties
		/// An array containing all library status types.
		public static let all: [Status] = [.inProgress, .planning, .completed, .onHold, .dropped, .interested, .ignored]

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
			case .interested:
				return "Interested"
			case .ignored:
				return "Ignored"
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
	/// - `none`: sorts by no specific type
	/// - `alphabetically`: sorts by alphabetical order
	/// - `popularity`: sorts by popularity
	/// - `date`: sorts by date
	/// - `rating`: sorts by global rating
	/// - `myRating`: sorts by user's rating
	///
	/// - Tag: KKL-SortType
	public enum SortType: Int, CaseIterable {
		// MARK: - Cases
		/// Sorted by no specific type.
		case none = 0

		/// Sorted by alphabetical order.
		case alphabetically

		/// Sorted by popularity.
		case popularity

//		case nextAiringEpisode
//		case nextEpisodeToWatch

		/// Sorted by date.
		case date

		/// Sorted by global rating.
		case rating

		/// Sorted by user's rating.
		case myRating

		// MARK: - Properties
		/// An array containing all sort types.
		public static let all: [KKLibrary.SortType] = [.alphabetically, .popularity, /*.nextAiringEpisode, .nextEpisodeToWatch,*/ .date, .rating, .myRating]

		/// The string value of a sort type.
		public var stringValue: String {
			switch self {
			case .none:
				return "None"
			case .alphabetically:
				return "Alphabetically"
			case .popularity:
				return "Popularity"
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
			case .popularity:
				return "popularity"
			case .date:
				return "date"
			case .rating:
				return "rating"
			case .myRating:
				return "my-rating"
			}
		}

		/// An array containing all library sort type sub-options string value and its equivalent raw value.
		public var optionValue: [KKLibrary.SortType.Option] {
			switch self {
			case .none:
				return []
			case .alphabetically:
				return [.ascending, .descending]
			case .popularity:
				return [.most, .least]
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
	/// case most, least
	/// case newest, oldest
	/// case worst, best
	/// ```
	///
	/// - Tag: KKL-ST-Option
	public enum Option: Int {
		// MARK: - Cases
		/// Sorted by no options.
		case none = 0

		/// Sorted in ascending order.
		case ascending

		/// Sorted in descending order.
		case descending

		/// Sorted in ascending order.
		case most

		/// Sorted in descending order.
		case least

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
		public static let all: [KKLibrary.SortType.Option] = [.ascending, .descending, .newest, .oldest, .worst, .best]

		/// The string value of a sort type option.
		public var stringValue: String {
			switch self {
			case .none:
				return "None"
			case .ascending:
				return "A-Z"
			case .descending:
				return "Z-A"
			case .most:
				return "Most"
			case .least:
				return "Least"
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
			case .most:
				return "(most)"
			case .least:
				return "(least)"
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
