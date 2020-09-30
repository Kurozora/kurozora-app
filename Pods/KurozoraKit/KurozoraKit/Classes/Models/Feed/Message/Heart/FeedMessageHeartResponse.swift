//
//  FeedMessageHeartResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 28/08/2020.
//

/**
	A root object that stores information about a feed message heart.
*/
public struct FeedMessageHeartResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a feed message heart object request.
	public let data: FeedMessageHeart
}

