//
//  ReviewResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/07/2023.
//

/// A root object that stores information about a collection of reviews.
public struct ReviewResponse: Codable {
	// MARK: - Properties
	/// The data included in the response for an review object request.
	public let data: [Review]

	/// The realtive URL to the next page in the paginated response.
	public let next: String?
}
