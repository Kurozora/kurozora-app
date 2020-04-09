//
//  WatchStatus.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 10/03/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Foundation

/**
	List of watch status.

	```
	case notWatched = -1
	case disabled = 0
	case watched = 1
	```
*/
public enum WatchStatus: Int {
	// MARK: - Cases
	case notWatched = -1
	case disabled = 0
	case watched = 1
}
