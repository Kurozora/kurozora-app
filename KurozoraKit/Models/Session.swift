//
//  Session.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

public class UserSessions: JSONDecodable {
    public let success: Bool?
	public let authToken: String?
	public let user: UserProfile?
	public let currentSessions: UserSessionsElement?
    public var otherSessions: [UserSessionsElement]?

    required public init(json: JSON) throws {
		self.success = json["success"].boolValue
		self.authToken = json["kuro_auth_token"].stringValue
		self.user = try? UserProfile(json: json["user"])
		if !json["current_session"].isEmpty {
			self.currentSessions = try? UserSessionsElement(json: json["current_session"])
		} else {
			self.currentSessions = try? UserSessionsElement(json: json["session"])
		}
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

public class UserSessionsElement: JSONDecodable {
	public let id: Int?
	public let device: String?
	public let ip: String?
	public let lastValidated: String?
	public let location: UserSessionsLocation?

	required public init(json: JSON) throws {
		self.id = json["id"].intValue
		self.device = json["device"].stringValue
		self.ip = json["ip"].stringValue
		self.lastValidated = json["last_validated"].stringValue
		self.location = try? UserSessionsLocation(json: json["location"])
	}
}

public class UserSessionsLocation: JSONDecodable {
	public let city: String?
	public let region: String?
	public let country: String?
	public let latitude: Double?
	public let longitude: Double?

	required public init(json: JSON) throws {
		self.city = json["city"].stringValue
		self.region = json["region"].stringValue
		self.country = json["country"].stringValue
		self.latitude = json["latitude"].doubleValue
		self.longitude = json["longitude"].doubleValue
	}
}
