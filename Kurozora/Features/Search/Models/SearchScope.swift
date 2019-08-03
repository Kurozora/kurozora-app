//
//  SearchScope.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/**
	List of search scopes

	- case show = 0
	- case myLibrary
	- case thread
	- case user
*/
enum SearchScope: Int {
	case show = 0
	case myLibrary
	case thread
	case user

	var stringValue: String {
		switch self {
		case .show:
			return "Anime"
		case .myLibrary:
			return "My Library"
		case .thread:
			return "Thread"
		case .user:
			return "User"
		}
	}

	static var all: [SearchScope] = [.show, .myLibrary, .thread, .user]
	static var allString: [String] {
		var allString: [String] = []
		for scope in all {
			allString.append(scope.stringValue)
		}
		return allString
	}
}
