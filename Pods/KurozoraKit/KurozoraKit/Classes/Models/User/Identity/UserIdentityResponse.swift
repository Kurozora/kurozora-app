//
//  UserIdentityResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 22/05/2022.
//

/// A root object that stores information about a collection of user identities.
public struct UserIdentityResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a user identity object request.
	public let data: [UserIdentity]

	/// The realtive URL to the next page in the paginated response.
	public let next: String?
}
