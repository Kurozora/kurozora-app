//
//  RecapResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 04/01/2024.
//

/// A root object that stores information about a collection of recaps.
public struct RecapResponse: Codable, Sendable {
	// MARK: - Properties
	/// The data included in the response for an recap object request.
	public let data: [Recap]

	/// The relative URL to the next page in the paginated response.
	public let next: String?
}
