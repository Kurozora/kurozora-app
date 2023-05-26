//
//  KurozoraKit+ReminderShow.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 18/08/2020.
//

import TRON

extension KurozoraKit {
	/// Fetch the list of reminder shows for the authenticated user.
	///
	/// - Parameters:
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get reminders response.
	public func getReminders(from libraryKind: KKLibrary.Kind, next: String? = nil, limit: Int = 25) -> RequestSender<ShowResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		headers.add(.authorization(bearerToken: self.authenticationKey))

		// Prepare parameters
		let parameters: [String: Any] = [
			"library": libraryKind.rawValue,
			"limit": limit
		]

		// Prepare request
		let meReminderShowIndex = next ?? KKEndpoint.Me.ReminderShow.index.endpointValue
		let request: APIRequest<ShowResponse, KKAPIError> = tron.codable.request(meReminderShowIndex).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Update the `ReminderStatus` value of a model in the authenticated user's library.
	///
	/// - Parameters:
	///    - libraryKind: To which library the model belongs.
	///    - modelID: The id of the model whose reminder status should be updated.
	///
	/// - Returns: An instance of `RequestSender` with the results of the update reminder status response.
	public func updateReminderStatus(inLibrary libraryKind: KKLibrary.Kind, modelID: String) -> RequestSender<ReminderShowResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		headers.add(.authorization(bearerToken: self.authenticationKey))

		// Prepare parameters
		let parameters: [String: Any] = [
			"library": libraryKind.rawValue,
			"model_id": modelID
		]

		// Prepare request
		let meReminderShowUpdate = KKEndpoint.Me.ReminderShow.update.endpointValue
		let request: APIRequest<ReminderShowResponse, KKAPIError> = tron.codable.request(meReminderShowUpdate)
			.method(.post)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// The reminder subscription url of the authenticated user.
	public var reminderSubscriptionURL: URL {
		let meReminderShowDownload = KKEndpoint.Me.ReminderShow.download.endpointValue
		let subscriptionURL = tron.urlBuilder.url(forPath: meReminderShowDownload)
		return subscriptionURL
	}
}
