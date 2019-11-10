//
//  String+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

extension String {
	// MARK: - Properties
	/// Returns the initial characters (up to 2 characters) of the string separated by a whitespace or a dot. For example "John Appleseed" and "John.Appleseed" returns "JA". Returned value is case insensitive which means "john appleseed" will return "ja".
	var initials: String {
		let stringSeparatedByWhiteSpace = self.components(separatedBy: [".", " "])
		let initials = stringSeparatedByWhiteSpace.reduce("") { ($0 == "" ? "" : "\($0.first ?? " ")") + "\($1.first ?? " ")" }
		return initials
	}

	/// Returns a string indicating the group a given date falls in.
	var groupTime: String {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "US_en")
		formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

		guard let date = formatter.date(from: self) else { return "" }
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
		}
		return "Recent" // If less than 1 hour, then Recent
	}

	/// Returns a string with a medium fomatted date.
	var mediumDate: String {
		return mediumFormatter.string(from: self.toDate)
	}

	/// Returns a string with a medium fomatted date as time.
	var mediumDateTime: String {
		return mediumDateTimeFormatter.string(from: self.toDate)
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
				formatter.dateStyle = DateFormatter.Style.medium
				return formatter
			}()
		}
		return Static.instance
	}

	/// Retunrs string representing how much time has passed since given date.
	var timeAgo: String {
		let date = self.toDate
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
		}
		return "Just now"
	}

	/// Returns a date object for given string.
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

	/// Returns a UIImage from the string. If no image can be created then `nil` is returns.
	var toImage: UIImage? {
		let frame = CGRect(x: 0, y: 0, width: 50, height: 50)

		// Create UILabel that holds the string
		let nameLabel = UILabel(frame: frame)
		nameLabel.textAlignment = .center
		nameLabel.backgroundColor = .lightGray
		nameLabel.textColor = .white
		nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
		nameLabel.text = self

		// Create a screenshot of the UILabel and return the resulted image
		UIGraphicsBeginImageContext(frame.size)
		if let currentContext = UIGraphicsGetCurrentContext() {
			nameLabel.layer.render(in: currentContext)
			let nameImage = UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(.alwaysOriginal)
			return nameImage
		}
		return nil
	}

	// MARK: - Functions
	/**
		Returns an estimated time of arrival date for a given string.

		- Returns: an estimated time of arrival from a given string.
	*/
	func etaDate() -> (days: Int?, hours: Int?, minutes: Int?) {
		let now = Date()
		let cal = Calendar.current
		let unitFlags = Set<Calendar.Component>([.day, .hour, .minute])
		let components = cal.dateComponents(unitFlags, from: now, to: self.toDate)

		return (components.day, components.hour, components.minute)
	}

	/**
		Returns an estimated time of arrival date and string for a given string.

		- Parameter shortend: A boolean value indicating whether to return the short or long version of the eta string.
		- Returns: an estimated time of arrival date and string for a given string.
	*/
	func etaDateAndString(shortend: Bool = false) -> (days: Int?, hours: Int?, minutes: Int?, etaString: String) {
		let (days, hours, minutes) = etaDate()

		var etaTime = ""
		if days != 0 {
			etaTime = shortend ? "\(String(describing: days))d \(String(describing: hours))h" : "\(String(describing: days))d \(String(describing: hours))h \(String(describing: minutes))m"
		} else if hours != 0 {
			etaTime = "\(String(describing: hours))h \(String(describing: minutes))m"
		} else {
			etaTime = "\(String(describing: minutes))m"
		}
		return (days, hours, minutes, etaTime)
	}

	/**
		Returns an estimated time of arrival string for a given string.

		- Parameter shortend: A boolean value indicating whether to return the short or long version of the eta string.
		- Returns: an estimated time of arrival from a given string.
	*/
	func etaString(shortend: Bool = false) -> String {
		return etaDateAndString(shortend: shortend).etaString
	}
}
