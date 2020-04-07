//
//  FavoriteShow.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/01/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

public class FavoriteShow: JSONDecodable {
	public let success: Bool?
	public let isFavorite: Int?

	required public init(json: JSON) throws {
		self.success = json["success"].boolValue
		self.isFavorite = json["is_favorite"].intValue
	}
}
