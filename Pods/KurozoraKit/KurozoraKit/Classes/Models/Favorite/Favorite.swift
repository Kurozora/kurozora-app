//
//  Favorite.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 31/01/2020.
//

/// A root object that stores information about a favorite model resource.
public struct Favorite: Codable, Sendable {
	// MARK: - Properties
	/// Whether the model is favorited.
	internal let isFavorited: Bool
}

// MARK: - Helpers
extension Favorite {
	// MARK: - Properties
	/// The favorite status of the model.
	public var favoriteStatus: FavoriteStatus {
		return FavoriteStatus(self.isFavorited)
	}
}
