//
//  UserIdentityResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 22/05/2022.
//

/// A root object that stores information about a collection of user identities.
public struct UserIdentityResponse: Codable, Sendable {
	// MARK: - Properties
	/// The data included in the response for a user identity object request.
	public let data: [UserIdentity]

	/// The relative URL to the next page in the paginated response.
	public let next: String?
}
