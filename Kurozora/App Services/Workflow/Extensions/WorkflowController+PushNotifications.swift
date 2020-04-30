//
//  WorkflowController+PushNotifications.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/02/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

// MARK: - Push Notifications
extension WorkflowController {
	func scheduleNotification(_ title: String, body: String) {
		// Prepare local notification
		let date = Date()
		let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
		let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
		let identifier = "Local Notification"

		// Prepare actions for notification
		let showSessionAction = UNNotificationAction(identifier: "NEW_SESSION", title: "Show", options: [])
		let sessionActions = "Session Actions"
		let category = UNNotificationCategory(identifier: sessionActions, actions: [showSessionAction], intentIdentifiers: [], options: [])

		// Create notification content
		let content = UNMutableNotificationContent()
		content.title = "\(title)"
		content.body = "\(body)"
		content.sound = .default
		content.badge = 1
		content.categoryIdentifier = sessionActions
		let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

		// Add notification actions
		notificationCenter.setNotificationCategories([category])
		notificationCenter.delegate = self

		// Add notification to notification center
		notificationCenter.add(request) { (error) in
			if let error = error {
				print("Error \(error.localizedDescription)")
			}
		}
	}

	/**
		Returns a boolean value indicating whether the app should register the current device for push notifications.

		A value of `true` is returned if the device has not been registered before or if the last registration date is an old week. For all other cases `false` is returned.

		- Returns: a boolean value indicating whether the app should register the current device for push notifications.
	*/
	fileprivate func shouldRegisterForPushNotifications() -> Bool {
		if let lastDate = UserSettings.lastNotificationRegistrationRequest {
			let weekFromLastDate = lastDate.addingTimeInterval(604800)
			return Date() >= weekFromLastDate
		}
		return true
	}

	/// Asks the user for permission to register the device for push notifications.
	func registerForPushNotifications() {
		if shouldRegisterForPushNotifications() {
			UserSettings.set(Date(), forKey: .lastNotificationRegistrationRequest)
			UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
				guard granted else { return }
				self?.getNotificationSettings()
			}
		}
	}

	/// Registers the device for push notifications if authorized.
	func getNotificationSettings() {
		UNUserNotificationCenter.current().getNotificationSettings { settings in
			guard settings.authorizationStatus == .authorized else { return }
			DispatchQueue.main.async {
				UIApplication.shared.registerForRemoteNotifications()
			}
		}
	}
}

// MARK: - UNUserNotificationCenterDelegate
extension WorkflowController: UNUserNotificationCenterDelegate {
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		// Perform the task associated with the action.
		switch response.actionIdentifier {
		case "NEW_SESSION":
			self.showSessions()
		default:
			break
		}

		// Always call the completion handler when done.
		completionHandler()
	}
}
