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
	///
	/// - Returns: An instance of `RequestSender` with the results of the get feed messages response.
	public func getFeedMessages(forUser userIdentity: UserIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<FeedMessageResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		if !self.authenticationKey.isEmpty {
			headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		// Prepare parameters
		let parameters: [String: Any] = [
			"limit": limit
		]

		// Prepare request
		let usersFeedMessages = next ?? KKEndpoint.Users.feedMessages(userIdentity).endpointValue
		let request: APIRequest<FeedMessageResponse, KKAPIError> = tron.codable.request(usersFeedMessages).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Fetch a list of home feed messages.
	///
	/// - Parameters:
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get feed home response.
	public func getFeedHome(next: String? = nil, limit: Int = 25) -> RequestSender<FeedMessageResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		if !self.authenticationKey.isEmpty {
			headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		// Prepare parameters
		let parameters: [String: Any] = [
			"limit": limit
		]

		// Prepare request
		let feedHome = next ?? KKEndpoint.Feed.home.endpointValue
		let request: APIRequest<FeedMessageResponse, KKAPIError> = tron.codable.request(feedHome).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Fetch a list of explore feed messages.
	///
	/// - Parameters:
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get feed explore response.
	public func getFeedExplore(next: String? = nil, limit: Int = 25) -> RequestSender<FeedMessageResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		if !self.authenticationKey.isEmpty {
			headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		// Prepare parameters
		let parameters: [String: Any] = [
			"limit": limit
		]

		// Prepare request
		let feedExplore = next ?? KKEndpoint.Feed.explore.endpointValue
		let request: APIRequest<FeedMessageResponse, KKAPIError> = tron.codable.request(feedExplore).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
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
	///
	/// - Returns: An instance of `RequestSender` with the results of the get feed message details response.
	public func getDetails(forFeedMessage messageID: String) -> RequestSender<FeedMessageResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		if !self.authenticationKey.isEmpty {
			headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		// Prepare request
		let feedMessagesDetails = KKEndpoint.Feed.Messages.details(messageID).endpointValue
		let request: APIRequest<FeedMessageResponse, KKAPIError> = tron.codable.request(feedMessagesDetails)
			.method(.get)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Fetch the replies for the given feed message id.
	///
	/// - Parameters:
	///    - feedMessageID: The id of the feed message for which the replies should be fetched.
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get feed message replies response.
	public func getReplies(forFeedMessage feedMessageID: String, next: String? = nil, limit: Int = 25) -> RequestSender<FeedMessageResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		if !self.authenticationKey.isEmpty {
			headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		// Prepare parameters
		let parameters: [String: Any] = [
			"limit": limit
		]

		// Prepare request
		let feedMessagesResplies = next ?? KKEndpoint.Feed.Messages.replies(feedMessageID).endpointValue
		let request: APIRequest<FeedMessageResponse, KKAPIError> = tron.codable.request(feedMessagesResplies).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
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
	///
	/// - Returns: An instance of `RequestSender` with the results of the heart message response.
	public func heartMessage(_ messageID: String) ->  RequestSender<FeedMessageUpdateResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		headers.add(.authorization(bearerToken: self.authenticationKey))

		// Prepare request
		let feedPost = KKEndpoint.Feed.Messages.heart(messageID).endpointValue
		let request: APIRequest<FeedMessageUpdateResponse, KKAPIError> = tron.codable.request(feedPost)
			.method(.post)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Delete the specified message ID from the user's messages.
	///
	/// - Parameters:
	///    - messageID: The message ID to be deleted.
	///
	/// - Returns: An instance of `RequestSender` with the results of the delete message response.
	public func deleteMessage(_ messageID: String) -> RequestSender<KKSuccess, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		headers.add(.authorization(bearerToken: self.authenticationKey))

		// Prepare request
		let feedMessagesDelete = KKEndpoint.Feed.Messages.delete(messageID).endpointValue
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(feedMessagesDelete)
			.method(.post)
			.headers(headers)

		// Send request
		return request.sender()
	}
}
