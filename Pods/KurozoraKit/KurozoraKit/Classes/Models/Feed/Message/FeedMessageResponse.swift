//
//  FeedMessageResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/08/2020.
//

/// A root object that stores information about a collection of feed messages.
public struct FeedMessageResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a feed message object request.
	public let data: [FeedMessage]

	/// The realtive URL to the next page in the paginated response.
	public let next: String?
}
