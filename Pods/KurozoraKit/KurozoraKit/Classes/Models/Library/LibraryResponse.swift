//
//  LibraryResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 06/02/2023.
//

/// A root object that stores information about a collection of libraries.
public struct LibraryResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a search object request.
	public let data: Library

	/// The realtive URL to the next page in the paginated response.
	public let next: String?
}
