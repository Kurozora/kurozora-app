//
//  CellStyle.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension KKLibrary {
	/// List of library layout styles.
	///
	/// ```swift
	/// case detailed = 0
	/// case compact = 1
	/// case list = 2
	/// case table = 3
	/// ```
	enum CellStyle: Int {
		// MARK: - Cases
		/// Indicates that the cell has the `detailed` style.
		case detailed = 0

		/// Indicates that the cell has the `compact` style.
		case compact = 1

		/// Indicates that the cell has the `list` style.
		case list = 2

		/// Indicates that the cell has the `table` style.
		case table = 3

		// MARK: - Properties
		/// An array containing all library cell styles.
		static let all: [CellStyle] = [.compact, .detailed, .list, .table]

		/// The string value of a library cell style.
		var stringValue: String {
			switch self {
			case .detailed:
				return "Detailed"
			case .compact:
				return "Compact"
			case .list:
				return "List"
			case .table:
				return "Table"
			}
		}

		/// The cell identifier string of a cell style.
		var identifierString: String {
			switch self {
			case .detailed:
				return LibraryDetailedCollectionViewCell.reuseID
			case .compact:
				return LibraryCompactCollectionViewCell.reuseID
			case .list:
				return LibraryListCollectionViewCell.reuseID
			case .table:
				return LibraryTableCollectionViewCell.reuseID
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
			case .table:
				return UIImage(systemName: "tablecells.fill")!
			}
		}
	}

	/// Controls title visibility for cells rendered with the ``CellStyle/compact`` layout.
	///
	/// ```swift
	/// case always = 0
	/// case never = 1
	/// case smart = 2
	/// ```
	enum CompactTitleVisibility: Int, CaseIterable {
		// MARK: - Cases
		/// Always show the title beneath the poster.
		case always = 0

		/// Never show the title — the poster stands alone.
		case never = 1

		/// Hide the title when real poster art is loaded; show it when the poster is the built-in placeholder.
		case smart = 2

		// MARK: - Properties
		/// The human-readable title for the View Options menu entry.
		var title: String {
			switch self {
			case .always: return L10n.compactTitleAlways
			case .never: return L10n.compactTitleNever
			case .smart: return L10n.compactTitleSmart
			}
		}

		/// The menu-entry icon. Falls back to an empty image when the SF Symbol is unavailable.
		var image: UIImage? {
			switch self {
			case .always: return UIImage(systemName: "text.below.photo") ?? UIImage()
			case .never: return UIImage(systemName: "photo") ?? UIImage()
			case .smart: return UIImage(systemName: "sparkles") ?? UIImage()
			}
		}

		/// Short explanatory text surfaced beneath the menu title, when applicable.
		var subtitle: String? {
			switch self {
			case .smart: return L10n.compactTitleSmartSubtitle
			default: return nil
			}
		}
	}
}
