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
    var sessions: [JSON]?
    
    let id: Int?
    let secret: String?
    let device: String?
    let ip: String?
    let lastValidated: String?
    
    init(json: JSON) throws {
        success = json["success"].boolValue
        message = json["error_message"].stringValue
        sessions = json["sessions"].arrayValue
        
        id = json["sessions"]["id"].intValue
        secret = json["sessions"]["secret"].stringValue
        device = json["sessions"]["device"].stringValue
        ip = json["sessions"]["ip"].stringValue
        lastValidated = json["sessions"]["last_validated"].stringValue
    }
    
    func getSessionId() -> Int {
        if let sessionId = self.id {
            return sessionId
        }

        return 0
    }
}
