//
//  KurozoraKit+Feed.swift
//  Kurozora
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
	public func getFeedSections(completion completionHandler: @escaping (_ result: Result<[FeedSectionsElement], KKError>) -> Void) {
		let feedSection = self.kurozoraKitEndpoints.feedSection
		let request: APIRequest<FeedSections, KKError> = tron.swiftyJSON.request(feedSection)
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { sections in
			completionHandler(.success(sections.sections ?? []))
		}, failure: { error in
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
		- Parameter page: The page to retrieve posts from. (starts at 0)
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getFeedPosts(forSection sectionID: Int, page: Int, completion completionHandler: @escaping (_ result: Result<FeedPosts, KKError>) -> Void) {
		let feedSectionPost = self.kurozoraKitEndpoints.feedSectionPost.replacingOccurrences(of: "?", with: "\(sectionID)")
		let request: APIRequest<FeedPosts, KKError> = tron.swiftyJSON.request(feedSectionPost)
		request.headers = headers
		request.method = .get
		request.parameters = [
			"page": page
		]
		request.perform(withSuccess: { feedPosts in
			completionHandler(.success(feedPosts))
		}, failure: { error in
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get feed posts 😔", subTitle: error.message)
			}
			print("Received get feed posts error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}
}
