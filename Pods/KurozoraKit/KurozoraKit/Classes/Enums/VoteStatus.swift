//
//  VoteStatus.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 06/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Foundation

/**
	The set of available vote status types.

	```
	case downVote = -1
	case noVote = 0
	case upVote = 1
	```
*/
public enum VoteStatus: Int {
	// MARK: - Cases
	/// The thread/reply is downvoted.
	case downVote = -1

	/// The thread/reply has no vote.
	case noVote = 0

	/// The thread/reply is upvoted.
	case upVote = 1

	// MARK: - Properties
	/// The vote value of a vote status type.
	public var voteValue: Int {
		switch self {
		case .upVote:
			return 1
		case .downVote:
			return 0
		case .noVote:
			return 0
		}
	}
}
