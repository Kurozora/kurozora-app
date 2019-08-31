//
//  Date+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 03/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

extension Date {
	/**
		Return device's system uptime.

		- Returns: device's system uptime.
	*/
	static func uptime() -> time_t {
		var boottime = timeval()
		var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]
		var size = MemoryLayout<timeval>.stride

		var now = time_t()
		var uptime: time_t = -1

		time(&now)
		if sysctl(&mib, 2, &boottime, &size, nil, 0) != -1 && boottime.tv_sec != 0 {
			uptime = now - boottime.tv_sec
		}
		return uptime
	}

	/**
		Retunrs string representing how much time has passed since given date.

		- Parameter time: The time to be compared with in string format.

		- Returns: a string representing how much time has passed since given date.
	*/
	static func timeAgo(_ time: String?) -> String {
		guard let time = time else { return "" }
		let date = stringToDateTime(string: time)
		let timeInterval = Int(-date.timeIntervalSince(Date()))

		if let yearsAgo = timeInterval / (12*4*7*24*60*60) as Int?, yearsAgo > 0 {
			return "\(yearsAgo)Y ago"
		} else if let monthsAgo = timeInterval / (4*7*24*60*60) as Int?, monthsAgo > 0 {
			return "\(monthsAgo)M ago"
		} else if let weeksAgo = timeInterval / (7*24*60*60) as Int?, weeksAgo > 0 {
			return "\(weeksAgo)w ago"
		} else if let daysAgo = timeInterval / (24*60*60) as Int?, daysAgo > 0 {
			return "\(daysAgo)d ago"
		} else if let hoursAgo = timeInterval / (60*60) as Int?, hoursAgo > 0 {
			return "\(hoursAgo)h ago"
		} else if let minutesAgo = timeInterval / 60 as Int?, minutesAgo > 0 {
			return "\(minutesAgo)m ago"
		} else {
			return "Just now"
		}
	}

	/**
		Returns a string indicating the group a given date falls in.

		- Parameter date: The string of the date by which the grouping will be determined.

		- Returns: a string indicating the group a given date falls in (i.e. Last Week, Last Month, etc.).
	*/
	static func groupTime(by date: String) -> String {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "US_en")
		formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

		guard let date = formatter.date(from: date) else { return "" }
		let timeInterval = Int(-date.timeIntervalSince(Date()))

		// Name of week day
		formatter.dateFormat = "EEEE"
		let weekDay = formatter.string(from: date)

		if let yearsAgo = timeInterval / (12*4*7*24*60*60) as Int?, yearsAgo > 0 {
			return (yearsAgo == 1 ? "Last Year" : "\(yearsAgo) Years Ago") // If exactly 1 year, then Last Year, otherwise # Years Ago
		} else if let monthsAgo = timeInterval / (4*7*24*60*60) as Int?, monthsAgo > 0 {
			return (monthsAgo == 1 ? "Last Month" : "\(monthsAgo) Months ago") // If exactly 1 month, then Last Month, otherwise # Months Ago
		} else if let weeksAgo = timeInterval / (7*24*60*60) as Int?, weeksAgo > 0 {
			return (weeksAgo == 1 ? "Last Week" : "\(weeksAgo) Weeks Ago") // If 1 week exactly, then Last Week, otherwise # Weeks Ago
		} else if let daysAgo = timeInterval / (24*60*60) as Int?, daysAgo > 0 {
			return (daysAgo == 1 ? "Yesterday" : weekDay) // If 1 day exactly, then Yesterday, otherwise Day Of Week
		} else if let hoursAgo = timeInterval / (60*60) as Int?, hoursAgo > 0 {
			return "Earlier Today" // If 1 hour or more, then Earlier Today
		} else {
			return "Recent" // If less than 1 hour, then Recent
		}
	}

	/**
		Returns a date object for given string.

		- Parameter string: The string that needs to be converted to a date object.

		- Returns: a date object for given string.
	*/
	static func stringToDateTime(string: String?) -> Date {
		guard let string = string else { return Date() }
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "en_US")
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		return dateFormatter.date(from: string)!
	}
}
