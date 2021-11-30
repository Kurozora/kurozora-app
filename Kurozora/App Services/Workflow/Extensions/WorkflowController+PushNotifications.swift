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
		print("----- Schedule notification.")

		// Create notification content
		let content = UNMutableNotificationContent()
		content.title = "\(title)"
		content.body = "\(body)"
		content.sound = .default
		content.badge = 1
		content.categoryIdentifier = NotificationKind.newSession.identifierValue

		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
		let request = UNNotificationRequest(identifier: "LocalNotification", content: content, trigger: trigger)

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
		print("----- Should register for push notifications")
		if let lastDate = UserSettings.lastNotificationRegistrationRequest {
			let weekFromLastDate = lastDate.addingTimeInterval(604800)
			return Date() >= weekFromLastDate
		}
		return true
	}

	/// Asks the user for permission to register the device for push notifications.
	func registerForPushNotifications() {
		print("----- Register for push notifications.")
		if shouldRegisterForPushNotifications() {
			UserSettings.set(Date(), forKey: .lastNotificationRegistrationRequest)
			UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .providesAppNotificationSettings]) { [weak self] granted, _ in
				guard granted else { return }
				self?.getNotificationSettings()
			}
		}

		self.setupCategoryActions()
	}

	/// Sets up the notification actions for each of the available categories.
	func setupCategoryActions() {
		print("----- Setup categrory actions.")
		var notificationCategories: Set<UNNotificationCategory> = []

		// Configure notification categories.
		NotificationKind.allCases.forEach { notificationKind in
			let notificationCategory = UNNotificationCategory(identifier: notificationKind.identifierValue, actions: notificationKind.actionValue.actionValue, intentIdentifiers: [], options: [.hiddenPreviewsShowTitle])
			notificationCategories.insert(notificationCategory)
		}

		// Register notification categories.
		UNUserNotificationCenter.current().setNotificationCategories(notificationCategories)
	}

	/// Registers the device for push notifications if authorized.
	func getNotificationSettings() {
		print("----- Get notification settings.")
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
		print("----- Notification center received response.")
		let userInfo = response.notification.request.content.userInfo

		// Perform the task associated with the action.
		switch response.actionIdentifier {
		case NotificationKind.Action.viewSessionDetails.identifierValue:
			self.openSessionsManager()
		case NotificationKind.Action.viewShowDetails.identifierValue:
			if let showID = userInfo["SHOW_ID"] as? Int {
				self.openShowDetails(for: showID)
			}
		case NotificationKind.Action.viewProfileDetails.identifierValue:
			if let userID = userInfo["USER_ID"] as? Int {
				self.openUserProfile(for: userID)
			}
		default: break
		}

		completionHandler()
	}

	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		print("----- Notification center will present notification.")
		if !UserSettings.notificationsAllowed {
			completionHandler([])
			return
		}

		var notificationPresentationOptions: UNNotificationPresentationOptions = [.list, .banner]

		if UserSettings.notificationsSound {
			notificationPresentationOptions.insert(.sound)
		}
		if UserSettings.notificationsBadge {
			notificationPresentationOptions.insert(.badge)
		}

		completionHandler(notificationPresentationOptions)
	}

	func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
		print("----- Notification center open settings.")
		self.openNotificationSettings()
	}
}

// MARK: - Push Notification Actions
extension WorkflowController {
	/// Open the notification settings view if the current view is not the sessions view.
	func openNotificationSettings(in viewController: UIViewController? = UIApplication.topViewController) {
		if UIApplication.topViewController as? NotificationsSettingsViewController == nil {
			if let notificationsSettingsViewController = R.storyboard.notificationSettings.notificationsSettingsViewController() {
				viewController?.show(notificationsSettingsViewController, sender: nil)
			}
		}
	}

	/// Open the sessions view if the current view is not the sessions view.
	func openSessionsManager(in viewController: UIViewController? = UIApplication.topViewController) {
		if UIApplication.topViewController as? ManageActiveSessionsController == nil {
			if let manageActiveSessionsController = R.storyboard.accountSettings.manageActiveSessionsController() {
				viewController?.show(manageActiveSessionsController, sender: nil)
			}
		}
	}

	/**
		Open the show details view for the given show ID.

		- Parameter showID: The id of the show with which the details view will be loaded.
	*/
	func openShowDetails(for showID: Int, in viewController: UIViewController? = UIApplication.topViewController) {
		let showDetailsCollectionViewController = ShowDetailsCollectionViewController.`init`(with: showID)
		viewController?.show(showDetailsCollectionViewController, sender: nil)
	}

	/**
		Open the profile view for the given user ID.

		- Parameter userID: The id of the user with which the profile view will be loaded.
	*/
	func openUserProfile(for userID: Int, in viewController: UIViewController? = UIApplication.topViewController) {
		let profileTableViewController = ProfileTableViewController.`init`(with: userID)
		viewController?.show(profileTableViewController, sender: nil)
	}

	/**
		Open the feed message details view for the given feed message ID.

		- Parameter userID: The id of the feed message with which the feed message details view will be loaded.
	*/
	func openFeedMessage(for feedMessageID: Int, in viewController: UIViewController? = UIApplication.topViewController) {
		let fmDetailsTableViewController = FMDetailsTableViewController.`init`(with: feedMessageID)
		viewController?.show(fmDetailsTableViewController, sender: nil)
	}
}
