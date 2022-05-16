//
//  UserUpdate.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 14/08/2020.
//

/// A root object that stores information about a user update resource.
public struct UserUpdate: Codable {
	// MARK: - Properties
	/// The biography text of the user.
	public var biography: String?

	/// The profile image of the user.
	public var profile: Media?

	/// The banner image of the user.
	public var banner: Media?
}
