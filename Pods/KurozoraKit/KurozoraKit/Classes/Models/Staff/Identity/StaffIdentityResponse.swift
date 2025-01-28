//
//  StaffIdentityResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/10/2023.
//

/// A root object that stores information about a collection of staff identities.
public struct StaffIdentityResponse: Codable, Sendable {
	// MARK: - Properties
	/// The data included in the response for a staff identity object request.
	public let data: [StaffIdentity]

	/// The relative URL to the next page in the paginated response.
	public let next: String?
}
