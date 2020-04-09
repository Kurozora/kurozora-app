//
//  KurozoraKit+Notifications.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SCLAlertView

extension KurozoraKit {
	/**
		Delete the notification for the given notification id.

		- Parameter notificationID: The id of the notification to be deleted.
		- Parameter successHandler: A closure returning a boolean indicating whether notification deletion is successful.
		- Parameter isSuccess: A boolean value indicating whether notification deletion is successful.
	*/
	public func deleteNotification(_ notificationID: String, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		let notificationsDelete = self.kurozoraKitEndpoints.notificationsDelete.replacingOccurrences(of: "?", with: "\(notificationID)")
		let request: APIRequest<UserNotification, JSONError> = tron.swiftyJSON.request(notificationsDelete)

		request.headers = headers
		if self._userAuthToken != "" {
			request.headers["kuro-auth"] = self._userAuthToken
		}

		request.method = .post
		request.perform(withSuccess: { notification in
			if let success = notification.success {
				if success {
					successHandler(success)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't delete notification 😔", subTitle: error.message)
			print("Received delete notification error: \(error.message ?? "No message available")")
		})
	}

	/**
		Update the read status for the given notification id.

		- Parameter notificationID: The id of the notification to be updated. Accepts array of id's or `all`.
		- Parameter read: Mark notification as `read` or `unread`.
		- Parameter successHandler: A closure returning a boolean indicating whether notification deletion is successful.
		- Parameter isSuccess: A boolean value indicating whether notification deletion is successful.
	*/
	public func updateNotification(_ notificationID: String, withStatus read: Int, withSuccess successHandler: @escaping (Bool) -> Void) {
		let notificationsUpdate = self.kurozoraKitEndpoints.notificationsUpdate
		let request: APIRequest<UserNotificationsElement, JSONError> = tron.swiftyJSON.request(notificationsUpdate)

		request.headers = headers
		if self._userAuthToken != "" {
			request.headers["kuro-auth"] = self._userAuthToken
		}

		request.method = .post
		request.parameters = [
			"notification": notificationID,
			"read": read
		]
		request.perform(withSuccess: { notification in
			if let read = notification.read {
				successHandler(read)
			}
		}, failure: { error in
			SCLAlertView().showError("Can't update notification 😔", subTitle: error.message)
			print("Received update notification error: \(error.message ?? "No message available")")
		})
	}
}
