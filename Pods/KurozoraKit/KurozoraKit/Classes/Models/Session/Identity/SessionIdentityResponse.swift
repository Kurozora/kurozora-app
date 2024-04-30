//
//  SessionIdentityResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 21/07/2022.
//

/// A root object that stores information about a collection of session identities.
public struct SessionIdentityResponse: Codable {
	// MARK: - Properties
	/// The data included in the response for a session identity object request.
	public let data: [SessionIdentity]

	/// The realtive URL to the next page in the paginated response.
	public let next: String?
}
