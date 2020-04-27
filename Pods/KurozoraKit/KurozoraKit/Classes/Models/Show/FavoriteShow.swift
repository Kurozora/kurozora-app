//
//  FavoriteShow.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/01/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about a show's favorite status.
*/
public class FavoriteShow: JSONDecodable {
	// MARK: - Properties
	/// The favorite status of the show.
	public let favoriteStatus: FavoriteStatus?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.favoriteStatus = FavoriteStatus(rawValue: json["is_favorite"].intValue)
	}
}
