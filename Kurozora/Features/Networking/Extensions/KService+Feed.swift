//
//  KService+Feed.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SCLAlertView

extension KService {
	/**
		Fetch the list of feed sections.

		- Parameter successHandler: A closure returning a FeedSectionsElement array.
		- Parameter feedSections: The returned FeedSectionsElement array.
	*/
	func getFeedSections(withSuccess successHandler: @escaping (_ feedSections: [FeedSectionsElement]?) -> Void) {
		let request: APIRequest<FeedSections, JSONError> = tron.swiftyJSON.request("feed-sections")
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { sections in
			if let success = sections.success {
				if success {
					successHandler(sections.sections)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get feed sections 😔", subTitle: error.message)
			print("Received get feed sections error: \(error)")
		})
	}

	/**
		Fetch a list of feed posts for the given feed section id.

		- Parameter sectionID: The id of the feed section for which the posts should be fetched.
		- Parameter page: The page to retrieve posts from. (starts at 0)
		- Parameter successHandler: A closure returning a FeedPosts array.
		- Parameter feedPosts: The returned FeedPosts array.
	*/
	func getFeedPosts(for sectionID: Int?, page: Int?, withSuccess successHandler: @escaping (_ feedPosts: FeedPosts?) -> Void) {
		guard let sectionID = sectionID else { return }
		guard let page = page else { return }

		let request: APIRequest<FeedPosts, JSONError> = tron.swiftyJSON.request("feed-sections/\(sectionID)/posts")
		request.headers = headers
		request.method = .get
		request.parameters = [
			"page": page
		]
		request.perform(withSuccess: { feedPosts in
			if let success = feedPosts.success {
				if success {
					successHandler(feedPosts)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get feed posts 😔", subTitle: error.message)
			print("Received get feed posts error: \(error)")
		})
	}
}
