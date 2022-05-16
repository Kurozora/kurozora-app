//
//  StudioIdentityResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 25/02/2022.
//

/// A root object that stores information about a collection of studio identities.
public struct StudioIdentityResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a studio identity object request.
	public let data: [StudioIdentity]

	/// The realtive URL to the next page in the paginated response.
	public let next: String?
}
