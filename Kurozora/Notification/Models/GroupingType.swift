//
//  GroupingType.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/**
	List of notification group types

	- case automatic = 0
	- case byType = 1
	- case off = 2
*/
enum GroupingType: Int {
	case automatic = 0
	case byType
	case off
}
