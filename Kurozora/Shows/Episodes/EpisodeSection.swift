//
//  EpisodeSection.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/05/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/**
	List of episode view sections.

	```
	case synopsis = 0
	case information = 1
	case cast = 2
	case discussion = 3
	```
*/
enum EpisodeSection: Int {
	case synopsis
	case information
	case cast
	case discussion

	/// An array containing all episode sections.
	static let all: [EpisodeSection] = [.synopsis, .information, .cast, .discussion]
}
