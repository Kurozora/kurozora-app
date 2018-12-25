//
//  Notification.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class UserNotification: JSONDecodable {
    let success: Bool?
    let notifications: [JSON]?
    
    required init(json: JSON) throws {
        success = json["success"].boolValue
        notifications = json["notifications"].arrayValue
    }
}
