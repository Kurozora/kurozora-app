//
//  CastIdentityResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 12/02/2022.
//

/// A root object that stores information about a collection of cast identities.
public struct CastIdentityResponse: Codable, Sendable {
	// MARK: - Properties
	/// The data included in the response for a cast identity object request.
	public let data: [CastIdentity]

	/// The relative URL to the next page in the paginated response.
	public let next: String?
}
