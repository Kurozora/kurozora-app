//
//  ForumsSortingStyle.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

/**
	List of Forums sorting styles.

	```
	case top = "Top"
	case recent = "Recent"
	```
*/
enum ForumsSortingStyle: String {
	case top
	case recent

	/// The image value of a sorting style.
	var imageValue: UIImage {
		switch self {
		case .top:
			return #imageLiteral(resourceName: "Symbols/arrow_up_line_horizontal_3_decrease")
		case .recent:
			return #imageLiteral(resourceName: "Symbols/clock")
		}
	}
}
