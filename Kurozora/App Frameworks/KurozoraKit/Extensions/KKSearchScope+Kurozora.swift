//
//  KKSearchScope+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit

extension KKSearchScope {
	// MARK: - Variables
	/// An array containing the string value of all search scopes.
	static var allString: [String] {
		return self.allCases.map { searchScope in
			return searchScope.stringValue
		}
	}

	/// The string value of a search scope.
	var stringValue: String {
		switch self {
		case .kurozora:
			return "Kurozora"
		case .library:
			return Trans.library
		}
	}
}
