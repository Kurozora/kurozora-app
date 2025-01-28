//
//  RecapItemResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 04/01/2024.
//

/// A root object that stores information about a collection of recap items.
public struct RecapItemResponse: Codable, Sendable {
	// MARK: - Properties
	/// The data included in the response for an recap item object request.
	public let data: [RecapItem]

	/// The relative URL to the next page in the paginated response.
	public let next: String?
}
