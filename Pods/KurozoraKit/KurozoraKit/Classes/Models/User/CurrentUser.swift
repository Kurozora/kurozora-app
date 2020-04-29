//
//  CurrentUser.swift
//  Alamofire
//
//  Created by Khoren Katklian on 27/04/2020.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about the current user, such as the current user's username, bio, and session.
*/
public class CurrentUser: UserProfile {
	// MARK: - Properties
	/// The authnetication key of the current user.
	internal var authenticationKey: String?

	/// The session of the current user.
	public let session: UserSessionsElement?

	// MARK: - Initializers
	/// Creates model object from SwiftyJSON.JSON struct.
	required public init(json: JSON) throws {
		self.session = try? UserSessionsElement(json: json["session"])
		try super.init(json: json["user"])
	}

	// MARK: - Functions
	/**
		Updates the user with the given details.

		- Parameter userDetails: The details used to update the vurrent user's details.
	*/
	func updateDetails(with userDetails: UserProfile) {
		self.profileImageURL = userDetails.profileImageURL
		self.bannerImageURL = userDetails.bannerImageURL
		self.biography = userDetails.biography
	}
}
