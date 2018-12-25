//
//  Session.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class Session: JSONDecodable {
    let success: Bool?
    let otherSessions: [JSON]?
    
    // Current session
    let id: Int?
    let device: String?
    let ip: String?
    let lastValidated: String?
    
    required init(json: JSON) throws {
        success = json["success"].boolValue
        otherSessions = json["other_sessions"].arrayValue
        
        // Current session
        id = json["current_session"]["id"].intValue
        device = json["current_session"]["device"].stringValue
        ip = json["current_session"]["ip"].stringValue
        lastValidated = json["current_session"]["last_validated"].stringValue
    }
}
