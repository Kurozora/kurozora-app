//
//  KurozoraKit+Notifications.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//

import Alamofire
import TRON

extension KurozoraKit {
	/// Fetch the list of notifications for the authenticated user.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getNotifications() -> DataTask<UserNotificationResponse> {
		let meNotificationsIndex = KKEndpoint.Me.Notifications.index.endpointValue
		let request: APIRequest<UserNotificationResponse, KKAPIError> = tron.codable.request(meNotificationsIndex)

		request.headers = headers
		request.headers.add(.authorization(bearerToken: self.authenticationKey))

		request.method = .get
		return request.perform().serializingDecodable(UserNotificationResponse.self, decoder: self.tron.codable.modelDecoder)
	}

	/// Fetch the notification details for the given notification id.
	///
	/// - Parameters:
	///    - notificationID: The id of the notification for which the details should be fetched.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getDetails(forNotificationID notificationID: String) -> DataTask<UserNotificationResponse> {
		let notificationsDetail = KKEndpoint.Me.Notifications.details(notificationID).endpointValue
		let request: APIRequest<UserNotificationResponse, KKAPIError> = tron.codable.request(notificationsDetail)
		request.headers = headers
		request.method = .get
		return request.perform().serializingDecodable(UserNotificationResponse.self, decoder: self.tron.codable.modelDecoder)
	}

	/// Update the read status for the given notification id.
	///
	/// - Parameters:
	///    - notificationID: The id of the notification to be updated. Accepts array of id's or `all`.
	///    - readStatus: The `ReadStatus` value the specified notification should be updated with.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func updateNotification(_ notificationID: String, withReadStatus readStatus: ReadStatus) -> DataTask<UserNotificationUpdateResponse> {
		let neNotificationsUpdate = KKEndpoint.Me.Notifications.update.endpointValue
		let request: APIRequest<UserNotificationUpdateResponse, KKAPIError> = tron.codable.request(neNotificationsUpdate)

		request.headers = headers
		request.headers.add(.authorization(bearerToken: self.authenticationKey))

		request.method = .post
		request.parameters = [
			"notification": notificationID,
			"read": readStatus.rawValue
		]
		return request.perform().serializingDecodable(UserNotificationUpdateResponse.self, decoder: self.tron.codable.modelDecoder)
	}

	/// Delete the notification for the given notification id.
	///
	/// - Parameters:
	///    - notificationID: The id of the notification to be deleted.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func deleteNotification(_ notificationID: String) -> DataTask<KKSuccess> {
		let meNotificationsDelete = KKEndpoint.Me.Notifications.delete(notificationID).endpointValue
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(meNotificationsDelete)

		request.headers = headers
		request.headers.add(.authorization(bearerToken: self.authenticationKey))

		request.method = .post
		return request.perform().serializingDecodable(KKSuccess.self, decoder: self.tron.codable.modelDecoder)
	}
}
