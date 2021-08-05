//
//  ShowIdentityResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 20/07/2021.
//

/**
	A root object that stores information about a collection of show identities.
*/
public struct ShowIdentityResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a show object request.
	public let data: [ShowIdentity]

	/// The realtive URL to the next page in the paginated response.
	public let next: String?
}
