//
//  KurozoraKit+Notifications.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON

extension KurozoraKit {
	/// Fetch the list of notifications for the authenticated user.
	///
	/// - Parameters:
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	public func getNotifications(completion completionHandler: @escaping (_ result: Result<[UserNotification], KKAPIError>) -> Void) {
		let meNotificationsIndex = KKEndpoint.Me.Notifications.index.endpointValue
		let request: APIRequest<UserNotificationResponse, KKAPIError> = tron.codable.request(meNotificationsIndex)

		request.headers = headers
		request.headers.add(.authorization(bearerToken: self.authenticationKey))

		request.method = .get
		request.perform(withSuccess: { userNotificationResponse in
			completionHandler(.success(userNotificationResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Notifications 😔", message: error.message)
			}
			print("❌ Received get notification error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/// Fetch the notification details for the given notification id.
	///
	/// - Parameters:
	///    - notificationID: The id of the notification for which the details should be fetched.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	public func getDetails(forNotificationID notificationID: String, completion completionHandler: @escaping (_ result: Result<[UserNotification], KKAPIError>) -> Void) {
		let notificationsDetail = KKEndpoint.Me.Notifications.details(notificationID).endpointValue
		let request: APIRequest<UserNotificationResponse, KKAPIError> = tron.codable.request(notificationsDetail)
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { userNotificationResponse in
			completionHandler(.success(userNotificationResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Notification's Details 😔", message: error.message)
			}
			print("❌ Received get notification details error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/// Update the read status for the given notification id.
	///
	/// - Parameters:
	///    - notificationID: The id of the notification to be updated. Accepts array of id's or `all`.
	///    - readStatus: The `ReadStatus` value the specified notification should be updated with.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	public func updateNotification(_ notificationID: String, withReadStatus readStatus: ReadStatus, completion completionHandler: @escaping (_ result: Result<ReadStatus, KKAPIError>) -> Void) {
		let neNotificationsUpdate = KKEndpoint.Me.Notifications.update.endpointValue
		let request: APIRequest<UserNotificationUpdateResponse, KKAPIError> = tron.codable.request(neNotificationsUpdate)

		request.headers = headers
		request.headers.add(.authorization(bearerToken: self.authenticationKey))

		request.method = .post
		request.parameters = [
			"notification": notificationID,
			"read": readStatus.rawValue
		]
		request.perform(withSuccess: { userNotificationUpdateResponse in
			completionHandler(.success(userNotificationUpdateResponse.data.readStatus))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Update Notification 😔", message: error.message)
			}
			print("❌ Received update notification error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
		})
	}

	/// Delete the notification for the given notification id.
	///
	/// - Parameters:
	///    - notificationID: The id of the notification to be deleted.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	public func deleteNotification(_ notificationID: String, completion completionHandler: @escaping (_ result: Result<KKSuccess, KKAPIError>) -> Void) {
		let meNotificationsDelete = KKEndpoint.Me.Notifications.delete(notificationID).endpointValue
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(meNotificationsDelete)

		request.headers = headers
		request.headers.add(.authorization(bearerToken: self.authenticationKey))

		request.method = .post
		request.perform(withSuccess: { success in
			completionHandler(.success(success))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Delete Notification 😔", message: error.message)
			}
			print("❌ Received delete notification error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
		})
	}
}
