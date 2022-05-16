//
//  UserResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 05/08/2020.
//

/// A root object that stores information about a collection of users.
public struct UserResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a user object request.
	public let data: [User]

	/// The realtive URL to the next page in the paginated response.
	public let next: String?
}
