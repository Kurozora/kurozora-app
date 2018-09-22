//
//  Session.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

struct Session: JSONDecodable {
    let success: Bool?
    let message: String?
    let otherSessions: [JSON]?
    
    // Current session
    let id: Int?
    let device: String?
    let ip: String?
    let lastValidated: String?
    
    init(json: JSON) throws {
        success = json["success"].boolValue
        message = json["error_message"].stringValue
        otherSessions = json["other_sessions"].arrayValue
        
        // Current session
        id = json["current_session"]["id"].intValue
        device = json["current_session"]["device"].stringValue
        ip = json["current_session"]["ip"].stringValue
        lastValidated = json["current_session"]["last_validated"].stringValue
    }
}
