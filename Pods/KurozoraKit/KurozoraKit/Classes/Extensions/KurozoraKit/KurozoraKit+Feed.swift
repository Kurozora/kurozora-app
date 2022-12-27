//
//  KurozoraKit+Feed.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//

import TRON

extension KurozoraKit {
	/// Fetch a list of feed messages for the given user identity.
	///
	/// - Parameters:
	///    - userIdentity: The identity of the user whose feed messages to fetch.
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	public func getFeedMessages(forUser userIdentity: UserIdentity, next: String? = nil, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<FeedMessageResponse, KKAPIError>) -> Void) {
		let usersFeedMessages = next ?? KKEndpoint.Users.feedMessages(userIdentity).endpointValue
		let request: APIRequest<FeedMessageResponse, KKAPIError> = tron.codable.request(usersFeedMessages).buildURL(.relativeToBaseURL)

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
			print("┌ Server message:", error.message)
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/// Fetch a list of home feed messages.
	///
	/// - Parameters:
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	public func getFeedHome(next: String? = nil, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<FeedMessageResponse, KKAPIError>) -> Void) {
		let feedHome = next ?? KKEndpoint.Feed.home.endpointValue
		let request: APIRequest<FeedMessageResponse, KKAPIError> = tron.codable.request(feedHome).buildURL(.relativeToBaseURL)

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
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Home Feed 😔", message: error.message)
			}
			print("❌ Received get feed home error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message)
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/// Fetch a list of explore feed messages.
	///
	/// - Parameters:
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	public func getFeedExplore(next: String? = nil, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<FeedMessageResponse, KKAPIError>) -> Void) {
		let feedExplore = next ?? KKEndpoint.Feed.explore.endpointValue
		let request: APIRequest<FeedMessageResponse, KKAPIError> = tron.codable.request(feedExplore).buildURL(.relativeToBaseURL)

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
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Explore Feed 😔", message: error.message)
			}
			print("❌ Received get feed explore error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message)
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/// Post a new message to the feed.
	///
	/// If the message is a reply or a re-share, then also supply the parent message's ID.
	///
	/// - Parameters:
	///    - feedMessageRequest: An instance of `FeedMessageRequest` containing the new feed message details.
	///
	/// - Returns: An instance of `RequestSender` with the results of the post feed message response.
	public func postFeedMessage(_ feedMessageRequest: FeedMessageRequest) -> RequestSender<FeedMessageResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		headers.add(.authorization(bearerToken: self.authenticationKey))

		// Prepare parameters
		var parameters: [String: Any] = [:]
		parameters = [
			"content": feedMessageRequest.content,
			"is_nsfw": feedMessageRequest.isNSFW,
			"is_spoiler": feedMessageRequest.isSpoiler
		]
		if let messageID = feedMessageRequest.parentIdentity?.id {
			parameters["parent_id"] = messageID
			parameters["is_reply"] = feedMessageRequest.isReply
			parameters["is_reshare"] = feedMessageRequest.isReShare
		}

		// Prepare request
		let feedPost = KKEndpoint.Feed.post.endpointValue
		let request: APIRequest<FeedMessageResponse, KKAPIError> = tron.codable.request(feedPost)
			.method(.post)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Fetch the details of the given feed message id.
	///
	/// - Parameters:
	///    - messageID: The id of the message for which the details should be fetched.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	public func getDetails(forFeedMessage messageID: Int, completion completionHandler: @escaping (_ result: Result<[FeedMessage], KKAPIError>) -> Void) {
		let feedMessagesDetails = KKEndpoint.Feed.Messages.details(messageID).endpointValue
		let request: APIRequest<FeedMessageResponse, KKAPIError> = tron.codable.request(feedMessagesDetails)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		request.method = .get
		request.perform(withSuccess: { feedMessageResponse in
			completionHandler(.success(feedMessageResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Message Details 😔", message: error.message)
			}
			print("❌ Received get message details error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message)
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/// Fetch the replies for the given feed message id.
	///
	/// - Parameters:
	///    - feedMessageID: The id of the feed message for which the replies should be fetched.
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	public func getReplies(forFeedMessage feedMessageID: Int, next: String? = nil, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<FeedMessageResponse, KKAPIError>) -> Void) {
		let feedMessagesResplies = next ?? KKEndpoint.Feed.Messages.replies(feedMessageID).endpointValue
		let request: APIRequest<FeedMessageResponse, KKAPIError> = tron.codable.request(feedMessagesResplies).buildURL(.relativeToBaseURL)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		request.method = .get
		request.parameters = [
			"limit": limit
		]
		request.perform(withSuccess: { feedMessageResponse in
			completionHandler(.success(feedMessageResponse))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Replies 😔", message: error.message)
			}
			print("❌ Received get feed message replies error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message)
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/// Update the details for the given feed message id.
	///
	/// - Parameters:
	///    - feedMessageUpdateRequest: An instance of `FeedMessageUpdateRequest` containing the updated feed message details.
	///
	/// - Returns: An instance of `RequestSender` with the results of the update feed message response.
	public func updateMessage(_ feedMessageUpdateRequest: FeedMessageUpdateRequest) -> RequestSender<FeedMessageUpdateResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		headers.add(.authorization(bearerToken: self.authenticationKey))

		// Prepare parameters
		var parameters: [String: Any] = [:]
		parameters = [
			"content": feedMessageUpdateRequest.content,
			"is_nsfw": feedMessageUpdateRequest.isNSFW,
			"is_spoiler": feedMessageUpdateRequest.isSpoiler
		]

		// Prepare request
		let feedMessageUpdate = KKEndpoint.Feed.Messages.update(feedMessageUpdateRequest.feedMessageIdentity.id).endpointValue
		let request: APIRequest<FeedMessageUpdateResponse, KKAPIError> = tron.codable.request(feedMessageUpdate)
			.method(.post)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Heart or un-heart a feed message.
	///
	/// - Parameters:
	///    - messageID: The id of the message to heart or un-heart.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	public func heartMessage(_ messageID: Int, completion completionHandler: @escaping (_ result: Result<FeedMessageUpdate, KKAPIError>) -> Void) {
		let feedPost = KKEndpoint.Feed.Messages.heart(messageID).endpointValue
		let request: APIRequest<FeedMessageUpdateResponse, KKAPIError> = tron.codable.request(feedPost)

		request.headers = headers
		request.headers.add(.authorization(bearerToken: self.authenticationKey))

		request.method = .post
		request.perform(withSuccess: { feedMessageupdateResponse in
			completionHandler(.success(feedMessageupdateResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Heart Message 😔", message: error.message)
			}
			print("❌ Received heart feed message error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message)
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/// Delete the specified message ID from the user's messages.
	///
	/// - Parameters:
	///    - messageID: The message ID to be deleted.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	public func deleteMessage(_ messageID: Int, completion completionHandler: @escaping (_ result: Result<KKSuccess, KKAPIError>) -> Void) {
		let feedMessagesDelete = KKEndpoint.Feed.Messages.delete(messageID).endpointValue
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(feedMessagesDelete)

		request.headers = headers
		request.headers.add(.authorization(bearerToken: self.authenticationKey))

		request.method = .post
		request.perform(withSuccess: { success in
			completionHandler(.success(success))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Delete Message 😔", message: error.message)
			}
			print("❌ Received delete feed message error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message)
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
