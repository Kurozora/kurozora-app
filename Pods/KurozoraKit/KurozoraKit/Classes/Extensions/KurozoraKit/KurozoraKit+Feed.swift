//
//  KurozoraKit+Feed.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SCLAlertView

extension KurozoraKit {
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
				SCLAlertView().showError("Can't get home feed 😔", subTitle: error.message)
			}
			print("Received get feed home error: \(error.message ?? "No message available")")
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
				SCLAlertView().showError("Can't get explore feed 😔", subTitle: error.message)
			}
			print("Received get feed explore error: \(error.message ?? "No message available")")
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
		guard User.current != nil else { fatalError("User must be signed in and have a session attached to call the postFeedMessage(withBody:isReply:isReShare:isNSFW:isSpoiler:) method.") }
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
				SCLAlertView().showError("Can't submit your message 😔", subTitle: error.message)
			}
			print("Received post feed message error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}
}
