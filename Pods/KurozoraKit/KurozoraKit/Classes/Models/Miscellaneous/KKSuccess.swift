//
//  KKSuccess.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 10/04/2020.
//

/// An immutable object that stores information about a single successful request, such as the success message.
public struct KKSuccess: Codable {
	// MARK: - Properties
	/// The message of a successful request.
	public var message: String?
}
