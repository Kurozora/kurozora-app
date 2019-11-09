//
//  LibrarySection.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/**
	List of library sections.

	```
	case watching = 0
	case planning = 1
	case completed = 2
	case onHold = 3
	case dropped = 4
	```
*/
enum LibrarySection: Int {
	/// The watching list in the user's library.
	case watching = 0

	/// The planning list in the user's library.
	case planning = 1

	/// The completed list in the user's library.
	case completed = 2

	/// The on-hold list in the user's library.
	case onHold = 3

	/// The dropped list in the user's library.
	case dropped = 4

	/// An array containing all library sections.
	static let all: [LibrarySection] = [.watching, .planning, .completed, .onHold, .dropped]

	/// The string value of a library section.
	var stringValue: String {
		switch self {
		case .watching:
			return "Watching"
		case .planning:
			return "Planning"
		case .completed:
			return "Completed"
		case .onHold:
			return "On-Hold"
		case .dropped:
			return "Dropped"
		}
	}
}
