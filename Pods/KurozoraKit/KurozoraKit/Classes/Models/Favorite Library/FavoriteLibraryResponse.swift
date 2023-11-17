//
//  FavoriteLibraryResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 16/11/2023.
//

/// A root object that stores information about a collection of favorite libraries.
public struct FavoriteLibraryResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a favorite library object request.
	public let data: FavoriteLibrary

	/// The realtive URL to the next page in the paginated response.
	public let next: String?
}
