//
//  GroupedNotifications.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import KurozoraKit
import Foundation

/// List of notification grouping.
struct GroupedNotifications: nonisolated Hashable {
	/// The title of the section.
	var sectionTitle: String

	/// The notification of the section.
	var sectionNotifications: [UserNotification]

	// MARK: - Functions
	nonisolated func hash(into hasher: inout Hasher) {
		hasher.combine(self.sectionTitle)
	}

	nonisolated static func == (lhs: GroupedNotifications, rhs: GroupedNotifications) -> Bool {
		return lhs.sectionTitle == rhs.sectionTitle
	}
}
