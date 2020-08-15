//
//  ForumsVote.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 08/08/2020.
//

/**
	A root object that stores information about a single forums vote, such as the vote action.
*/
public struct ForumsVote: Codable {
	// MARK: - Properties
	/// The vote action of a forums vote.
	public let voteAction: VoteStatus
}
