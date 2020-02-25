//
//  WorkflowController+In-AppNotifications.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/02/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import NotificationBannerSwift

// MARK: - In-App Notification handlers
extension WorkflowController {
	/// Open the sessions view if the current view is not the sessions view.
	func showSessions() {
		if UIApplication.topViewController as? ManageActiveSessionsController == nil {
			if let manageActiveSessionsController = R.storyboard.accountSettings.manageActiveSessionsController() {
				manageActiveSessionsController.dismissEnabled = true
				let kurozoraNavigationController = KNavigationController(rootViewController: manageActiveSessionsController)
				UIApplication.topViewController?.present(kurozoraNavigationController)
			}
		}
	}

	/**
		Handles which type of notification to show according to the user's notification settings.

		- Parameter device: The name of the device a new session was created on.
	*/
	func notificationsHandler(_ device: String) {
		// If notifications enabled
		if UserSettings.notificationsAllowed {
			let alertType = UserSettings.alertType
			var banner: BaseNotificationBanner?

			if alertType == 0 {
				banner = FloatingNotificationBanner(title: "New sign in detected from " + device, subtitle: "(Tap to manage your sessions!)", style: .info)
			} else if alertType == 1 {
				banner = FloatingNotificationBanner(title: "New sign in detected from " + device, subtitle: "(Tap to manage your sessions!)", leftView: UIImageView(image: R.image.icons.session()), style: .info)
			} else if alertType == 2 {
				banner = StatusBarNotificationBanner(title: "New sign in detected from " + device, style: .info)
			}

			// Notification haptic feedback and vibration
			banner?.haptic = (UserSettings.notificationsVibration) ? .heavy : .none

			// Notification sound feedback
//			banner?.sound = (UserSettings.notificationsSound) ? .success : .none

			// Notification persistency
			if UserSettings.notificationsPersistent == 0 {
				banner?.autoDismiss = true
			} else {
				banner?.autoDismiss = false
				banner?.onSwipeUp = {
					banner?.dismiss()
				}
			}
			banner?.onTap = {
				self.showSessions()
			}

			if alertType == 0 || alertType == 1 {
				(banner as? FloatingNotificationBanner)?.show(cornerRadius: 10, shadowBlurRadius: 15, shadowCornerRadius: 15)
			} else {
				banner?.show()
			}
		}
	}
}
