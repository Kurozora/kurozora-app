//
//  String+Date.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 07/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Foundation

extension String {
	/// Returns a `Date` object for the given string.
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
