//
//  String+Date.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Foundation

extension String {
	// MARK: - Properties
	/// Returns a date object for given string.
	var toDate: Date {
		if self != "" {
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

			if let dateFromString = dateFormatter.date(from: self) {
				return dateFromString
			}
		}
		return Date()
	}
}
