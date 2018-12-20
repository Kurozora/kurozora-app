//
//  Date+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 03/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

extension Date {
	static func timeAgo(_ time: String) -> String {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "US_en")
		formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

		guard let date = formatter.date(from: time) else { return "" }

		let timeInterval = Int(-date.timeIntervalSince(Date()))

		if let yearsAgo = timeInterval / (12*4*7*24*60*60) as Int?, yearsAgo > 0 {
			return "\(yearsAgo)" + (yearsAgo == 1 ? "year" : "years")
		} else if let monthsAgo = timeInterval / (4*7*24*60*60) as Int?, monthsAgo > 0 {
			return "\(monthsAgo)" + (monthsAgo == 1 ? "month" : "months")
		} else if let weeksAgo = timeInterval / (7*24*60*60) as Int?, weeksAgo > 0 {
			return "\(weeksAgo)" + (weeksAgo == 1 ? "week" : "weeks")
		} else if let daysAgo = timeInterval / (24*60*60) as Int?, daysAgo > 0 {
			return "\(daysAgo)" + (daysAgo == 1 ? "day" : "days")
		} else if let hoursAgo = timeInterval / (60*60) as Int?, hoursAgo > 0 {
			return "\(hoursAgo)" + (hoursAgo == 1 ? "hr" : "hrs")
		} else if let minutesAgo = timeInterval / 60 as Int?, minutesAgo > 0 {
			return "\(minutesAgo)" + (minutesAgo == 1 ? "min" : "mins")
		} else {
			return "Just now"
		}
	}
}
