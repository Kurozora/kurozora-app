//
//  ShowSections.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/04/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/**
	List of show sections

	- case synopsis = 0
	- case information = 1
	- case cast = 2
	- case related = 3
*/
enum ShowSections: Int {
	case synopsis
	case information
	case cast
	case related

	static var allSections: [ShowSections] = [.synopsis, .information, .cast, .related]
}
