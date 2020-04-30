//
//  String+Date.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Foundation

extension String {
	// MARK: - Properties
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
}
