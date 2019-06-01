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

	- case show = "ShowResultCell"
	- case myLibrary = "LibraryResultCell"
	- case thread = "ThreadResultCell"
	- case user = "UserResultCell"
*/
enum SearchList: String {
	case show = "ShowResultCell"
	case myLibrary = "LibraryResultCell"
	case thread = "ThreadResultCell"
	case user = "UserResultCell"

	static func fromScope(_ scope: SearchScope) -> String {
		switch scope {
		case .show:
			return "ShowResultCell"
		case .myLibrary:
			return "LibraryResultCell"
		case .thread:
			return "ThreadResultCell"
		case .user:
			return "UserResultCell"
		}
	}
}
