//
//  EpisodesWatched.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class EpisodesWatched: JSONDecodable {
	let success: Bool?
	let watched: Bool?

	required init(json: JSON) throws {
		self.success = json["success"].boolValue
		self.watched = json["watched"].boolValue
	}
}
