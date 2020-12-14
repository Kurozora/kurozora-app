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

		self.setupCategoryActions()
	}

	/// Sets up the notification actions for each of the available categories.
	func setupCategoryActions() {
		// Define the custom actions.
		let showSessionsAction = UNNotificationAction(identifier: "VIEW_SESSION_DETAILS", title: "View Sessions", options: .foreground)
		let showUpdateAction = UNNotificationAction(identifier: "VIEW_SHOW_DETAILS", title: "View Show Details", options: .foreground)
		let newUserFollowAction = UNNotificationAction(identifier: "VIEW_PROFILE_DETAILS", title: "View Profile", options: .foreground)

		// Define the notification type
		let newSessionCategory =
			UNNotificationCategory(identifier: "NEW_SESSION", actions: [showSessionsAction], intentIdentifiers: [], options: [.hiddenPreviewsShowTitle, .allowAnnouncement])
		let showUpdateCategory = UNNotificationCategory(identifier: "SHOW_UPDATE", actions: [showUpdateAction], intentIdentifiers: [], options: [.hiddenPreviewsShowTitle, .allowAnnouncement])
		let newUserFollowCategory = UNNotificationCategory(identifier: "NEW_USER_FOLLOW", actions: [newUserFollowAction], intentIdentifiers: [], options: [.hiddenPreviewsShowTitle])

		// Register notification types.
		UNUserNotificationCenter.current().setNotificationCategories([newSessionCategory, showUpdateCategory, newUserFollowCategory])
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
		let userInfo = response.notification.request.content.userInfo

		// Perform the task associated with the action.
		switch response.actionIdentifier {
		case "VIEW_SESSION_DETAILS":
			self.openSessionsManager()
		case "VIEW_SHOW_DETAILS":
			if let showID = userInfo["SHOW_ID"] as? Int {
				self.openShowDetails(for: showID)
			}
		case "VIEW_PROFILE_DETAILS":
			if let userID = userInfo["USER_ID"] as? Int {
				self.openUserProfile(for: userID)
			}
		default: break
		}

		completionHandler()
	}

	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		if UserSettings.notificationsAllowed {
			#if targetEnvironment(macCatalyst)
			let alertOptions: UNNotificationPresentationOptions = [.list]
			#else
			let alertOptions: UNNotificationPresentationOptions = [.alert]
			#endif
			var notificationPresentationOptions: UNNotificationPresentationOptions = alertOptions

			if UserSettings.notificationsSound {
				notificationPresentationOptions.insert(.sound)
			}
			if UserSettings.notificationsBadge {
				notificationPresentationOptions.insert(.badge)
			}

			switch notification.request.content.categoryIdentifier {
			case "NEW_SESSION":
				completionHandler(notificationPresentationOptions)
			case "SHOW_UPDATE":
				completionHandler(notificationPresentationOptions)
			case "NEW_USER_FOLLOW":
				completionHandler(notificationPresentationOptions)
			default: break
			}
		}

		completionHandler([])
	}

	func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
		if let notificationsSettingsViewController = R.storyboard.notificationSettings.notificationsSettingsViewController() {
			UIApplication.topViewController?.show(notificationsSettingsViewController, sender: nil)
		}
	}
}

// MARK: - Push Notification Actions
extension WorkflowController {
	/// Open the sessions view if the current view is not the sessions view.
	func openSessionsManager() {
		if UIApplication.topViewController as? ManageActiveSessionsController == nil {
			if let manageActiveSessionsController = R.storyboard.accountSettings.manageActiveSessionsController() {
				UIApplication.topViewController?.show(manageActiveSessionsController, sender: nil)
			}
		}
	}

	/**
		Open the show details view for the given show ID.

		- Parameter showID: The id of the show with which the details view will be loaded.
	*/
	func openShowDetails(for showID: Int) {
		if let showDetailsCollectionViewController = R.storyboard.shows.showDetailsCollectionViewController() {
			showDetailsCollectionViewController.showID = showID
			UIApplication.topViewController?.show(showDetailsCollectionViewController, sender: nil)
		}
	}

	/**
		Open the profile view for the given user ID.

		- Parameter userID: The id of the user with which the profile view will be loaded.
	*/
	func openUserProfile(for userID: Int) {
		if let profileTableViewController = R.storyboard.profile.profileTableViewController() {
			profileTableViewController.userID = userID
			UIApplication.topViewController?.show(profileTableViewController, sender: nil)
		}
	}
}
