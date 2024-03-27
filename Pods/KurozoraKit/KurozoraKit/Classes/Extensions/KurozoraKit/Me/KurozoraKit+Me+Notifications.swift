//
//  KurozoraKit+Notifications.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//

import TRON

extension KurozoraKit {
	/// Fetch the list of notifications for the authenticated user.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get notifications response.
	public func getNotifications() -> RequestSender<UserNotificationResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		headers.add(.authorization(bearerToken: self.authenticationKey))

		// Prepare request
		let meNotificationsIndex = KKEndpoint.Me.Notifications.index.endpointValue
		let request: APIRequest<UserNotificationResponse, KKAPIError> = tron.codable.request(meNotificationsIndex)
			.method(.get)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Fetch the notification details for the given notification id.
	///
	/// - Parameters:
	///    - notificationID: The id of the notification for which the details should be fetched.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get notification details response.
	public func getDetails(forNotificationID notificationID: String) -> RequestSender<UserNotificationResponse, KKAPIError> {
		// Prepare request
		let notificationsDetail = KKEndpoint.Me.Notifications.details(notificationID).endpointValue
		let request: APIRequest<UserNotificationResponse, KKAPIError> = tron.codable.request(notificationsDetail)
			.method(.get)
			.headers(self.headers)

		// Send request
		return request.sender()
	}

	/// Update the read status for the given notification id.
	///
	/// - Parameters:
	///    - notificationID: The id of the notification to be updated. Accepts array of id's or `all`.
	///    - readStatus: The `ReadStatus` value the specified notification should be updated with.
	///
	/// - Returns: An instance of `RequestSender` with the results of the update notification response.
	public func updateNotification(_ notificationID: String, withReadStatus readStatus: ReadStatus) -> RequestSender<UserNotificationUpdateResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		headers.add(.authorization(bearerToken: self.authenticationKey))

		// Prepare parameters
		let parameters: [String: Any] = [
			"notification": notificationID,
			"read": readStatus.rawValue
		]

		// Prepare request
		let neNotificationsUpdate = KKEndpoint.Me.Notifications.update.endpointValue
		let request: APIRequest<UserNotificationUpdateResponse, KKAPIError> = tron.codable.request(neNotificationsUpdate)
			.method(.post)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Delete the notification for the given notification id.
	///
	/// - Parameters:
	///    - notificationID: The id of the notification to be deleted.
	///
	/// - Returns: An instance of `RequestSender` with the results of the delete notification response.
	public func deleteNotification(_ notificationID: String) -> RequestSender<KKSuccess, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		headers.add(.authorization(bearerToken: self.authenticationKey))

		// Prepare request
		let meNotificationsDelete = KKEndpoint.Me.Notifications.delete(notificationID).endpointValue
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(meNotificationsDelete)
			.method(.post)
			.headers(headers)

		// Send request
		return request.sender()
	}
}
