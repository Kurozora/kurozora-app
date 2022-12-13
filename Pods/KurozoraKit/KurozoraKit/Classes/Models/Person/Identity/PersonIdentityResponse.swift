//
//  PersonIdentityResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 25/02/2022.
//

/// A root object that stores information about a collection of person identities.
public struct PersonIdentityResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a person identity object request.
	public let data: [PersonIdentity]

	/// The realtive URL to the next page in the paginated response.
	public let next: String?
}
