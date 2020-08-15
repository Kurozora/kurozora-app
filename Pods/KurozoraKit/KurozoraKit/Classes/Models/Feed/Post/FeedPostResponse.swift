//
//  FeedPostResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 07/08/2020.
//

/**
	A root object that stores information about a collection of feed posts.
*/
public struct FeedPostResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a feed post object request.
	public let data: [FeedPost]

	/// The realtive URL to the next page in the paginated response.
	public let next: String?
}
