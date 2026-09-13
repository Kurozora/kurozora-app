//
//  DayPart+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit

extension DayPart {
	/// The name of a day part.
	var name: String {
		switch self {
		case .lateNight:
			return L10n.dayPartLateNight
		case .morning:
			return L10n.dayPartMorning
		case .afternoon:
			return L10n.dayPartAfternoon
		case .evening:
			return L10n.dayPartEvening
		}
	}

	/// The hours a day part spans, written for the current locale.
	var rangeDescription: String {
		let start = Self.formatter.string(from: Self.date(atHour: self.startHour))
		let end = Self.formatter.string(from: Self.date(atHour: self.endHour))

		return "\(start) - \(end)"
	}

	/// The formatter that writes a day part's bounds.
	private static var formatter: DateFormatter {
		let formatter = DateFormatter()
		formatter.locale = LanguageManager.shared.locale
		formatter.setLocalizedDateFormatFromTemplate("j:mm")
		return formatter
	}

	/// Returns a date set to the given hour.
	///
	/// - Parameter hour: The hour to set.
	///
	/// - Returns: A date at the given hour.
	private static func date(atHour hour: Int) -> Date {
		return Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date()
	}
}
