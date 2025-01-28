//
//  GenreResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 09/08/2020.
//

/// A root object that stores information about a collection of genres.
public struct GenreResponse: Codable, Sendable {
	// MARK: - Properties
	/// The data included in the response for a genre object request.
	public let data: [Genre]
}
