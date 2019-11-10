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
		/// Indicates that the cell has the `detailed` style.
		case detailed = 0

		/// Indicates that the cell has the `compact` style.
		case compact = 1

		/// Indicates that the cell has the `list` style.
		case list = 2

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
				return "LibraryDetailedCollectionViewCell"
			case .compact:
				return "LibraryCompactCollectionViewCell"
			case .list:
				return "LibraryListCollectionViewCell"
			}
		}

		/// The image value of a cell style.
		var imageValue: UIImage {
			switch self {
			case .detailed:
				return #imageLiteral(resourceName: "detailed_view_icon")
			case .compact:
				return #imageLiteral(resourceName: "compact_view_icon")
			case .list:
				return #imageLiteral(resourceName: "sort_top")
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
}
