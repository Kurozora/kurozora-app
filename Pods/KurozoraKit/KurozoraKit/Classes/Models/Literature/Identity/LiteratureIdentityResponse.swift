//
//  LiteratureIdentityResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/01/2023.
//

/// A root object that stores information about a collection of literature identities.
public struct LiteratureIdentityResponse: Codable, Sendable {
	// MARK: - Properties
	/// The data included in the response for a literature identity object request.
	public let data: [LiteratureIdentity]

	/// The relative URL to the next page in the paginated response.
	public let next: String?
}
