//
//  Date+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 03/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import Foundation

extension Date {
	// MARK: - Properties
	/// The component of which the date consists.
	var components: DateComponents {
		let calendar = Calendar.current
		return calendar.dateComponents([.calendar, .timeZone, .era, .year, .month, .day, .hour, .minute, .second, .nanosecond, .weekday, .weekdayOrdinal, .quarter, .weekOfMonth, .weekOfYear, .yearForWeekOfYear], from: self)
	}

	/// Locale-aware string representations of a relative date or time.
	///
	/// Use the strings that the formatter produces, such as “1 hour ago”, “in 2 weeks”, “yesterday”, and “tomorrow” as standalone strings. Embedding them in other strings may not be grammatically correct.
	var relativeToNow: String {
		return self.formatted(.relative(presentation: .numeric, unitsStyle: .narrow))
	}

	/// Returns a string indicating the group a given date falls in.
	var groupTime: String {
		let timeInterval = Int(-self.timeIntervalSince(Date()))

		// Name of week day
		let formatter = DateFormatter()
		formatter.dateFormat = "EEEE"
		let weekDay = formatter.string(from: self)

		if let yearsAgo = timeInterval / (12 * 4 * 7 * 24 * 60 * 60) as Int?, yearsAgo > 0 {
			return yearsAgo == 1 ? "Last Year" : "\(yearsAgo) Years Ago" // If exactly 1 year, then Last Year, otherwise # Years Ago
		} else if let monthsAgo = timeInterval / (4 * 7 * 24 * 60 * 60) as Int?, monthsAgo > 0 {
			return monthsAgo == 1 ? "Last Month" : "\(monthsAgo) Months ago" // If exactly 1 month, then Last Month, otherwise # Months Ago
		} else if let weeksAgo = timeInterval / (7 * 24 * 60 * 60) as Int?, weeksAgo > 0 {
			return weeksAgo == 1 ? "Last Week" : "\(weeksAgo) Weeks Ago" // If 1 week exactly, then Last Week, otherwise # Weeks Ago
		} else if let daysAgo = timeInterval / (24 * 60 * 60) as Int?, daysAgo > 0 {
			return daysAgo == 1 ? "Yesterday" : weekDay // If 1 day exactly, then Yesterday, otherwise Day Of Week
		} else if let hoursAgo = timeInterval / (60 * 60) as Int?, hoursAgo > 0 {
			return "Earlier Today" // If 1 hour or more, then Earlier Today
		}
		return "Recent" // If less than 1 hour, then Recent
	}

	// MARK: - Initializers
	/// Creates a new `Date` based on the first date detected in a string using data dectors.
	///
	/// - Parameters:
	///    - string: The string from which the date should be detected.
	///
	/// - Returns: `null` if a date object cannot be initiated from the given string.
	init?(from string: String) {
		if string == "now" {
			self = Date.now
			return
		}

		let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
		let matches = detector?.matches(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count))

		if let date = matches?.first?.date {
			self.init()
			self = date
		} else {
			return nil
		}
	}

	// MARK: - Functions
	/// Formats the date as a AM/PM time.
	func convertToAMPM() -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "hh:mm a"
		return dateFormatter.string(from: self)
	}

	/// Formats the date as a 24 hour time.
	func convertTo24Hour() -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "HH:mm:ss"
		return dateFormatter.string(from: self)
	}

	/// Return device's system uptime.
	///
	/// - Returns: device's system uptime.
	static func uptime() -> time_t {
		var boottime = timeval()
		var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]
		var size = MemoryLayout<timeval>.stride

		var now = time_t()
		var uptime: time_t = -1

		time(&now)

		if sysctl(&mib, 2, &boottime, &size, nil, 0) != -1, boottime.tv_sec != 0 {
			uptime = now - boottime.tv_sec
		}

		return uptime
	}

	/// Returns the date components of the date object in days, hours and minutes.
	///
	/// - Returns: the date components of the date object in days, hours and minutes.
	func etaDate() -> (days: Int, hours: Int, minutes: Int, seconds: Int) {
		let now = Date()
		let cal = Calendar.current
		let unitFlags = Set<Calendar.Component>([.day, .hour, .minute, .second])
		let components = cal.dateComponents(unitFlags, from: now, to: self)
		return (components.day ?? 0, components.hour ?? 0, components.minute ?? 0, components.second ?? 0)
	}

	/// Returns the date components of the date object in days, hours and minutes and the eta string of the date string in readable form.
	///
	/// If `short` is set to `true` the returned string will be in short format. Default value is `false`.
	///
	/// - Parameter short: Boolean value indicating whether to shorten the returned date string.
	///
	/// - Returns: the date components of the date object in days, hours and minutes and the eta string of the date string in readable form.
	func etaForDateWithString(short: Bool = false) -> (days: Int?, hours: Int?, minutes: Int?, etaString: String) {
		let (days, hours, minutes, seconds) = self.etaDate()

		var etaTime = ""

		if days != 0 {
			etaTime = short ? "\(days)d \(hours)h" : "\(days)d \(hours)h \(minutes)m"
		} else if hours != 0 {
			etaTime = short ? "\(hours)h \(minutes)m" : "\(hours)h \(minutes)m \(seconds)s"
		} else {
			etaTime = "\(minutes)m \(seconds)s"
		}

		return (days, hours, minutes, etaTime)
	}

	/// Returns the eta string of the date in a human readable form.
	///
	/// If `short` is set to `true` the returned string will be in short format. Default value is `false`.
	///
	/// - Parameter short: Boolean value indicating whether to shorten the returned date string.
	///
	/// - Returns: the eta string of the date in a human readable form.
	func etaStringForDate(short: Bool = false) -> String {
		return self.etaForDateWithString(short: short).etaString
	}

	/// Returns the number of months between the current date and the specified date.
	///
	/// - Parameters:
	///    - date: The date with which the current date is compared.
	///
	/// - Returns: The number of months between the current and the specified date.
	func months(from date: Date) -> Int {
		return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
	}

	/// Returns a new date by setting the time components from a given time string.
	///
	/// - Parameters:
	///   - timeString: The time string in "HH:mm" format.
	///   - calendar: The calendar to use for date calculations. Defaults to the current calendar.
	///
	/// - Returns: A new `Date` with the time components set from the given string, or `nil` if the string is invalid.
	func settingTime(from timeString: String, calendar: Calendar = .app) -> Date? {
		let parts = timeString.split(separator: ":")
		guard
			parts.count == 2,
			let hour = Int(parts[0]),
			let minute = Int(parts[1])
		else { return nil }

		var comps = calendar.dateComponents(in: calendar.timeZone, from: self)
		comps.hour = hour
		comps.minute = minute
		return calendar.date(from: comps)
	}

	/// Converts `self` to its textual representation that contains both the date and time parts. The exact format depends on the user's preferences.
	///
	/// - Parameters:
	///    - date: The style for describing the date part.
	///    - time: The style for describing the time part.
	///
	/// - Returns: A `String` describing `self`.
	func appFormatted(date: Date.FormatStyle.DateStyle, time: Date.FormatStyle.TimeStyle) -> String {
		let formatter = DateFormatter.app(date: date, time: time)
		return formatter.string(from: self)
	}
}

// MARK: - DateFormatter
extension DateFormatter {
	/// A date formatter configured with the user's preferred locale and timezone.
	static var app: DateFormatter {
		let formatter = DateFormatter()
		formatter.calendar = .app
		formatter.timeZone = .app
		formatter.locale = .app
		return formatter
	}

	/// A date formatter configured to display broadcast times in 24-hour format with timezone.
	static var broadcastTime: DateFormatter {
		let formatter = DateFormatter.app
		formatter.dateFormat = "HH:mm '\(formatter.timeZone.localizedName(for: .shortStandard, locale: .app) ?? "UTC")"
		return formatter
	}

	/// A date formatter configured with the user's preferred locale and timezone, and the given date and time styles.
	///
	/// - Parameters:
	///    - date: The style for describing the date part.
	///    - time: The style for describing the time part.
	///
	/// - Returns: A date formatter configured with the user's preferred locale and timezone, and the given date and time styles.
	static func app(date: Date.FormatStyle.DateStyle, time: Date.FormatStyle.TimeStyle) -> DateFormatter {
		let formatter = DateFormatter()
		formatter.dateStyle = .init(date)
		formatter.timeStyle = .init(time)
		formatter.calendar = .app
		return formatter
	}
}

// MARK: - DateFormatter.Style
extension DateFormatter.Style {
	/// Initializes a `DateFormatter.Style` from a `Date.FormatStyle.DateStyle`.
	///
	/// - Parameters:
	///    - style: The style for describing the date part.
	///
	/// - Returns: A `DateFormatter.Style` corresponding to the given `Date.FormatStyle.DateStyle`.
	init(_ style: Date.FormatStyle.DateStyle) {
		switch style {
		case .abbreviated:
			self = .medium
		case .complete:
			self = .full
		case .long:
			self = .long
		case .numeric:
			self = .short
		case .omitted:
			self = .none
		default:
			self = .full
		}
	}

	/// Initializes a `DateFormatter.Style` from a `Date.FormatStyle.TimeStyle`.
	///
	/// - Parameters:
	///    - style: The style for describing the time part.
	///
	/// - Returns: A `DateFormatter.Style` corresponding to the given `Date.FormatStyle.TimeStyle`.
	init(_ style: Date.FormatStyle.TimeStyle) {
		switch style {
		case .complete:
			self = .full
		case .shortened:
			self = .short
		case .standard:
			self = .medium
		case .omitted:
			self = .none
		default:
			self = .medium
		}
	}
}
