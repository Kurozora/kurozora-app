//
//  RelatedGameResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 01/03/2023.
//

/// A root object that stores information about a collection of related games.
public struct RelatedGameResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a related games object request.
	public let data: [RelatedGame]

	/// The realtive URL to the next page in the paginated response.
	public let next: String?
}
