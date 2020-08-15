//
//  SignInResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 08/08/2020.
//

/**
	A root object that stores information about a sign in object request.
*/
public struct SignInResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a sign in object request.
	public let data: [User]

	/// The authentication token included in the repsonse for a sign in object request.
	public let authToken: String
}
