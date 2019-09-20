//
//  String+NSDate.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 02/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import Foundation

extension String {
	// Does not include seconds
	public func dateWithISO8601() -> Date? {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mmZZZZZ"
		return dateFormatter.date(from: self)! as Date
	}
	public func dateWithISO8601NoMinutes() -> Date? {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HHZZZZZ"
		return dateFormatter.date(from: self)! as Date
	}
}
