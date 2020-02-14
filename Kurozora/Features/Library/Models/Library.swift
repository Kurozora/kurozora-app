//
//  LibrarySection.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class Library {
	/**
		List of library sections.

		```
		case watching = 0
		case planning = 1
		case completed = 2
		case onHold = 3
		case dropped = 4
		```
	*/
	enum Section: Int {
		// MARK: - Cases
		/// The watching list in the user's library.
		case watching = 0

		/// The planning list in the user's library.
		case planning = 1

		/// The completed list in the user's library.
		case completed = 2

		/// The on-hold list in the user's library.
		case onHold = 3

		/// The dropped list in the user's library.
		case dropped = 4

		// MARK: - Properties
		/// An array containing all library sections.
		static let all: [Section] = [.watching, .planning, .completed, .onHold, .dropped]

		/// The string value of a library section.
		var stringValue: String {
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

		/// The section value string of a library section.
		var sectionValue: String {
			switch self {
			case .onHold:
				return "OnHold"
			default:
				return self.stringValue
			}
		}

		/// An array containing all library section string value and its equivalent section value.
		static var alertControllerItems: [(String, String)] {
			var items = [(String, String)]()
			for section in Section.all {
				items.append((section.stringValue, section.sectionValue))
			}
			return items
		}
	}

	/**
		List of library layout styles.

		```
		case detailed = 0
		case compact = 1
		case list = 2
		```
	*/
	enum CellStyle: Int {
		// MARK: - Cases
		/// Indicates that the cell has the `detailed` style.
		case detailed = 0

		/// Indicates that the cell has the `compact` style.
		case compact = 1

		/// Indicates that the cell has the `list` style.
		case list = 2

		// MARK: - Properties
		/// An array containing all library cell styles.
		static let all: [CellStyle] = [.compact, .detailed, .list]

		/// The string value of a library cell style.
		var stringValue: String {
			switch self {
			case .detailed:
				return "Detailed"
			case .compact:
				return "Compact"
			case .list:
				return "List"
			}
		}

		/// The cell identifier string of a cell style.
		var identifierString: String {
			switch self {
			case .detailed:
				return R.reuseIdentifier.libraryDetailedCollectionViewCell.identifier
			case .compact:
				return R.reuseIdentifier.libraryCompactCollectionViewCell.identifier
			case .list:
				return R.reuseIdentifier.libraryListCollectionViewCell.identifier
			}
		}

		/// The image value of a cell style.
		var imageValue: UIImage {
			switch self {
			case .detailed:
				return R.image.symbols.rectangle_fill_on_rectangle_fill()!
			case .compact:
				return R.image.symbols.rectangle_grid_3x2_fill()!
			case .list:
				return R.image.symbols.rectangle_grid_1x2_fill()!
			}
		}

		/// The next cell style.
		var next: CellStyle {
			var cellValue = self.rawValue
			cellValue += 1

			if cellValue > CellStyle.all.count-1 {
				cellValue = 0
			}

			return CellStyle(rawValue: cellValue) ?? .detailed
		}

		/// The previous cell style.
		var previous: CellStyle {
			var cellValue = self.rawValue
			cellValue -= 1

			if cellValue < 0 {
				cellValue = CellStyle.all.count-1
			}

			return CellStyle(rawValue: cellValue) ?? .detailed
		}

		// TODO: - A better way to implement this mess
		var sizeValue: CGSize {
			var cgSize: CGSize = .zero

			switch self {
			case .detailed:
				let screenWidth = UIScreen.main.bounds.width - 20
				let screenHeight = UIScreen.main.bounds.height - 20

				if UIDevice.isLandscape {
					switch UIDevice.type {
					case .iPhone5SSE, .iPhone66S78, .iPhone66S78PLUS:
						return CGSize(width: screenWidth / 2.08, height: screenHeight / 2.0)
					case .iPhoneXr, .iPhoneXXs, .iPhoneXsMax:
						return CGSize(width: screenWidth / 2.32, height: screenHeight / 1.8)
					case .iPad, .iPadAir3, .iPadPro11, .iPadPro12:
						return CGSize(width: screenWidth / 3.06, height: screenHeight / 3.8)
					}
				} else {
					switch UIDevice.type {
					case .iPhone5SSE:
						return CGSize(width: screenWidth, height: screenHeight / 3.2)
					case .iPhone66S78, .iPhone66S78PLUS:
						return CGSize(width: screenWidth, height: screenHeight / 3.2)
					case .iPhoneXr, .iPhoneXXs, .iPhoneXsMax:
						return CGSize(width: screenWidth, height: screenHeight / 3.8)
					case .iPad, .iPadAir3, .iPadPro11, .iPadPro12:
						return CGSize(width: screenWidth / 2, height: screenHeight / 4.8)
					}
				}
			case .compact:
				cgSize = CGSize(width: 150, height: 210)
			case .list:
				let screenWidth = UIScreen.main.bounds.width - 20
				cgSize.height = 160

				if UIDevice.isPhone {
					if UIDevice.isLandscape {
						cgSize.width = screenWidth / 2
					} else {
						cgSize.width = screenWidth
					}
				} else {
					if UIDevice.isLandscape {
						cgSize.width = 320
					} else {
						cgSize.width = screenWidth / 2
					}
				}
			}

			return cgSize
		}
	}

	/**
		List of all sort types for shows in a user's library.

		```
		case none = 0
		case alphabetically = 1
		case popularity = 2
		case nextAiringEpisode = 3
		case nextEpisodeToWatch = 4
		case newest = 5
		case oldest = 6
		case rating = 7
		case myRating = 8
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

		/// The image value of a sort type.
		var imageValue: UIImage {
			switch self {
			case .none:
				return R.image.symbols.line_horizontal_3_decrease_circle_fill()!
			case .alphabetically:
				return R.image.symbols.textformat_abc()!
//			case .popularity:
//				return R.image.symbols.flame_fill()!
//			case .nextAiringEpisode:
//				return R.image.symbols.tv_arrowshape_turn_up_right_fill()!
//			case .nextEpisodeToWatch:
//				return R.image.symbols.tv_eye_fill()!
			case .date:
				return R.image.symbols.calendar()!
			case .rating:
				return R.image.symbols.star_fill()!
			case .myRating:
				return R.image.symbols.person_crop_circle_fill_badge_star()!
			}
		}

		/// An array containing all library sort type string value and its equivalent raw value.
		static var alertControllerItems: [(String, Library.SortType, UIImage)] {
			var items = [(String, Library.SortType, UIImage)]()
			for sortType in SortType.all {
				items.append((sortType.stringValue, sortType, sortType.imageValue))
			}
			return items
		}

		/// An array containing all library sort type string value and its equivalent raw value.
		var subAlertControllerItems: [(String, Library.SortType.Options, UIImage)] {
			var items = [(String, Library.SortType.Options, UIImage)]()
			for option in self.optionValue {
				items.append((option.stringValue, option, option.imageValue))
			}
			return items
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

		/// An array containing all library sort type sub-options string value and its equivalent raw value.
		var optionValue: [Library.SortType.Options] {
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

extension Library.SortType {
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

		/// The image value of a sort type option.
		var imageValue: UIImage {
			switch self {
			case .none:
				return R.image.symbols.line_horizontal_3_decrease_circle_fill()!
			case .ascending:
				return R.image.symbols.arrow_up_line_horizontal_3_decrease()!
			case .descending:
				return R.image.symbols.arrow_down_line_horizontal_3_increase()!
			case .newest:
				return R.image.symbols.calendar_badge_arrowshape_turn_up_right()!
			case .oldest:
				return R.image.symbols.calendar_badge_arrowshape_turn_up_left()!
			case .best:
				return R.image.symbols.hand_thumbsup_fill()!
			case .worst:
				return R.image.symbols.hand_thumbsdown_fill()!
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
