//
//  KCalendarApp.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

enum KCalendarApp: Int, CaseIterable {
	// MARK: - Cases
	case calendar = 0
	case fantastical
	case googleCalendar
	case outlook
	case protonCalendar
	case yahooMail
	case copyLink

	// MARK: - Properties
	/// The display name of the calendar destination.
	var stringValue: String {
		switch self {
		case .calendar:
			return "Calendar"
		case .fantastical:
			return "Fantastical"
		case .googleCalendar:
			return "Google Calendar"
		case .outlook:
			return "Outlook"
		case .protonCalendar:
			return "Proton Calendar"
		case .yahooMail:
			return "Yahoo Calendar"
		case .copyLink:
			return L10n.copySubscriptionLink
		}
	}

	/// The image representing the calendar destination.
	var image: UIImage? {
		switch self {
		case .calendar:
			return .Calendars.calendar
		case .fantastical:
			return .Calendars.fantastical
		case .googleCalendar:
			return .Calendars.googleCalendar
		case .outlook:
			return .Calendars.outlook
		case .protonCalendar:
			return .Calendars.protonCalendar
		case .yahooMail:
			return .Calendars.yahooMail
		case .copyLink:
			return UIImage(systemName: "doc.on.doc")
		}
	}

	/// The App Store URL used as a fallback when a deep-link destination isn't installed.
	var storeURL: URL? {
		switch self {
		case .fantastical:
			return URL(string: "https://apps.apple.com/app/id718043190")
		case .protonCalendar:
			return URL(string: "https://apps.apple.com/app/id1514709943")
		case .calendar, .googleCalendar, .yahooMail, .outlook, .copyLink:
			return nil
		}
	}

	/// Whether this case copies the subscription link instead of opening a URL.
	var isCopyAction: Bool {
		return self == .copyLink
	}

	/// Indicates whether the destination URL is a custom-scheme deep link.
	var isDeepLink: Bool {
		switch self {
		case .calendar, .fantastical, .protonCalendar:
			return true
		case .googleCalendar, .yahooMail, .outlook, .copyLink:
			return false
		}
	}

	// MARK: - Functions
	/// Builds the destination URL for the given calendar app from the supplied webcal subscription URL.
	///
	/// - Parameter webcalURL: The webcal-scheme subscription URL.
	///
	/// - Returns: The URL to open for the chosen calendar app, or `nil` for actions that do not open a URL.
	func subscriptionURL(from webcalURL: URL) -> URL? {
		let allowedCharacters = CharacterSet.urlQueryAllowed
		let encodedWebcal = webcalURL.absoluteString.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? webcalURL.absoluteString

		switch self {
		case .calendar:
			return webcalURL
		case .fantastical:
			return URL(string: "x-fantastical3://addcalendar?url=\(encodedWebcal)")
		case .googleCalendar:
			return URL(string: "https://calendar.google.com/calendar/r?cid=\(encodedWebcal)")
		case .outlook:
			let encodedName = "Kurozora".addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? "Kurozora"
			return URL(string: "https://outlook.live.com/calendar/0/addfromweb?url=\(encodedWebcal)&name=\(encodedName)")
		case .protonCalendar:
			return URL(string: "protoncalendar://")
		case .yahooMail:
			return URL(string: "https://calendar.yahoo.com/?v=60&view=cal&type=24&url=\(encodedWebcal)")
		case .copyLink:
			return nil
		}
	}
}
