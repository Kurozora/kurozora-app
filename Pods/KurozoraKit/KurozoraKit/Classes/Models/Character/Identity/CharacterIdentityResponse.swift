//
//  CharacterIdentityResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 25/02/2022.
//

/// A root object that stores information about a collection of character identities.
public struct CharacterIdentityResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a Character identity object request.
	public let data: [CharacterIdentity]

	/// The realtive URL to the next page in the paginated response.
	public let next: String?
}
