//
//  FavoriteShow.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 31/01/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

/// A root object that stores information about a favorite show resource.
public struct FavoriteShow: Codable {
	// MARK: - Properties
	/// Whether the show is favorited.
	public let isFavorited: Bool
}

// MARK: - Helpers
extension FavoriteShow {
	// MARK: - Properties
	/// The favorite status of the show.
	public var favoriteStatus: FavoriteStatus {
		return FavoriteStatus(self.isFavorited)
	}
}
