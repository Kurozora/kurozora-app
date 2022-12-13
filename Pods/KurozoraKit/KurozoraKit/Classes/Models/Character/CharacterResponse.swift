//
//  CharacterResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/06/2020

/// A root object that stores information about a collection of characters.
public struct CharacterResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a character object request.
    public let data: [Character]

	/// The realtive URL to the next page in the paginated response.
	public let next: String?
}
