//
//  UserUpdateResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 14/08/2020.
//

/// A root object that stores information about a user update.
public struct UserUpdateResponse: Codable {
	// MARK: - Properties
	/// The data included in the response for a user update object request.
	public let data: UserUpdate

	/// The message included in the response for a user update object request.
	public let message: String
}
