//
//  Seasons.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class Seasons: JSONDecodable {
    let success: Bool?
    let message: String?
    let seasons: [JSON]?
    
    required init(json: JSON) throws {
        success = json["success"].boolValue
        message = json["error_message"].stringValue
        seasons = json["seasons"].arrayValue
    }
}
