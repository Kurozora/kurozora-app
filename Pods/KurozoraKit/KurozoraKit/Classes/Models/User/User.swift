//
//  User.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 17/05/2018.
//

/**
	A root object that stores information about a user resource.
*/
public struct User: IdentityResource {
	// MARK: - Properties
	public let id: Int

	public let type: String

	public let href: String

	/// An object which holds information about the current user.
	public static var current: User? = nil

	/// The attributes belonging to the user.
	public var attributes: User.Attributes

	/// The relationships blonging to yhe user.
	public let relationships: User.Relationships?
}

// MARK: - Helpers
extension User {
	// MARK: - Properties
	/// Returns a boolean indicating if the current user is signed in.
	public static var isSignedIn: Bool {
		return User.current != nil
	}

	/// Returns a boolean indicating if the current user has purchased PRO.
	static var isPro: Bool {
		return true
	}

	// MARK: - Functions
	/**
		Updates the user with the given details.

		- Parameter userDetails: The details used to update the current user's details.
	*/
	internal mutating func updateDetails(with userDetails: User) {
		self.attributes.profileImageURL = userDetails.attributes.profileImageURL
		self.attributes.bannerImageURL = userDetails.attributes.bannerImageURL
		self.attributes.biography = userDetails.attributes.biography
	}
}
