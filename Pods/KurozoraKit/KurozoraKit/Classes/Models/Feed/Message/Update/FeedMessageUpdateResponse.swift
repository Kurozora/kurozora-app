//
//  FeedMessageUpdateResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 06/08/2020.
//

/// A root object that stores information about a feed message update.
public struct FeedMessageUpdateResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a feed message update object request.
	public let data: FeedMessageUpdate
}
