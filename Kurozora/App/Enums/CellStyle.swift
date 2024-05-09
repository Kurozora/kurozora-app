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
	}
}
