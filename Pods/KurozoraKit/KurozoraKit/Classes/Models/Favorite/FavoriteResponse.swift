//
//  FavoriteResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 13/08/2020.
//

/// A root object that stores information about a model's favorite status.
public struct FavoriteResponse: Codable, Sendable {
	// MARK: - Properties
	/// The data included in the response for a favorite model object request.
	public let data: Favorite
}
