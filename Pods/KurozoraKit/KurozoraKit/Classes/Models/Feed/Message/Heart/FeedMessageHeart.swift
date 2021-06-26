//
//  FeedMessageHeart.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 28/08/2020.
//

/**
	A root object that stores information about a single feed message vote, such as the vote action.
*/
public struct FeedMessageHeart: Codable {
	// MARK: - Properties
	/// Whether the message is hearted or not.
	public let isHearted: Bool
}
