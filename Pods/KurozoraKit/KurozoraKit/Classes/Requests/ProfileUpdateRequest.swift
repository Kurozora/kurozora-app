//
//  ProfileUpdateRequest.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 13/11/2022.
//

/// A root object that stores information about a profile update request.
public struct ProfileUpdateRequest {
	// MARK: - Properties
	/// The username of the user.
	public let username: String?

	/// The nickname of the user.
	public let nickname: String?

	/// The biography of the user.
	public let biography: String?

	/// The profile image of the user,
	public let profileImage: URL?

	/// The banner image of the user.
	public let bannerImage: URL?

	/// The preferred language of the user.
	public let preferredLanguage: String?

	/// The preferred TV rating of the user.
	public let preferredTVRating: Int?

	/// The preferred timezone of the user.
	public let preferredTimezone: String?

	// MARK: - Initializers
	/// Initialize a new instance of `ProfileUpdateRequest` to request changes in a user's profile.
	///
	/// - Parameters:
	///    - username: The new username of the user.
	///    - nickname: The new nickname of the user.
	///    - biography: The new biography of the user.
	///    - profileImage: The path to the new profile image of the user.
	///    - bannerImage: The path to the new banner image of the user.
	///    - preferredLanguage: The new preferred language.
	///    - preferredTVRating: The new preferred TV rating.
	///    - preferredTimezone: The new preferred timezone.
	public init(username: String?, nickname: String?, biography: String?, profileImage: URL?, bannerImage: URL?, preferredLanguage: String?, preferredTVRating: Int?, preferredTimezone: String?) {
		self.username = username
		self.nickname = nickname
		self.biography = biography
		self.profileImage = profileImage
		self.bannerImage = bannerImage
		self.preferredLanguage = preferredLanguage
		self.preferredTVRating = preferredTVRating
		self.preferredTimezone = preferredTimezone

	}
}
