//
//  CellStyle.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension KKLibrary {
	/// List of library layout styles.
	///
	/// ```
	/// case detailed = 0
	/// case compact = 1
	/// case list = 2
	/// ```
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
				return UIImage(systemName: "rectangle.fill.on.rectangle.fill")!
			case .compact:
				return UIImage(systemName: "rectangle.grid.3x2.fill")!
			case .list:
				return UIImage(systemName: "rectangle.grid.1x2.fill")!
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
