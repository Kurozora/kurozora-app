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
		- Parameter successHandler: A closure returning a ForumsThreadElement object.
		- Parameter thread: The returned ForumsThreadElement object.
	*/
	public func getDetails(forThread threadID: Int, withSuccess successHandler: @escaping (_ thread: ForumsThreadElement?) -> Void) {
		let forumsThreads = self.kurozoraKitEndpoints.forumsThreads.replacingOccurrences(of: "?", with: "\(threadID)")
		let request: APIRequest<ForumsThread, JSONError> = tron.swiftyJSON.request(forumsThreads)

		request.headers = headers
		request.headers["kuro-auth"] = self._userAuthToken

		request.method = .get
		request.perform(withSuccess: { thread in
			if let success = thread.success {
				if success {
					successHandler(thread.thread)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get thread details 😔", subTitle: error.message)
			print("Received get thread error: \(error.message ?? "No message available")")
		})
	}

	/**
		Upvote or downvote a thread with the given thread id.

		- Parameter threadID: The id of the thread that should be up upvoted/downvoted.
		- Parameter vote: An vote status value indicating whether the thread is upvoted or downvoted.
		- Parameter successHandler: A closure returning an vote status indicating whether the thread is upvoted or downvoted.
		- Parameter action: The vote status indicating whether the thead is upvoted or downvoted.
	*/
	public func voteOnThread(_ threadID: Int, withVoteStatus vote: VoteStatus, withSuccess successHandler: @escaping (_ action: VoteStatus) -> Void) {
		let forumsThreadsVote = self.kurozoraKitEndpoints.forumsThreadsVote.replacingOccurrences(of: "?", with: "\(threadID)")
		let request: APIRequest<VoteThread, JSONError> = tron.swiftyJSON.request(forumsThreadsVote)

		request.headers = headers
		request.headers["kuro-auth"] = self._userAuthToken

		request.method = .post
		request.parameters = [
			"vote": vote.rawValue
		]
		request.perform(withSuccess: { vote in
			if let success = vote.success {
				if success, let action = vote.action {
					successHandler(VoteStatus(rawValue: action) ?? .noVote)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't vote on this thread 😔", subTitle: error.message)
			print("Received vote thread error: \(error.message ?? "No message available")")
		})
	}

	/**
		Fetch the replies for the given thread id.

		- Parameter threadID: The id of the thread for which the replies should be fetched.
		- Parameter order: The forum order vlue by which the replies should be ordered.
		- Parameter page: The page to retrieve replies from. (starts at 0)
		- Parameter successHandler: A closure returning a ThreadReplies object.
		- Parameter threadReplies: The returned ThreadReplies object.
	*/
	public func getReplies(forThread threadID: Int, orderedBy order: ForumOrder, page: Int, withSuccess successHandler: @escaping (_ threadReplies: ThreadReplies?) -> Void) {
		let forumsThreadsReplies = self.kurozoraKitEndpoints.forumsThreadsReplies.replacingOccurrences(of: "?", with: "\(threadID)")
		let request: APIRequest<ThreadReplies, JSONError> = tron.swiftyJSON.request(forumsThreadsReplies)

		request.headers = headers
		request.headers["kuro-auth"] = self._userAuthToken

		request.method = .get
		request.parameters = [
			"order": order.rawValue,
			"page": page
		]
		request.perform(withSuccess: { replies in
			if let success = replies.success {
				if success {
					successHandler(replies)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get replies 😔", subTitle: error.message)
			print("Received get replies error: \(error.message ?? "No message available")")
		})
	}

	/**
		Post a new reply to the given thread id.

		- Parameter threadID: The id of the forum thread where the reply is posted.
		- Parameter comment: The content of the reply.
		- Parameter successHandler: A closure returning the newly created reply id.
		- Parameter replyID: The id of the newly created reply.
	*/
	public func postReply(inThread threadID: Int, withComment comment: String, withSuccess successHandler: @escaping (_ replyID: Int) -> Void) {
		let forumsThreadsReplies = self.kurozoraKitEndpoints.forumsThreadsReplies.replacingOccurrences(of: "?", with: "\(threadID)")
		let request: APIRequest<ThreadReply, JSONError> = tron.swiftyJSON.request(forumsThreadsReplies)

		request.headers = headers
		request.headers["kuro-auth"] = self._userAuthToken

		request.method = .post
		request.parameters = [
			"content": comment
		]
		request.perform(withSuccess: { reply in
			if let success = reply.success {
				if success, let replyID = reply.replyID {
					successHandler(replyID)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't reply 😔", subTitle: error.message)
			print("Received post reply error: \(error.message ?? "No message available")")
		})
	}

	/**
		Fetch a list of threads matching the search query.

		- Parameter thread: The search query.
		- Parameter successHandler: A closure returning a SearchElement array.
		- Parameter search: The returned SearchElement array.
	*/
	public func search(forThread thread: String, withSuccess successHandler: @escaping (_ search: [ForumsThreadElement]?) -> Void) {
		let forumsThreadsSearch = self.kurozoraKitEndpoints.forumsThreadsSearch
		let request: APIRequest<Search, JSONError> = tron.swiftyJSON.request(forumsThreadsSearch)

		request.headers = headers
		request.headers["kuro-auth"] = self._userAuthToken

		request.method = .get
		request.parameters = [
			"query": thread
		]
		request.perform(withSuccess: { search in
			if let success = search.success {
				if success {
					successHandler(search.threadResults)
				}
			}
		}, failure: { error in
//			SCLAlertView().showError("Can't get search results 😔", subTitle: error.message)
			print("Received thread search error: \(error.message ?? "No message available")")
		})
	}

	/**
		Lock or unlock a thread with the given thread id.

		- Parameter threadID: The id of the forum thread to be locked/unlocked.
		- Parameter lockStatus: The lock status value indicating whether to lock or unlock a thread.
		- Parameter successHandler: A closure returning a lock status value indicating whether a thread is locked or unlocked.
		- Parameter lockStatus: A lock status value indicating whether a thread is locked or unlocked.
	*/
	public func lockThread(_ threadID: Int, withLockStatus lockStatus: LockStatus, withSuccess successHandler: @escaping (_ lockStatus: LockStatus) -> Void) {
		let forumsThreadsLock = self.kurozoraKitEndpoints.forumsThreadsLock.replacingOccurrences(of: "?", with: "\(threadID)")
		let request: APIRequest<ForumsThread, JSONError> = tron.swiftyJSON.request(forumsThreadsLock)

		request.headers = headers
		request.headers["kuro-auth"] = self._userAuthToken

		request.method = .post
		request.parameters = [
			"lock": lockStatus.rawValue
		]
		request.perform(withSuccess: { forums in
			if let success = forums.success {
				if success, let locked = forums.thread?.locked {
					successHandler(locked ? .locked : .unlocked)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't lock thread 😔", subTitle: error.message)
			print("Received thread lock error: \(error.message ?? "No message available")")
		})
	}
}
