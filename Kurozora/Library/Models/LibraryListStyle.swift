//
//  LibraryListStyle.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/**
	List of library styles.

	```
	case compact = "CompactCell"
	case detailed = "DetailedCell"
	case list = "ListCell" (unused)
	```
*/
enum LibraryListStyle: String {
	/// Indicates that the cell has the `compact` style.
	case compact = "CompactCell"

	/// Indicates that the cell has the `detailed` style.
	case detailed = "DetailedCell"

	/// Indicates that the cell has the `list` style.
	//		case list = "ListCell"
}
