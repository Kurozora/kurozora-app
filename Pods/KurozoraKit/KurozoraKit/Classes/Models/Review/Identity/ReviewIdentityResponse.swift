//
//  ReviewIdentityResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 22/03/2024.
//

/// A root object that stores information about a collection of reviews.
public struct ReviewIdentityResponse: Codable, Sendable {
	// MARK: - Properties
	/// The data included in the response for an review object request.
	public let data: [ReviewIdentity]

	/// The relative URL to the next page in the paginated response.
	public let next: String?
}
