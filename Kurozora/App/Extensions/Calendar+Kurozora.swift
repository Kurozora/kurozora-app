//
//  Calendar+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/09/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit

extension Calendar {
	/// A calendar configured with the user's preferred locale and timezone.
	static var app: Calendar {
		var calendar = Calendar.current
		calendar.timeZone = .app
		calendar.locale = .app
		return calendar
	}
}

extension Locale {
	/// A locale configured with the user's preferred language.
	static var app: Locale {
		if let preferredLocale = User.current?.attributes.preferredLanguage {
			return Locale(identifier: preferredLocale)
		}
		return .current
	}
}

extension TimeZone {
	/// A timezone configured with the user's preferred timezone.
	static var app: TimeZone {
		if let preferredTimezone = User.current?.attributes.preferredTimezone {
			return TimeZone(identifier: preferredTimezone) ?? .current
		}
		return .current
	}
}
