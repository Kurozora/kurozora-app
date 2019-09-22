//
//  LoginCellType.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/**
	List of login cell types used on the login table view.

	```
	case username = 0
	case password = 1
	case footer = 2
	```
*/
enum LoginCellType: Int {
	/// Username cell type.
	case username = 0

	/// Password cell type.
	case password = 1

	/// Footer cell type.
	case footer = 2

	/// An array containing all login cell types.
	static let all: [LoginCellType] = [.username, .password, .footer]
}
