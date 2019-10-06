//
//  KService+Thread.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SCLAlertView

extension KService {
	/**
		Fetch the details of the given thread id.

		- Parameter threadID: The id of the thread for which the details should be fetched.
		- Parameter successHandler: A closure returning a ForumsThreadElement object.
		- Parameter thread: The returned ForumsThreadElement object.
	*/
	func getDetails(forThread threadID: Int?, withSuccess successHandler: @escaping (_ thread: ForumsThreadElement?) -> Void) {
		guard let threadID = threadID else { return }

		let request: APIRequest<ForumsThread, JSONError> = tron.swiftyJSON.request("forum-threads/\(threadID)")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
		request.method = .get
		request.perform(withSuccess: { thread in
			if let success = thread.success {
				if success {
					successHandler(thread.thread)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get thread details 😔", subTitle: error.message)
			print("Received get thread error: \(error)")
		})
	}

	/**
		Upvote or downvote a thread with the given thread id.

		- Parameter threadID: The id of the thread that should be up upvoted/downvoted.
		- Parameter vote: An intgere indicating whether the thread is upvoted or downvoted. (0 = downvote, 1 = upvote)
		- Parameter successHandler: A closure returning an intiger indicating whether the thread is upvoted or downvoted.
		- Parameter action: The integer indicating whether the thead is upvoted or downvoted.
	*/
	func vote(forThread threadID: Int?, vote: Int?, withSuccess successHandler: @escaping (_ action: Int) -> Void) {
		guard let threadID = threadID else { return }
		guard let vote = vote else { return }

		let request: APIRequest<VoteThread, JSONError> = tron.swiftyJSON.request("forum-threads/\(threadID)/vote")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
		request.method = .post
		request.parameters = [
			"vote": vote
		]
		request.perform(withSuccess: { vote in
			if let success = vote.success {
				if success, let action = vote.action {
					successHandler(action)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't vote on this thread 😔", subTitle: error.message)
			print("Received vote thread error: \(error)")
		})
	}

	/**
		Fetch the replies for the given thread id.

		- Parameter threadID: The id of the thread for which the replies should be fetched.
		- Parameter order: The method by which the replies should be ordered. Current options are "top" and "recent".
		- Parameter page: The page to retrieve replies from. (starts at 0)
		- Parameter successHandler: A closure returning a ThreadReplies object.
		- Parameter threadReplies: The returned ThreadReplies object.
	*/
	func getReplies(forThread threadID: Int?, order: String?, page: Int?, withSuccess successHandler: @escaping (_ threadReplies: ThreadReplies?) -> Void) {
		guard let threadID = threadID else { return }
		guard let order = order else { return }
		guard let page = page else { return }

		let request: APIRequest<ThreadReplies, JSONError> = tron.swiftyJSON.request("forum-threads/\(threadID)/replies")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
		request.method = .get
		request.parameters = [
			"order": order,
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
			print("Received get replies error: \(error)")
		})
	}

	/**
		Post a new reply to the given thread id.

		- Parameter comment: The content of the reply.
		- Parameter threadID: The id of the forum thread where the reply is posted.
		- Parameter successHandler: A closure returning the newly created reply id.
		- Parameter replyID: The id of the newly created reply.
	*/
	func postReply(inThread threadID: Int?, withComment comment: String?, withSuccess successHandler: @escaping (_ replyID: Int) -> Void) {
		guard let threadID = threadID else { return }
		guard let comment = comment else { return }

		let request: APIRequest<ThreadReply, JSONError> = tron.swiftyJSON.request("forum-threads/\(threadID)/replies")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
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
			print("Received post reply error: \(error)")
		})
	}

	/**
		Fetch a list of threads matching the search query.

		- Parameter thread: The search query.
		- Parameter successHandler: A closure returning a SearchElement array.
		- Parameter search: The returned SearchElement array.
	*/
	func search(forThread thread: String?, withSuccess successHandler: @escaping (_ search: [ForumsThreadElement]?) -> Void) {
		guard let thread = thread else { return }

		let request: APIRequest<Search, JSONError> = tron.swiftyJSON.request("forum-threads/search")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
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
			print("Received thread search error: \(error)")
		})
	}

	/**
		Lock or unlock a thread with the given thread id.

		- Parameter threadID: The id of the forum thread to be locked/unlocked.
		- Parameter lock: The integer indicating whether to lock or unlock a thread. (0 = unlock, 1 = lock)
		- Parameter successHandler: A closure returning a boolean indicating whether thread lock/unlock is successful.
		- Parameter isSuccess: A boolean value indicating whether thread lock/unlock is successful.
	*/
	func lockThread(withID threadID: Int?, lock: Int?, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		guard let threadID = threadID else { return }
		guard let lock = lock else { return }

		let request: APIRequest<ForumsThread, JSONError> = tron.swiftyJSON.request("forum-threads/\(threadID)/lock")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
		request.method = .post
		request.parameters = [
			"lock": lock
		]
		request.perform(withSuccess: { forums in
			if let success = forums.success {
				if success, let locked = forums.thread?.locked {
					successHandler(locked)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't lock thread 😔", subTitle: error.message)
			print("Received thread lock error: \(error)")
		})
	}
}
