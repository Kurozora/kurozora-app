//
//  ShowIdentityResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 20/07/2021.
//

/// A root object that stores information about a collection of show identities.
public struct ShowIdentityResponse: Codable, Sendable {
	// MARK: - Properties
	/// The data included in the response for a show identity object request.
	public let data: [ShowIdentity]

	/// The relative URL to the next page in the paginated response.
	public let next: String?
}
