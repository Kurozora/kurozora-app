//
//  UserDefaults+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/09/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import Foundation

extension UserDefaults {
	/// Date from UserDefaults.
	///
	/// - Parameter key: key to find date for.
	///
	/// - Returns: Date object for key (if exists).
	func date(forKey key: String) -> Date? {
		return self.object(forKey: key) as? Date
	}
}
