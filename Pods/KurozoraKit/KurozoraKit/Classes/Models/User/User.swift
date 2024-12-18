//
//  User.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 17/05/2018.
//

/// A root object that stores information about a user resource.
public class User: IdentityResource, Hashable {
	// MARK: - Properties
	public let id: String

	public let uuid: UUID

	public let type: String

	public let href: String

	/// An object which holds information about the current user.
	public static var current: User? = nil

	/// The attributes belonging to the user.
	public var attributes: User.Attributes

	/// The relationships blonging to yhe user.
	public let relationships: User.Relationships?

	// MARK: - Functions
	public static func == (lhs: User, rhs: User) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}

// MARK: - Helpers
extension User {
	// MARK: - Properties
	/// Returns a boolean indicating if the current user is signed in.
	public static var isSignedIn: Bool {
		return User.current != nil
	}

	/// Returns a boolean indicating if the current signed in user has a pro account.
	public static var isPro: Bool {
		guard let currentUser = User.current else { return false }
		return currentUser.attributes.isPro
	}

	/// Returns a boolean indicating if the current signed in user has a Kurozra+ subscription.
	public static var isSubscribed: Bool {
		guard let currentUser = User.current else { return false }
		return currentUser.attributes.isSubscribed
	}

	// MARK: - Functions
	/// Updates the user with the given details.
	///
	/// - Parameter userDetails: The details used to update the current user's details.
	internal func updateDetails(with userDetails: User) {
		self.attributes.profile = userDetails.attributes.profile
		self.attributes.banner = userDetails.attributes.banner
		self.attributes.biography = userDetails.attributes.biography
	}
}
