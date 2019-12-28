//
//  VerticalCollectionCellStyle.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

/**
	List of vertival explore cell styles.

	```
	case actionList = 0
	case actionButton = 1
	```
*/
enum VerticalCollectionCellStyle: Int {
	/// Indicates that the cell has the `actionList` style.
	case actionList = 0

	/// Indicates that the cell has the `actionButton` style.
	case actionButton = 1

	/// Indicates that the cell has the `legal` style.
	case legal = 2
}

// MARK: - Properties
extension VerticalCollectionCellStyle {
	/// The cell identifier string of a vertical collection cell style.
	var identifierString: String {
		switch self {
		case .actionList:
			return "ActionListExploreCollectionViewCell"
		case .actionButton:
			return "ActionButtonExploreCollectionViewCell"
		case .legal:
			return "LegalExploreCollectionViewCell"
		}
	}

	/// The item content insets of a vertical collection cell style.
	var itemContentInsets: NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10)
	}
}

// MARK: - Functions
extension VerticalCollectionCellStyle {
	/**
		Reutrns the number of columns the collection view should present.

		- Parameter width: The width of the collection view used to calculate the number of columns.
		- Parameter numberOfItems: The number of items in a section used to determine the number of columns.

		- Returns: the number of columns the collection view should present.
	*/
	func columnCount(for width: CGFloat, numberOfItems: Int) -> Int {
		var columnCount = 0
		let numberOfItems = numberOfItems > 0 ? numberOfItems : 1

		switch self {
		case .actionList:
			if width < 414 {
				columnCount = 1
			} else if width < 828 {
				columnCount = 2
			} else {
				if numberOfItems < 5 {
					columnCount = numberOfItems
				} else {
					columnCount = 5
				}
			}
		case .actionButton:
			if width < 414 {
				columnCount = 1
			} else if width < 828 {
				columnCount = 2
			} else {
				columnCount = (width / 414).int
			}
		case .legal:
			columnCount = 1
		}

		return columnCount > 0 ? columnCount : 1
	}

	/**
		Returns the section content insets of a vertical collection cell style.

		- Parameter width: The width used to calculate the section content inset.
		- Parameter numberOfItems: The number of items the current section contains.

		- Returns: the section content insets of a vertical collection cell style.
	*/
	func sectionContentInsets(for width: CGFloat, numberOfItems: Int) -> NSDirectionalEdgeInsets {
		switch self {
		case .actionButton:
			if width > 828 {
				let itemsWidth = (414 * numberOfItems + 20 * numberOfItems).cgFloat
				var leadingInset: CGFloat = (width - itemsWidth) / 2
				var trailingInset: CGFloat = 0

				if leadingInset < 10 {
					leadingInset = 10
					trailingInset = 10
				} else if width < 1240 {
					trailingInset = leadingInset
				}

				return NSDirectionalEdgeInsets(top: 0, leading: leadingInset, bottom: 20, trailing: trailingInset)
			}

			return NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10)
		default:
			return NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10)
		}
	}
}
