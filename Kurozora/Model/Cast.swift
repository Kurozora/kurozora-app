//
//  Cast.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

struct CastDetails: JSONDecodable {
    let success: Bool?
    let message: String?
    let actors: Array<Any>?
    
    let castImage: String?
    let castName: String?
    let castRole: String?
    
    init(json: JSON) throws {
        success = json["success"].boolValue
        message = json["error_message"].stringValue
        actors = json["actors"].arrayValue
        
        castImage = json["actors"]["image"].stringValue
        castName = json["actors"]["name"].stringValue
        castRole = json["actors"]["role"].stringValue
    }
}
