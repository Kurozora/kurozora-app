//
//  Int+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/09/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Foundation

extension Int {
	/// String formatted values properly displaying huge numbers.
	///
	/// String formatted for values over ±1000 (example: 1k, -2k, 100k, 1kk, -5kk..).
	///
	/// If the value is between 1000 and -1000 then it's returned as is (example: 0, -2, 100, 1, -5..).
	var kkFormatted: String {
		switch self {
		case _ where self < 1000 && self > -1000:
			return "\(self)"
		default:
			return self.kFormatted
		}
	}
}
