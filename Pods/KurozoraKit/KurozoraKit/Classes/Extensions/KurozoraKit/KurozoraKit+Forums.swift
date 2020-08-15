//
//  KurozoraKit+Forums.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SCLAlertView

extension KurozoraKit {
	/**
		Fetch the list of forum sections.

		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getForumSections(completion completionHandler: @escaping (_ result: Result<[ForumsSection], KKAPIError>) -> Void) {
		let forumsSections = self.kurozoraKitEndpoints.forumsSections
		let request: APIRequest<ForumsSectionResponse, KKAPIError> = tron.codable.request(forumsSections)
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { forumsSectionResponse in
			completionHandler(.success(forumsSectionResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get forum sections 😔", subTitle: error.message)
			}
			print("Received get forum sections error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch a list of forum threads for the given forum section id.

		- Parameter sectionID: The id of the forum section for which the forum threads should be fetched.
		- Parameter orderedBy: The forum order value by which the threads should be ordered.
		- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getForumsThreads(forSection sectionID: Int, orderedBy order: ForumOrder, next: String? = nil, completion completionHandler: @escaping (_ result: Result<ForumsThreadResponse, KKAPIError>) -> Void) {
		let forumsSectionsThreads = next ?? self.kurozoraKitEndpoints.forumsSectionsThreads.replacingOccurrences(of: "?", with: "\(sectionID)")
		let request: APIRequest<ForumsThreadResponse, KKAPIError> = tron.codable.request(forumsSectionsThreads).buildURL(.relativeToBaseURL)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		request.method = .get
		request.parameters = [
			"order": order.rawValue
		]
		request.perform(withSuccess: { forumsThreadResponse in
			completionHandler(.success(forumsThreadResponse))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get forum thread 😔", subTitle: error.message)
			}
			print("Received get forum threads error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/**
		Post a new thread to the given forum section id.

		- Parameter sectionID: The id of the forum section where the thread is posted.
		- Parameter title: The title of the thread.
		- Parameter content: The content of the thread.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func postThread(inSection sectionID: Int, withTitle title: String, content: String, completion completionHandler: @escaping (_ result: Result<[ForumsThread], KKAPIError>) -> Void) {
		let forumsSectionsThreads = self.kurozoraKitEndpoints.forumsSectionsThreads.replacingOccurrences(of: "?", with: "\(sectionID)")
		let request: APIRequest<ForumsThreadResponse, KKAPIError> = tron.codable.request(forumsSectionsThreads)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		request.method = .post
		request.parameters = [
			"title": title,
			"content": content
		]
		request.perform(withSuccess: { forumsThreadResponse in
			completionHandler(.success(forumsThreadResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				SCLAlertView().showError("Can't submit your thread 😔", subTitle: error.message)
			}
			print("Received post thread error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}
}
