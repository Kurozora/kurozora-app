//
//  Date+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 03/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import Foundation

extension Date {
	// MARK: - Functions
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
	func etaForDate() -> (days: Int?, hours: Int?, minutes: Int?) {
		let now = Date()
		let cal = Calendar.current
		let unitFlags = Set<Calendar.Component>([.day, .hour, .minute])
		let components = cal.dateComponents(unitFlags, from: now, to: self)

		return (components.day, components.hour, components.minute)
	}

	/**
		Returns the date components of the date object in days, hours and minutes and the eta string of the date string in readable form.

		If `short` is set to `true` the returned string will be in short format. Default value is `false`.

		- Parameter short: Boolean value indicating whether to shorten the returned date string.

		- Returns: the date components of the date object in days, hours and minutes and the eta string of the date string in readable form.
	*/
	func etaForDateWithString(short: Bool = false) -> (days: Int?, hours: Int?, minutes: Int?, etaString: String) {
		let (days, hours, minutes) = etaForDate()

		var etaTime = ""
		if days != 0 {
			etaTime = short ? "\(String(describing: days))d \(String(describing: hours))h" : "\(String(describing: days))d \(String(describing: hours))h \(String(describing: minutes))m"
		} else if hours != 0 {
			etaTime = "\(String(describing: hours))h \(String(describing: minutes))m"
		} else {
			etaTime = "\(String(describing: minutes))m"
		}

		return (days, hours, minutes, etaTime)
	}

	/**
		Returns the eta string of the date string in readable form.

		If `short` is set to `true` the returned string will be in short format. Default value is `false`.

		- Parameter short: Boolean value indicating whether to shorten the returned date string.

		- Returns: the eta string of the date string in readable form.
	*/
	func etaStringForDate(short: Bool = false) -> String {
		return etaForDateWithString(short: short).etaString
	}
}
