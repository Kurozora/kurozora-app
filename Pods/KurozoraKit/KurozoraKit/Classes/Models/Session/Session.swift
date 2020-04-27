//
//  Session.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about a collection of user sessions, such as the current session, and a collection of other sessions.
*/
public class UserSessions: JSONDecodable {
	// MARK: - Properties
	/// The user profile related to the session.
	public let user: UserProfile?

	/// The user's current session.
	public let currentSessions: UserSessionsElement?

	/// The collection of the user's other sessions.
    public var otherSessions: [UserSessionsElement]?

	// MARK: - Initializers
    required public init(json: JSON) throws {
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
