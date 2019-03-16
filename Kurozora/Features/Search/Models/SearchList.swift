//
//  SearchList.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/**
	List of search cases

	- case show = "ShowCell"
	- case myLibrary = "LibraryCell"
	- case thread = "ThreadCell"
	- case user = "UserCell"
*/
enum SearchList: String {
	case show = "ShowCell"
	case myLibrary = "LibraryCell"
	case thread = "ThreadCell"
	case user = "UserCell"

	static func fromScope(_ scope: SearchScope) -> String {
		switch scope {
		case .show:
			return "ShowCell"
		case .thread:
			return "ThreadCell"
		case .user:
			return "UserCell"
		case .myLibrary:
			return "LibraryCell"
		}
	}
}
