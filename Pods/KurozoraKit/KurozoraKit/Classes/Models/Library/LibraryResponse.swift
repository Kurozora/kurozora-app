//
//  LibraryResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 06/02/2023.
//

/// A root object that stores information about a collection of libraries.
public struct LibraryResponse: Codable, Sendable {
	// MARK: - Properties
	/// The data included in the response for a library object request.
	public let data: Library

	/// The relative URL to the next page in the paginated response.
	public let next: String?

	/// The total number of available library items.
	public let total: Int?
}
