//
//  KurozoraKit+Feed.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON

extension KurozoraKit {
	/**
		Fetch a list of given user's feed messages.

		- Parameter userID: The id of the user whose feed messages to fetch.
		- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
		- Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getFeedMessages(forUserID userID: Int, next: String? = nil, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<FeedMessageResponse, KKAPIError>) -> Void) {
		let usersFeedMessages = next ?? KKEndpoint.Users.feedMessages(userID).endpointValue
		let request: APIRequest<FeedMessageResponse, KKAPIError> = tron.codable.request(usersFeedMessages).buildURL(.relativeToBaseURL)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
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

	/**
		Fetch a list of home feed messages.

		- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
		- Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getFeedHome(next: String? = nil, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<FeedMessageResponse, KKAPIError>) -> Void) {
		let feedHome = next ?? KKEndpoint.Feed.home.endpointValue
		let request: APIRequest<FeedMessageResponse, KKAPIError> = tron.codable.request(feedHome).buildURL(.relativeToBaseURL)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
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
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch a list of explore feed messages.

		- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
		- Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getFeedExplore(next: String? = nil, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<FeedMessageResponse, KKAPIError>) -> Void) {
		let feedExplore = next ?? KKEndpoint.Feed.explore.endpointValue
		let request: APIRequest<FeedMessageResponse, KKAPIError> = tron.codable.request(feedExplore).buildURL(.relativeToBaseURL)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
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
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Post a new message to the feed.

		If the message is a reply or a re-share, then also supply the parent message's ID.

		- Parameter body: The content of the message to be posted in the feed.
		- Parameter messageID: The ID of the parent message this message is related to.
		- Parameter isReply: Whether the message is a reply to another message.
		- Parameter isReShare: Whether the message is a re-share of another message.
		- Parameter isNSFW: Whether the message contains NSFW material.
		- Parameter isSpoiler: Whether the message contains spoiler material.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func postFeedMessage(withBody body: String, relatedToParent messageID: Int?, isReply: Bool?, isReShare: Bool?, isNSFW: Bool, isSpoiler: Bool, completion completionHandler: @escaping (_ result: Result<[FeedMessage], KKAPIError>) -> Void) {
		guard User.current != nil else { fatalError("User must be signed in and have a session attached to call the postFeedMessage(withBody:relatedToParent:isReply:isReShare:isNSFW:isSpoiler:completion:) method.") }
		let feedPost = KKEndpoint.Feed.post.endpointValue
		let request: APIRequest<FeedMessageResponse, KKAPIError> = tron.codable.request(feedPost)

		request.headers = headers
		request.headers["kuro-auth"] = self.authenticationKey

		request.parameters = [
			"body": body,
			"is_nsfw": isNSFW,
			"is_spoiler": isSpoiler
		]
		if let messageID = messageID {
			request.parameters["parent_id"] = messageID
			request.parameters["is_reply"] = isReply
			request.parameters["is_reshare"] = isReShare
		}

		request.method = .post
		request.perform(withSuccess: { feedMessageResponse in
			completionHandler(.success(feedMessageResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Submit Your Message 😔", message: error.message)
			}
			print("❌ Received post feed message error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the details of the given feed message id.

		- Parameter messageID: The id of the message for which the details should be fetched.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getDetails(forFeedMessage messageID: Int, completion completionHandler: @escaping (_ result: Result<[FeedMessage], KKAPIError>) -> Void) {
		let feedMessagesDetails = KKEndpoint.Feed.Messages.details(messageID).endpointValue
		let request: APIRequest<FeedMessageResponse, KKAPIError> = tron.codable.request(feedMessagesDetails)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
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
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the replies for the given feed message id.

		- Parameter feedMessageID: The id of the feed message for which the replies should be fetched.
		- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
		- Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getReplies(forFeedMessage feedMessageID: Int, next: String? = nil, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<FeedMessageResponse, KKAPIError>) -> Void) {
		let feedMessagesResplies = next ?? KKEndpoint.Feed.Messages.replies(feedMessageID).endpointValue
		let request: APIRequest<FeedMessageResponse, KKAPIError> = tron.codable.request(feedMessagesResplies).buildURL(.relativeToBaseURL)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
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
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Update the details for the given feed message id.

		- Parameter messageID: The id of the feed message to be updated.
		- Parameter body: The content of the message to be posted in the feed.
		- Parameter isNSFW: Whether the message contains NSFW material.
		- Parameter isSpoiler: Whether the message contains spoiler material.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func updateMessage(_ messageID: Int, withBody body: String, isNSFW: Bool, isSpoiler: Bool, completion completionHandler: @escaping (_ result: Result<FeedMessageUpdate, KKAPIError>) -> Void) {
		guard User.current != nil else { fatalError("User must be signed in and have a session attached to call the updateMessage(messageID:withBody:isNSFW:isSpoiler:completion:) method.") }
		let feedMessageUpdate = KKEndpoint.Feed.Messages.update(messageID).endpointValue
		let request: APIRequest<FeedMessageUpdateResponse, KKAPIError> = tron.codable.request(feedMessageUpdate)

		request.headers = headers
		request.headers["kuro-auth"] = self.authenticationKey

		request.method = .post
		request.parameters = [
			"body": body,
			"is_nsfw": isNSFW,
			"is_spoiler": isSpoiler
		]
		request.perform(withSuccess: { feedMessageUpdateResponse in
			completionHandler(.success(feedMessageUpdateResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Update Message 😔", message: error.message)
			}
			print("❌ Received update message error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
		})
	}

	/**
		Heart or un-heart a feed message.

		- Parameter messageID: The id of the message to heart or un-heart.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func heartMessage(_ messageID: Int, completion completionHandler: @escaping (_ result: Result<FeedMessageUpdate, KKAPIError>) -> Void) {
		guard User.current != nil else { fatalError("User must be signed in and have a session attached to call the heartMessage(messageID:completion:) method.") }
		let feedPost = KKEndpoint.Feed.Messages.heart(messageID).endpointValue
		let request: APIRequest<FeedMessageUpdateResponse, KKAPIError> = tron.codable.request(feedPost)

		request.headers = headers
		request.headers["kuro-auth"] = self.authenticationKey

		request.method = .post
		request.perform(withSuccess: { feedMessageupdateResponse in
			completionHandler(.success(feedMessageupdateResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Heart Message 😔", message: error.message)
			}
			print("❌ Received heart feed message error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Delete the specified message ID from the user's messages.

		- Parameter messageID: The message ID to be deleted.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func deleteMessage(_ messageID: Int, completion completionHandler: @escaping (_ result: Result<KKSuccess, KKAPIError>) -> Void) {
		guard User.current != nil else { fatalError("User must be signed in and have a session attached to call the deleteMessage(messageID:completion:) method.") }
		let feedMessagesDelete = KKEndpoint.Feed.Messages.delete(messageID).endpointValue
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(feedMessagesDelete)

		request.headers = headers
		request.headers["kuro-auth"] = self.authenticationKey

		request.method = .post
		request.perform(withSuccess: { success in
			completionHandler(.success(success))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Delete Message 😔", message: error.message)
			}
			print("❌ Received delete feed message error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
