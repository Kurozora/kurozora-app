//
//  ShowSections.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/04/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/**
	List of show sections.

	```
	case synopsis = 0
	case information = 1
	case rating = 2
	case cast = 3
	case related = 4
	```
*/
enum ShowSections: Int {
	case synopsis
	case information
	case rating
	case cast
	case related

	/// An array containing all show sections.
	static let all: [ShowSections] = [.synopsis, .information, .rating, .cast, .related]
}
