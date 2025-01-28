//
//  FeedMessageResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/08/2020.
//

/// A root object that stores information about a collection of feed messages.
public struct FeedMessageResponse: Codable, Sendable {
	// MARK: - Properties
	/// The data included in the response for a feed message object request.
	public let data: [FeedMessage]

	/// The relative URL to the next page in the paginated response.
	public let next: String?
}
