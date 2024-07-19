//
//  KurozoraKit+Reminder.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 18/08/2020.
//

import TRON

extension KurozoraKit {
	/// Fetch the list of reminders for the authenticated user.
	///
	/// - Parameters:
	///    - libraryKind: From which library to get the reminders.
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get reminders response.
	public func getReminders(for libraryKind: KKLibrary.Kind, next: String? = nil, limit: Int = 25) -> RequestSender<ReminderLibraryResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		headers.add(.authorization(bearerToken: self.authenticationKey))

		// Prepare parameters
		let parameters: [String: Any] = [
			"library": libraryKind.rawValue,
			"limit": limit
		]

		// Prepare request
		let meRemindersIndex = next ?? KKEndpoint.Me.Reminders.index.endpointValue
		let request: APIRequest<ReminderLibraryResponse, KKAPIError> = tron.codable.request(meRemindersIndex).buildURL(.relativeToBaseURL)
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
	public func updateReminderStatus(inLibrary libraryKind: KKLibrary.Kind, modelID: String) -> RequestSender<ReminderResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		headers.add(.authorization(bearerToken: self.authenticationKey))

		// Prepare parameters
		let parameters: [String: Any] = [
			"library": libraryKind.rawValue,
			"model_id": modelID
		]

		// Prepare request
		let meRemindersUpdate = KKEndpoint.Me.Reminders.update.endpointValue
		let request: APIRequest<ReminderResponse, KKAPIError> = tron.codable.request(meRemindersUpdate)
			.method(.post)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// The reminder subscription url of the authenticated user.
	public var reminderSubscriptionURL: URL {
		let meRemindersDownload = KKEndpoint.Me.Reminders.download.endpointValue
		let subscriptionURL = tron.urlBuilder.url(forPath: meRemindersDownload)
		return subscriptionURL
	}
}
