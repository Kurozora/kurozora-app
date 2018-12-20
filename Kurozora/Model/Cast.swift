//
//  Cast.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class CastDetails: JSONDecodable {
    let success: Bool?
    let message: String?
    let page: Int?
    let actorsPerPage: Int?
    let totalActors: Int?
    let actors: [JSON]?

    required init(json: JSON) throws {
        success = json["success"].boolValue
        message = json["error_message"].stringValue
        page = json["page"].intValue
        actorsPerPage = json["actors_per_page"].intValue
        totalActors = json["total_actors"].intValue
        actors = json["actors"].arrayValue
        
//        castImage = json["actors"]["image"].stringValue
//        castName = json["actors"]["name"].stringValue
//        castRole = json["actors"]["role"].stringValue
    }
}
