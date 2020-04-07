//
//  String+Date.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 07/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Foundation

extension String {
	/// Returns a date object for the given string.
	var toDate: Date {
		if self != "" {
			let dateFormatter = DateFormatter()
			dateFormatter.locale = Locale(identifier: "en_US")
			dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

			if let dateFromString = dateFormatter.date(from: self) {
				return dateFromString
			}
		}
		return Date()
	}
}
