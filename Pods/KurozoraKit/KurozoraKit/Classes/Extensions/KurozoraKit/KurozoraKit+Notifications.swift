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
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func deleteNotification(_ notificationID: String, completion completionHandler: @escaping (_ result: Result<KKSuccess, KKError>) -> Void) {
		let notificationsDelete = self.kurozoraKitEndpoints.notificationsDelete.replacingOccurrences(of: "?", with: "\(notificationID)")
		let request: APIRequest<KKSuccess, KKError> = tron.swiftyJSON.request(notificationsDelete)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		request.method = .post
		request.perform(withSuccess: { success in
			completionHandler(.success(success))
		}, failure: { error in
			if self.services.showAlerts {
				SCLAlertView().showError("Can't delete notification 😔", subTitle: error.message)
			}
			print("Received delete notification error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/**
		Update the read status for the given notification id.

		- Parameter notificationID: The id of the notification to be updated. Accepts array of id's or `all`.
		- Parameter readStatus: The `ReadStatus` value the specified notification should be updated with.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func updateNotification(_ notificationID: String, withReadStatus readStatus: ReadStatus, completion completionHandler: @escaping (_ result: Result<ReadStatus, KKError>) -> Void) {
		let notificationsUpdate = self.kurozoraKitEndpoints.notificationsUpdate
		let request: APIRequest<UserNotificationElement, KKError> = tron.swiftyJSON.request(notificationsUpdate)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		request.method = .post
		request.parameters = [
			"notification": notificationID,
			"read": readStatus.rawValue
		]
		request.perform(withSuccess: { notification in
			completionHandler(.success(notification.readStatus ?? .unread))
		}, failure: { error in
			if self.services.showAlerts {
				SCLAlertView().showError("Can't update notification 😔", subTitle: error.message)
			}
			print("Received update notification error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}
}
