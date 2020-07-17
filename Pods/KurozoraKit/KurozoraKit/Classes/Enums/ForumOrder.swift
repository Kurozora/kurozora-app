//
//  ForumOrder.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 06/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Foundation

/**
	The set of available forum order types.

	```
	case top = "top"
	case recent = "recent"
	```
*/
public enum ForumOrder: String, CaseIterable {
	// MARK: - Cases
	/// Order by top interacted thread.
	case top

	/// Order by most recent thread.
	case recent
}
