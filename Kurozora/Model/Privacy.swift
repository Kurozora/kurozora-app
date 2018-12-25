//
//  Privacy.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class Privacy: JSONDecodable {
    let success: Bool?
    let text: String?
    let lastUpdate: String?
    
    required init(json: JSON) throws {
        success = json["success"].boolValue
        text = json["privacy_policy"]["text"].stringValue
        lastUpdate = json["privacy_policy"]["last_update"].stringValue
    }
}
