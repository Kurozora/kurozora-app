//
//  KurozoraKit+Thread.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SCLAlertView

extension KurozoraKit {
	/**
		Fetch the details of the given thread id.

		- Parameter threadID: The id of the thread for which the details should be fetched.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getDetails(forThread threadID: Int, completion completionHandler: @escaping (_ result: Result<[ForumsThread], KKAPIError>) -> Void) {
		let forumsThreadsDetails = KKEndpoint.Forums.Threads.details(threadID).endpointValue
		let request: APIRequest<ForumsThreadResponse, KKAPIError> = tron.codable.request(forumsThreadsDetails)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		request.method = .get
		request.perform(withSuccess: { forumsThreadResponse in
			completionHandler(.success(forumsThreadResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get thread details 😔", subTitle: error.message)
			}
			print("Received get thread error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/**
		Upvote or downvote a thread with the given thread id.

		- Parameter threadID: The id of the thread that should be up upvoted/downvoted.
		- Parameter voteStatus: A `VoteStatus` value indicating whether the thread is upvoted or downvoted.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func voteOnThread(_ threadID: Int, withVoteStatus voteStatus: VoteStatus, completion completionHandler: @escaping (_ result: Result<VoteStatus, KKAPIError>) -> Void) {
		let forumsThreadsVote = KKEndpoint.Forums.Threads.vote(threadID).endpointValue
		let request: APIRequest<ForumsVoteResponse, KKAPIError> = tron.codable.request(forumsThreadsVote)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		request.method = .post
		request.parameters = [
			"vote": voteStatus.voteValue
		]
		request.perform(withSuccess: { forumsVoteResponse in
			completionHandler(.success(forumsVoteResponse.data.voteAction))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				SCLAlertView().showError("Can't vote on this thread 😔", subTitle: error.message)
			}
			print("Received vote thread error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the replies for the given thread id.

		- Parameter threadID: The id of the thread for which the replies should be fetched.
		- Parameter order: The forum order vlue by which the replies should be ordered.
		- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
		- Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getReplies(forThread threadID: Int, orderedBy order: ForumOrder, next: String? = nil, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<ThreadReplyResponse, KKAPIError>) -> Void) {
		let forumsThreadsReplies = next ?? KKEndpoint.Forums.Threads.replies(threadID).endpointValue
		let request: APIRequest<ThreadReplyResponse, KKAPIError> = tron.codable.request(forumsThreadsReplies).buildURL(.relativeToBaseURL)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		request.method = .get
		request.parameters = [
			"order": order.rawValue,
			"limit": limit
		]
		request.perform(withSuccess: { threadReplyResponse in
			completionHandler(.success(threadReplyResponse))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get replies 😔", subTitle: error.message)
			}
			print("Received get replies error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/**
		Post a new reply to the given thread id and return the newly created reply id.

		- Parameter threadID: The id of the forum thread where the reply is posted.
		- Parameter comment: The content of the reply.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func postReply(inThread threadID: Int, withComment comment: String, completion completionHandler: @escaping (_ result: Result<[ThreadReply], KKAPIError>) -> Void) {
		let forumsThreadsReplies = KKEndpoint.Forums.Threads.replies(threadID).endpointValue
		let request: APIRequest<ThreadReplyResponse, KKAPIError> = tron.codable.request(forumsThreadsReplies)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		request.method = .post
		request.parameters = [
			"content": comment
		]
		request.perform(withSuccess: { threadReplyResponse in
			completionHandler(.success(threadReplyResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				SCLAlertView().showError("Can't reply 😔", subTitle: error.message)
			}
			print("Received post reply error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch a list of threads matching the search query.

		- Parameter thread: The search query.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func search(forThread thread: String, completion completionHandler: @escaping (_ result: Result<[ForumsThread], KKAPIError>) -> Void) {
		let forumsThreadsSearch = KKEndpoint.Forums.Threads.search.endpointValue
		let request: APIRequest<ForumsThreadResponse, KKAPIError> = tron.codable.request(forumsThreadsSearch)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		request.method = .get
		request.parameters = [
			"query": thread
		]
		request.perform(withSuccess: { forumsThreadResponse in
			completionHandler(.success(forumsThreadResponse.data))
		}, failure: { error in
//			if self.services.showAlerts {
//				SCLAlertView().showError("Can't get search results 😔", subTitle: error.message)
//			}
			print("Received thread search error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/**
		Lock or unlock a thread with the given thread id.

		- Parameter threadID: The id of the forum thread to be locked/unlocked.
		- Parameter lockStatus: The lock status value indicating whether to lock or unlock a thread.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func lockThread(_ threadID: Int, withLockStatus lockStatus: LockStatus, completion completionHandler: @escaping (_ result: Result<LockStatus, KKAPIError>) -> Void) {
		let forumsThreadsLock = KKEndpoint.Forums.Threads.lock(threadID).endpointValue
		let request: APIRequest<ForumsLockResponse, KKAPIError> = tron.codable.request(forumsThreadsLock)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		request.method = .post
		request.parameters = [
			"lock": lockStatus.rawValue
		]
		request.perform(withSuccess: { forumsLockResponse in
			completionHandler(.success(forumsLockResponse.data.lockStatus))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				SCLAlertView().showError("Can't lock thread 😔", subTitle: error.message)
			}
			print("Received thread lock error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}
}
