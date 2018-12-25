//
//  Episodes.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class Episodes: JSONDecodable {
    let success: Bool?
    let episodeCount: Int?
    let episodes: [JSON]?
    
    required init(json: JSON) throws {
        success = json["success"].boolValue
        episodeCount = json["season"]["episode_count"].intValue
        episodes = json["episodes"].arrayValue
    }
}
