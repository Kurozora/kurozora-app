//
//  String+Date.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Foundation

extension String {
	// MARK: - Functions
	/// Returns a date object for given string.
	func toDate(format: String = "yyyy-MM-dd HH:mm:ss") -> Date {
		if self != "" {
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = format

			if let dateFromString = dateFormatter.date(from: self) {
				return dateFromString
			}
		}
		return Date()
	}
}
