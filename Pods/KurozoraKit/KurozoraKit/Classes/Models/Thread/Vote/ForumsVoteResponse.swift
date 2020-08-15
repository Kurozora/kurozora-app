//
//  ForumsVoteResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 09/12/2018.
//

/**
	A root object that stores information about a forums vote.
*/
public struct ForumsVoteResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a forums vote reply object request.
	public let data: ForumsVote
}
