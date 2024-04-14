//
//  Scheme.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/02/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Foundation

/// List of supported schemes.
///
/// ```
/// case anime, show
/// case profile, user
/// case explore, home
/// case library, myLibrary, list
/// case feed, timeline
/// case notification, notifications
/// case search
/// ```
enum Scheme: String, CaseIterable {
	// MARK: - Cases
	case anime, show
	case profile, user
	case explore, home
	case library, myLibrary, list
	case feed, timeline
	case notification, notifications
	case search

	// MARK: - Properties
	var urlValue: URL {
		return URL(string: "kurozora://\(self.rawValue)")!
	}
}
