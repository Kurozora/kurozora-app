//
//  VerticalCollectionCellStyle.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

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

	/// The cell identifier string of a vertical collection cell style.
	var identifierString: String {
		switch self {
		case .actionList:
			return "ActionListExploreCollectionViewCell"
		case .actionButton:
			return "ActionButtonExploreCollectionViewCell"
		}
	}
}
