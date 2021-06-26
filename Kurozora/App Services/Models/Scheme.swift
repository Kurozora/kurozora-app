//
//  Scheme.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/02/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Foundation

/**
	List of supported schemes.

	```
	case anime, show
	case profile, user
	case explore, home
	case library, myLibrary, list
	case feed, timeline
	case notification, notifications
	```
*/
enum Scheme: String {
	case anime, show
	case profile, user
	case explore, home
	case library, myLibrary, list
	case feed, timeline
	case notification, notifications

	// MARK: - Properties
	/// An array containing all supported schemes.
	static let all: [Scheme] = [.anime, .show, .profile, .user, .explore, .home, .library, .myLibrary, .list, .feed, .timeline, .notification, .notifications]
}
