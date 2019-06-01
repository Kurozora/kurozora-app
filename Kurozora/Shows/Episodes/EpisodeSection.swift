//
//  EpisodeSection.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/05/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/**
	List of episode view sections

	- case synopsis
	- case information
	- case cast
	- case discussion
*/

enum EpisodeSection: Int {
	case synopsis
	case information
	case cast
	case discussion

	static var allSections: [EpisodeSection] = [.synopsis, .information, .cast, .discussion]
}
