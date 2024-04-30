//
//  OAuthResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 22/08/2020.
//

/// A root object that stores information about an OAuth sign in object request.
public struct OAuthResponse: Codable {
	// MARK: - Properties
	/// The data included in the response for a sign in object request.
	public let data: [User]?

	/// The authentication token included in the response for a sign in object request.
	public let authenticationToken: String

	/// The next action to follow if available.
	public let action: OAuthAction?
}
