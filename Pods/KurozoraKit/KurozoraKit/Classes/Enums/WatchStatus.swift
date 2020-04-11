//
//  WatchStatus.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 10/03/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Foundation

/**
	The set of available watch status types.

	```
	case notWatched = -1
	case disabled = 0
	case watched = 1
	```
*/
public enum WatchStatus: Int {
	// MARK: - Cases
	/// The episode is not watched.
	case notWatched = -1

	/// The episode can't be watched or unwatched.
	case disabled = 0

	/// The episode is watched.
	case watched = 1
}
