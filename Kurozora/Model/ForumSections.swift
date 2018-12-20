//
//  ForumSections.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class ForumSections: JSONDecodable {
    let success: Bool?
    let message: String?
    let sections: [JSON]?
    
    required init(json: JSON) throws {
        success = json["success"].boolValue
        message = json["error_message"].stringValue
        sections = json["sections"].arrayValue
    }
}
