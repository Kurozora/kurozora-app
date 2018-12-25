//
//  Models.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import TRON
import SwiftyJSON

class Show: JSONDecodable {
    let success: Bool?
    let banners: [JSON]?
    let categories: [JSON]?

    required init(json: JSON) throws {
        success = json["success"].boolValue
        banners = json["banners"].arrayValue
        categories = json["categories"].arrayValue
    }
}
