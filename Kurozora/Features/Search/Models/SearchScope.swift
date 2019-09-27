//
//  SearchScope.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/**
	List of search scopes used to filter search results.

	```
	case show = 0
	case myLibrary = 1
	case thread = 2
	case user = 3
	```
*/
enum SearchScope: Int {
	/// Search in shows list.
	case show = 0

	/// Search in user's library list.
	case myLibrary = 1

	/// Search in threads list.
	case thread = 2

	/// Search in users list.
	case user = 3
}

// MARK: - Variables
extension SearchScope {
	/// The string value of a search scope.
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

	/// The cell identifier string of a search scope.
	var identifierString: String {
		switch self {
		case .show:
			return "SearchShowResultsCell"
		case .myLibrary:
			return "SearchLibraryResultCell"
		case .thread:
			return "SearchForumsResultsCell"
		case .user:
			return "SearchUserResultsCell"
		}
	}

	/// An array containing all search scopes.
	static let all: [SearchScope] = [.show, .myLibrary, .thread, .user]

	/// An array containing the string value of all search scopes.
	static var allString: [String] {
		var allString: [String] = []
		for scope in all {
			allString.append(scope.stringValue)
		}
		return allString
	}
}

// MARK: - Functions
extension SearchScope {
	/// Returns a SearchScope for a given identifier string.
	static func scope(from identifier: String) -> SearchScope {
		switch identifier {
		case "ShowResultCell":
			return .show
		case "LibraryResultCell":
			return .myLibrary
		case "ThreadResultCell":
			return .thread
		case "UserResultCell":
			return .user
		default:
			return .show
		}
	}
}
