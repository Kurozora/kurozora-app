//
//  UserSessionsElement.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about a single user session, such as the session's ip address, last validated date, and platform.
*/
public class UserSessionsElement: JSONDecodable {
	// MARK: - Properties
	/// The id of the session.
	public var id: Int?

	/// The ip address form where the session was created.
	public let ip: String?

	/// The last time the session has been validated.
	public let lastValidated: String?

	/// The platform on which the session was created.
	public let platform: PlatformElement?

	/// The location where the session was created.
	public let location: LocationElement?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.id = json["id"].intValue
		self.ip = json["ip"].stringValue
		self.lastValidated = json["last_validated_at"].stringValue
		self.platform = try? PlatformElement(json: json["platform"])
		self.location = try? LocationElement(json: json["location"])
	}
}
