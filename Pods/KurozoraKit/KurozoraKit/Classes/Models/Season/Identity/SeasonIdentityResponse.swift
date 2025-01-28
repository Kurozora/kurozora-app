//
//  SeasonIdentityResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 12/02/2022.
//

/// A root object that stores information about a collection of season identities.
public struct SeasonIdentityResponse: Codable, Sendable {
	// MARK: - Properties
	/// The data included in the response for a season identity object request.
	public let data: [SeasonIdentity]

	/// The relative URL to the next page in the paginated response.
	public let next: String?
}
