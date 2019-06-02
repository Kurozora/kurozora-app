//
//  Session.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class UserSessions: JSONDecodable {
    let success: Bool?
	let currentSessions: UserSessionsElement?
    var otherSessions: [UserSessionsElement]?
    
    required init(json: JSON) throws {
        success = json["success"].boolValue
		self.currentSessions = try? UserSessionsElement(json: json["current_session"])
		var otherSessions = [UserSessionsElement]()

        let otherSessionsArray = json["other_sessions"].arrayValue
		for otherSessionsItem in otherSessionsArray {
			if let userSessionsElement = try? UserSessionsElement(json: otherSessionsItem) {
				otherSessions.append(userSessionsElement)
			}
		}

		self.otherSessions = otherSessions
    }
}

class UserSessionsElement: JSONDecodable {
	let id: Int?
	let device: String?
	let ip: String?
	let lastValidated: String?

	required init(json: JSON) throws {
		self.id = json["id"].intValue
		self.device = json["device"].stringValue
		self.ip = json["ip"].stringValue
		self.lastValidated = json["last_validated"].stringValue
	}
}