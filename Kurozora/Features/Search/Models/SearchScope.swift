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
}
