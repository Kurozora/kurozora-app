//
//  KKEndpoint+Forums.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 19/08/2020.
//

import Foundation

// MARK: - Threads
extension KKEndpoint.Forums {
	/// The set of available Threads API endpoints types.
	internal enum Threads {
		// MARK: - Cases
		/// The endpoint to the details of a thread.
		case details(_ threadID: Int)

		/// The endpoint to the replies in a thread.
		case replies(_ threadID: Int)

		/// The endpoint to update the vote on a thread.
		case vote(_ threadID: Int)

		/// The endpoint to lock a thread.
		case lock(_ threadID: Int)

		/// The endpoint to search for threads.
		case search

		// MARK: - Properties
		/// The endpoint value of the Threads API type.
		var endpointValue: String {
			switch self {
			case .details(let threadID):
				return "forum-threads/\(threadID)"
			case .replies(let threadID):
				return "forum-threads/\(threadID)/replies"
			case .vote(let threadID):
				return "forum-threads/\(threadID)/vote"
			case .lock(let threadID):
				return "forum-threads/\(threadID)/lock"
			case .search:
				return "forum-threads/search"
			}
		}
	}
}

// MARK: - Replies
extension KKEndpoint.Forums {
	/// The set of available Replies API endpoints types.
	internal enum Replies {
		// MARK: - Cases
		/// The endpoint to vote on a forums reply.
		case vote(_ replyID: Int)

		// MARK: - Properties
		/// The endpoint value of the Replies API type.
		var endpointValue: String {
			switch self {
			case .vote(let replyID):
				return "forum-replies/\(replyID)/vote"
			}
		}
	}
}
