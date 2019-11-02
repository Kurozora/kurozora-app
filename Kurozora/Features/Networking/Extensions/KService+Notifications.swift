//
//  KService+Notifications.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SCLAlertView

extension KService {
	/**
		Delete the notification for the given notification id.

		- Parameter notificationID: The id of the notification to be deleted.
		- Parameter successHandler: A closure returning a boolean indicating whether notification deletion is successful.
		- Parameter isSuccess: A boolean value indicating whether notification deletion is successful.
	*/
	func deleteNotification(with notificationID: Int?, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		guard let notificationID = notificationID else { return }

		let request: APIRequest<UserNotification, JSONError> = tron.swiftyJSON.request("user-notifications/\(notificationID)/delete")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
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
	func updateNotification(for notificationID: String?, withStatus read: Int?, withSuccess successHandler: @escaping (Bool) -> Void) {
		guard let notificationID = notificationID else { return }
		guard let read = read else { return }

		let request: APIRequest<UserNotificationsElement, JSONError> = tron.swiftyJSON.request("user-notifications/update")

		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
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
