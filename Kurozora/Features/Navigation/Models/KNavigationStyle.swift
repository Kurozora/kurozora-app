//
//  KNavigationStyle.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/05/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/**
	List of Kurozora navigation styles

	```
	case normal = 0
	case blurred = 1
	```
*/
enum KNavigationStyle: Int {
	/// A translucent navigation bar, intended for use on all views.
	case normal = 0

	/// A blurred navigation bar, intended for use on search view only.
	case blurred
}
