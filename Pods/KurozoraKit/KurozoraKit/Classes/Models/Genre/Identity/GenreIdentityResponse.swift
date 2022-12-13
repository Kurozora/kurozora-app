//
//  GenreIdentityResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 25/02/2022.
//

/// A root object that stores information about a collection of genre identities.
public struct GenreIdentityResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a episode identity object request.
	public let data: [GenreIdentity]

	/// The realtive URL to the next page in the paginated response.
	public let next: String?
}
