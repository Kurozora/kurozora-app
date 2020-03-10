//
//  KurozoraKit+Forums.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SCLAlertView

extension KurozoraKit {
	/**
		Fetch the list of forum sections.

		- Parameter successHandler: A closure returning a ForumsSectionsElement array.
		- Parameter forumSections: The returned ForumsSectionsElement array.
	*/
	func getForumSections(withSuccess successHandler: @escaping (_ forumSections: [ForumsSectionsElement]?) -> Void) {
		let forumsSections = self.kurozoraKitEndpoints.forumsSections
		let request: APIRequest<ForumsSections, JSONError> = tron.swiftyJSON.request(forumsSections)
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { sections in
			if let success = sections.success {
				if success {
					successHandler(sections.sections)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get forum sections 😔", subTitle: error.message)
			print("Received get forum sections error: \(error.message ?? "No message available")")
		})
	}

	/**
		Fetch a list of forum threads for the given forum section id.

		- Parameter sectionID: The id of the forum section for which the forum threads should be fetched.
		- Parameter order: The method by which the threads should be ordered. Currently "top" and "recent".
		- Parameter page: The page to retrieve threads from. (starts at 0)
		- Parameter successHandler: A closure returning a ForumsThread array.
		- Parameter forumThreads: The returned ForumsThread array.
	*/
	func getForumsThreads(for sectionID: Int, order: String, page: Int, withSuccess successHandler: @escaping (_ forumThreads: ForumsThread?) -> Void) {
		let forumsSectionsThreads = self.kurozoraKitEndpoints.forumsSectionsThreads.replacingOccurrences(of: "?", with: "\(sectionID)")
		let request: APIRequest<ForumsThread, JSONError> = tron.swiftyJSON.request(forumsSectionsThreads)

		request.headers = headers
		request.headers["kuro-auth"] = self.userAuthToken

		request.method = .get
		request.parameters = [
			"order": order,
			"page": page
		]
		request.perform(withSuccess: { threads in
			if let success = threads.success {
				if success {
					successHandler(threads)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get forum thread 😔", subTitle: error.message)
			print("Received get forum threads error: \(error.message ?? "No message available")")
		})
	}

	/**
		Post a new thread to the given forum section id.

		- Parameter title: The title of the thread.
		- Parameter content: The content of the thread.
		- Parameter sectionID: The id of the forum section where the thread is posted.
		- Parameter successHandler: A closure returning the newly created thread id.
		- Parameter threadID: The id of the newly created thread.
	*/
	func postThread(inSection sectionID: Int, withTitle title: String, content: String, withSuccess successHandler: @escaping (_ threadID: Int) -> Void) {
		let forumsSectionsThreads = self.kurozoraKitEndpoints.forumsSectionsThreads.replacingOccurrences(of: "?", with: "\(sectionID)")
		let request: APIRequest<ThreadPost, JSONError> = tron.swiftyJSON.request(forumsSectionsThreads)

		request.headers = headers
		request.headers["kuro-auth"] = self.userAuthToken

		request.method = .post
		request.parameters = [
			"title": title,
			"content": content
		]
		request.perform(withSuccess: { thread in
			if let success = thread.success {
				if success, let threadID = thread.threadID {
					successHandler(threadID)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't submit your thread 😔", subTitle: error.message)
			print("Received post thread error: \(error.message ?? "No message available")")
		})
	}
}
