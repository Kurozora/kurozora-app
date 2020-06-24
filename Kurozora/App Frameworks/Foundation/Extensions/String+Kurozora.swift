//
//  String+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

extension String {
	// MARK: - Properties
	/// Returns the initial characters (up to 2 characters) of the string separated by a whitespace or a dot. For example "John Appleseed" and "John.Appleseed" returns "JA". Returned value is case insensitive which means "john appleseed" will return "ja".
	var initials: String {
		let stringSeparatedByWhiteSpace = self.components(separatedBy: [".", " ", "-"])
		let initials = stringSeparatedByWhiteSpace.reduce("") { ($0 == "" ? "" : "\($0.first ?? " ")") + "\($1.first ?? " ")" }
		return initials
	}

	/// Returns a string indicating the group a given date falls in.
	var groupTime: String {
		guard let dateTime = self.dateTime else { return "" }
		let timeInterval = Int(-dateTime.timeIntervalSince(Date()))

		// Name of week day
		let formatter = DateFormatter()
		formatter.dateFormat = "EEEE"
		let weekDay = formatter.string(from: dateTime)

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
		}
		return "Recent" // If less than 1 hour, then Recent
	}

	/// Returns a string with a medium fomatted date.
	var mediumDate: String {
		guard let dateTime = self.dateTime else { return "" }
		return mediumFormatter.string(from: dateTime)
	}

	/// Returns a string with a medium fomatted date and time.
	var mediumDateTime: String {
		guard let dateTime = self.dateTime else { return "" }
		return mediumDateTimeFormatter.string(from: dateTime)
	}

	/// Returns an instance of a DateFormatter with medium date style and time style.
	private var mediumDateTimeFormatter: DateFormatter {
		struct Static {
			static let instance: DateFormatter = {
				let formatter = DateFormatter()
				formatter.dateStyle = DateFormatter.Style.medium
				formatter.timeStyle = DateFormatter.Style.medium
				return formatter
			}()
		}
		return Static.instance
	}

	/// Returns an instance of a DateFormatter with medium date style.
	private var mediumFormatter: DateFormatter {
		struct Static {
			static let instance: DateFormatter = {
				let formatter = DateFormatter()
				formatter.dateStyle = .medium
				return formatter
			}()
		}
		return Static.instance
	}

	/// Retunrs string representing how much time has passed since given date.
	var timeAgo: String {
		guard let dateTime = self.dateTime else { return "" }
		let timeInterval = Int(-dateTime.timeIntervalSince(Date()))

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
		}
		return "Just now"
	}
}
