//
//  Notification.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

struct UserNotification: JSONDecodable {
    let success: Bool?
    let message: String?
    let notifications: [JSON]?
    
    init(json: JSON) throws {
        success = json["success"].boolValue
        message = json["error_message"].stringValue
        notifications = json["notifications"].arrayValue
    }
}
