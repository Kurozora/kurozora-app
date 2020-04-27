//
//  User.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about a single user, such as the user's profile, and authentication token.
*/
public class User: JSONDecodable {
	// MARK: - Properties
	/// The profile update message.
	public let message: String?

	/// The authentication token of the user.
	public let kuroAuthToken: String?

	/// An object which holds information about the current user.
	public static var current: CurrentUser? = nil

	/// The profile details of the user.
	public var profile: UserProfile?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.message = json["message"].stringValue
		self.kuroAuthToken = json["kuro_auth_token"].stringValue

		if !json["session"].isEmpty {
			User.current = try? CurrentUser(json: json)
			User.current?.authenticationKey = self.kuroAuthToken
		} else {
			self.profile = try? UserProfile(json: json["user"])
		}
	}
}

// MARK: - Helpers
extension User {
	/// Returns a boolean indicating if the current user is signed in.
	public static var isSignedIn: Bool {
		return User.current != nil
	}

	/// Returns a boolean indicating if the current user has purchased PRO.
	static var isPro: Bool {
		return true
	}
}
