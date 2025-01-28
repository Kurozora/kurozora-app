//
//  GenreIdentityResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 25/02/2022.
//

/// A root object that stores information about a collection of genre identities.
public struct GenreIdentityResponse: Codable, Sendable {
	// MARK: - Properties
	/// The data included in the response for a episode identity object request.
	public let data: [GenreIdentity]

	/// The relative URL to the next page in the paginated response.
	public let next: String?
}
