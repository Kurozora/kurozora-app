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
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	public func getReminderShows(next: String? = nil, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<ShowResponse, KKAPIError>) -> Void) {
		let meReminderShowIndex = next ?? KKEndpoint.Me.ReminderShow.index.endpointValue
		let request: APIRequest<ShowResponse, KKAPIError> = tron.codable.request(meReminderShowIndex).buildURL(.relativeToBaseURL)

		request.headers = headers
		request.headers.add(.authorization(bearerToken: self.authenticationKey))

		request.parameters["limit"] = limit

		request.method = .get
		request.perform(withSuccess: { showResponse in
			completionHandler(.success(showResponse))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Reminders 😔", message: error.message)
			}
			print("❌ Received get reminder show error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message)
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/// Update the `ReminderStatus` value of a show in the authenticated user's library.
	///
	/// - Parameters:
	///    - showID: The id of the show whose reminder status should be updated.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	public func updateReminderStatus(forShow showID: Int, completion completionHandler: @escaping (_ result: Result<ReminderStatus, KKAPIError>) -> Void) {
		let meReminderShowUpdate = KKEndpoint.Me.ReminderShow.update.endpointValue
		let request: APIRequest<ReminderShowResponse, KKAPIError> = tron.codable.request(meReminderShowUpdate)

		request.headers = headers
		request.headers.add(.authorization(bearerToken: self.authenticationKey))

		request.method = .post
		request.parameters = [
			"anime_id": showID,
		]
		request.perform(withSuccess: { reminderShowResponse in
			completionHandler(.success(reminderShowResponse.data.reminderStatus))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Update Reminder Status 😔", message: error.message)
			}
			print("❌ Received update reminder status error", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message)
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/// The reminder subscription url of the authenticated user.
	public var reminderSubscriptionURL: URL {
		let meReminderShowDownload = KKEndpoint.Me.ReminderShow.download.endpointValue
		let subscriptionURL = tron.urlBuilder.url(forPath: meReminderShowDownload)
		return subscriptionURL
	}
}
