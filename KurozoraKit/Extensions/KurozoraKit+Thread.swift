//
//  KurozoraKit+Thread.swift
//  Kurozora
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
	public func getDetails(forThread threadID: Int, completion completionHandler: @escaping (_ result: Result<ForumsThreadElement, JSONError>) -> Void) {
		let forumsThreads = self.kurozoraKitEndpoints.forumsThreads.replacingOccurrences(of: "?", with: "\(threadID)")
		let request: APIRequest<ForumsThread, JSONError> = tron.swiftyJSON.request(forumsThreads)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self._userAuthToken
		}

		request.method = .get
		request.perform(withSuccess: { thread in
			completionHandler(.success(thread.thread ?? ForumsThreadElement()))
		}, failure: { error in
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
		- Parameter vote: An vote status value indicating whether the thread is upvoted or downvoted.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func voteOnThread(_ threadID: Int, withVoteStatus vote: VoteStatus, completion completionHandler: @escaping (_ result: Result<VoteStatus, JSONError>) -> Void) {
		let forumsThreadsVote = self.kurozoraKitEndpoints.forumsThreadsVote.replacingOccurrences(of: "?", with: "\(threadID)")
		let request: APIRequest<VoteThread, JSONError> = tron.swiftyJSON.request(forumsThreadsVote)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self._userAuthToken
		}

		request.method = .post
		request.parameters = [
			"vote": vote.rawValue
		]
		request.perform(withSuccess: { voteThread in
			completionHandler(.success(voteThread.voteStatus ?? .noVote))
		}, failure: { error in
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
		- Parameter page: The page to retrieve replies from. (starts at 0)
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getReplies(forThread threadID: Int, orderedBy order: ForumOrder, page: Int, completion completionHandler: @escaping (_ result: Result<ThreadReplies, JSONError>) -> Void) {
		let forumsThreadsReplies = self.kurozoraKitEndpoints.forumsThreadsReplies.replacingOccurrences(of: "?", with: "\(threadID)")
		let request: APIRequest<ThreadReplies, JSONError> = tron.swiftyJSON.request(forumsThreadsReplies)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self._userAuthToken
		}

		request.method = .get
		request.parameters = [
			"order": order.rawValue,
			"page": page
		]
		request.perform(withSuccess: { replies in
			completionHandler(.success(replies))
		}, failure: { error in
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
	public func postReply(inThread threadID: Int, withComment comment: String, completion completionHandler: @escaping (_ result: Result<Int, JSONError>) -> Void) {
		let forumsThreadsReplies = self.kurozoraKitEndpoints.forumsThreadsReplies.replacingOccurrences(of: "?", with: "\(threadID)")
		let request: APIRequest<ThreadReply, JSONError> = tron.swiftyJSON.request(forumsThreadsReplies)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self._userAuthToken
		}

		request.method = .post
		request.parameters = [
			"content": comment
		]
		request.perform(withSuccess: { reply in
			completionHandler(.success(reply.id ?? 0))
		}, failure: { error in
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
	public func search(forThread thread: String, completion completionHandler: @escaping (_ result: Result<[ForumsThreadElement], JSONError>) -> Void) {
		let forumsThreadsSearch = self.kurozoraKitEndpoints.forumsThreadsSearch
		let request: APIRequest<Search, JSONError> = tron.swiftyJSON.request(forumsThreadsSearch)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self._userAuthToken
		}

		request.method = .get
		request.parameters = [
			"query": thread
		]
		request.perform(withSuccess: { search in
			completionHandler(.success(search.threadResults ?? []))
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
	public func lockThread(_ threadID: Int, withLockStatus lockStatus: LockStatus, completion completionHandler: @escaping (_ result: Result<LockStatus, JSONError>) -> Void) {
		let forumsThreadsLock = self.kurozoraKitEndpoints.forumsThreadsLock.replacingOccurrences(of: "?", with: "\(threadID)")
		let request: APIRequest<ForumsThread, JSONError> = tron.swiftyJSON.request(forumsThreadsLock)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self._userAuthToken
		}

		request.method = .post
		request.parameters = [
			"lock": lockStatus.rawValue
		]
		request.perform(withSuccess: { forums in
			completionHandler(.success(forums.thread?.locked ?? .unlocked))
		}, failure: { error in
			if self.services.showAlerts {
				SCLAlertView().showError("Can't lock thread 😔", subTitle: error.message)
			}
			print("Received thread lock error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}
}
