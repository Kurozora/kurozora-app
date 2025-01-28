//
//  ThemeIdentityResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 25/02/2022.
//

/// A root object that stores information about a collection of theme identities.
public struct ThemeIdentityResponse: Codable, Sendable {
	// MARK: - Properties
	/// The data included in the response for a episode identity object request.
	public let data: [ThemeIdentity]

	/// The relative URL to the next page in the paginated response.
	public let next: String?
}
