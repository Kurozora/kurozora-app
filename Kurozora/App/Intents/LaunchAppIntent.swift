//
//  LaunchAppIntent.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/06/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import AppIntents
import SwiftUI

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
struct LaunchAppIntent: OpenIntent, ControlConfigurationIntent, WidgetConfigurationIntent {
	static let title: LocalizedStringResource = "Launch Kurozora"
	static let description = IntentDescription("Open Kurozora to your preferred page.")

	@Parameter(title: "Page", default: .home)
	var target: LaunchAppEnum

	/// Launch your app when the system triggers this intent.
	static let openAppWhenRun: Bool = true

	@MainActor
	func perform() async throws -> some IntentResult {
		guard
			let url = self.target.deeplink,
			let application = UIApplication.value(forKeyPath: #keyPath(UIApplication.shared)) as? UIApplication
		else {
			return .result()
		}

		await application.open(url)

		return .result()
	}
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
enum LaunchAppEnum: String, AppEnum {
	case home
	case schedule
	case library
	case feed
	case notifications
	case search

	static let typeDisplayRepresentation = TypeDisplayRepresentation("Kurozora’s Screens")

	static let caseDisplayRepresentations = [
		LaunchAppEnum.home: DisplayRepresentation("Home"),
		LaunchAppEnum.schedule: DisplayRepresentation("Schedule"),
		LaunchAppEnum.library: DisplayRepresentation("Library"),
		LaunchAppEnum.feed: DisplayRepresentation("Feed"),
		LaunchAppEnum.notifications: DisplayRepresentation("Notifications"),
		LaunchAppEnum.search: DisplayRepresentation("Search")
	]

	var name: String {
		return self.rawValue.capitalized
	}

	var deeplink: URL? {
		switch self {
		case .home:
			URL(string: "kurozora://home")
		case .schedule:
			URL(string: "kurozora://schedule")
		case .library:
			URL(string: "kurozora://library")
		case .feed:
			URL(string: "kurozora://feed")
		case .notifications:
			URL(string: "kurozora://notifications")
		case .search:
			URL(string: "kurozora://search")
		}
	}
}
