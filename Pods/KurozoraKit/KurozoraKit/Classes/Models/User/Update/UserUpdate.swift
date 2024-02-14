//
//  UserUpdate.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 14/08/2020.
//

/// A root object that stores information about a user update resource.
public struct UserUpdate: Codable {
	// MARK: - Properties
	/// The username of the user.
	public var username: String?

	/// The nickname of the user.
	public var nickname: String?

	/// The biography text of the user.
	public var biography: String?

	/// The profile image of the user.
	public var profile: Media?

	/// The banner image of the user.
	public var banner: Media?

	/// The preferred language of the user.
	public var preferredLanguage: String?

	/// The preferred TV rating of the user.
	public var preferredTVRating: String?

	/// The preferred timezone of the user.
	public var preferredTimezone: String?
}
