//
//  FollowUpdateResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 14/08/2020.
//

/// A root object that stores information about a user's follow update.
public struct FollowUpdateResponse: Codable {
	// MARK: - Properties
	/// The data included in the response for a user follow update object request.
	public let data: FollowUpdate
}
