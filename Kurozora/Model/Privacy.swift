//
//  Privacy.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

struct Privacy: JSONDecodable {
    let success: Bool?
    let text: String?
    let lastUpdate: String?
    let message: String?
    
    init(json: JSON) {
        success = json["success"].boolValue
        text = json["privacy_policy"]["text"].stringValue
        lastUpdate = json["privacy_policy"]["last_update"].stringValue
        message = json["error_message"].stringValue
    }
}
