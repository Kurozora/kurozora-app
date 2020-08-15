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
		Fetch the list of feed sections.

		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getFeedSections(completion completionHandler: @escaping (_ result: Result<[FeedSection], KKAPIError>) -> Void) {
		let feedSection = self.kurozoraKitEndpoints.feedSection
		let request: APIRequest<FeedSectionResponse, KKAPIError> = tron.codable.request(feedSection)
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { feedSectionResponse in
			completionHandler(.success(feedSectionResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get feed sections 😔", subTitle: error.message)
			}
			print("Received get feed sections error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch a list of feed posts for the given feed section id.

		- Parameter sectionID: The id of the feed section for which the posts should be fetched.
		- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getFeedPosts(forSection sectionID: Int, next: String? = nil, completion completionHandler: @escaping (_ result: Result<FeedPostResponse, KKAPIError>) -> Void) {
		let feedSectionPost = next ?? self.kurozoraKitEndpoints.feedSectionPost.replacingOccurrences(of: "?", with: "\(sectionID)")
		let request: APIRequest<FeedPostResponse, KKAPIError> = tron.codable.request(feedSectionPost).buildURL(.relativeToBaseURL)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		request.method = .get
		request.perform(withSuccess: { feedPostResponse in
			completionHandler(.success(feedPostResponse))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get feed posts 😔", subTitle: error.message)
			}
			print("Received get feed posts error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}
}
