//
//  KurozoraKit+Me+Feed.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 07/09/2020.
//

import TRON

extension KurozoraKit {
	/// Fetch a list of authenticated user's feed messages.
	///
	/// - Parameters:
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	public func getFeedMessages(next: String? = nil, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<FeedMessageResponse, KKAPIError>) -> Void) {
		let meFeedMessages = next ?? KKEndpoint.Me.Feed.messages.endpointValue
		let request: APIRequest<FeedMessageResponse, KKAPIError> = tron.codable.request(meFeedMessages).buildURL(.relativeToBaseURL)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		request.parameters["limit"] = limit

		request.method = .get
		request.perform(withSuccess: { feedMessageResponse in
			completionHandler(.success(feedMessageResponse))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Feed Messages 😔", message: error.message)
			}
			print("❌ Received get feed messages error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
