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

	// MARK: - Initializers
	/**
		Creates a new Date based on the first date detected on a string using data dectors.

		- Parameter string: The string from which the date should be detected.

		- Returns: `null` if a date object cannot be initiated from the given string.
	 */
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
	/**
		 Converts the date to string based on DateFormatter's date style and time style with optional relative date formatting, optional time zone and optional locale.

		 - Parameter dateStyle: The style of the date.
		 - Parameter timeStyle: The style of the time.
		 - Parameter isRelative: Whether relative syntax is used. (Today, Tomorrow, etc.)
		 - Parameter timeZone: The time zone of the time.
		 - Parameter locale: The locale of the string.

		 - Returns: the date as a formatted string.
	 */
	func toString(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style, isRelative: Bool = false, timeZone: TimeZone = TimeZone.current, locale: Locale = Locale.current) -> String {
		let formatter = DateFormatter()
		formatter.dateStyle = dateStyle
		formatter.timeStyle = timeStyle
		formatter.doesRelativeDateFormatting = isRelative
		formatter.timeZone = timeZone
		formatter.locale = locale
		return formatter.string(from: self)
	}

	/**
		 Converts the date to string using the short date and time style.

		 - Parameter style: The style of the formatted string.

		 - Returns: the date as a formatted string.
	 */
	func toString(style: DateFormatter.Style = .short) -> String {
		switch style {
		case .short:
			return self.toString(dateStyle: .short, timeStyle: .short, isRelative: false)
		case .medium:
			return self.toString(dateStyle: .medium, timeStyle: .medium, isRelative: false)
		case .long:
			return self.toString(dateStyle: .long, timeStyle: .long, isRelative: false)
		default:
			return self.toString(dateStyle: .full, timeStyle: .full, isRelative: false)
		}
	}

	/// Formats the date as a AM/PM time.
	func convertToAMPM() -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "hh:mm a"
		return dateFormatter.string(from: self)
	}

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
		Returns the date components of the date object in days, hours and minutes.

		- Returns: the date components of the date object in days, hours and minutes.
	*/
	func etaDate() -> (days: Int, hours: Int, minutes: Int, seconds: Int) {
		let now = Date()
		let cal = Calendar.current
		let unitFlags = Set<Calendar.Component>([.day, .hour, .minute, .second])
		let components = cal.dateComponents(unitFlags, from: now, to: self)

		return (components.day ?? 0, components.hour ?? 0, components.minute ?? 0, components.second ?? 0)
	}

	/**
		Returns the date components of the date object in days, hours and minutes and the eta string of the date string in readable form.

		If `short` is set to `true` the returned string will be in short format. Default value is `false`.

		- Parameter short: Boolean value indicating whether to shorten the returned date string.

		- Returns: the date components of the date object in days, hours and minutes and the eta string of the date string in readable form.
	*/
	func etaForDateWithString(short: Bool = false) -> (days: Int?, hours: Int?, minutes: Int?, etaString: String) {
		let (days, hours, minutes, seconds) = etaDate()

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

	/**
		Returns the eta string of the date in a human readable form.

		If `short` is set to `true` the returned string will be in short format. Default value is `false`.

		- Parameter short: Boolean value indicating whether to shorten the returned date string.

		- Returns: the eta string of the date in a human readable form.
	*/
	func etaStringForDate(short: Bool = false) -> String {
		return etaForDateWithString(short: short).etaString
	}
}
