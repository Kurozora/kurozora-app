//
//  NotificationSegueIdentifier.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/05/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

extension KNotification {
	/**
		List of notification settings.

		```
		case notificationsGrouping = 0
		case bannerStyle = 1
		```
	*/
	enum Settings: Int {
		/// Indicates the view should segue to the notifications grouping options view.
		case notificationsGrouping = 0

		/// Indicates the view should segue to the banner style options view.
		case bannerStyle = 1

		// MARK: - Initializers
		init(stringValue: String?) {
			switch stringValue {
			case R.segue.notificationsSettingsViewController.notificationsGroupingSegue.identifier:
				self = .notificationsGrouping
			case R.segue.notificationsSettingsViewController.bannerStyleSegue.identifier:
				self = .bannerStyle
			default:
				self = .bannerStyle
			}
		}

		// MARK: - Properties
		var segueIdentifier: String {
			switch self {
			case .notificationsGrouping:
				return R.segue.notificationsSettingsViewController.notificationsGroupingSegue.identifier
			case .bannerStyle:
				return R.segue.notificationsSettingsViewController.bannerStyleSegue.identifier
			}
		}
	}
}
