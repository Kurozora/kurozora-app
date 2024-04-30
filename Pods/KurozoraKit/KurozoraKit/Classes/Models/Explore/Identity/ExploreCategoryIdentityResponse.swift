//
//  ExploreCategoryIdentityResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 18/06/2022.
//

/// A root object that stores information about a collection of explore category identities.
public struct ExploreCategoryIdentityResponse: Codable {
	// MARK: - Properties
	/// The data included in the response for an explore category identity object request.
	public let data: [ExploreCategoryIdentity]

	/// The realtive URL to the next page in the paginated response.
	public let next: String?
}
