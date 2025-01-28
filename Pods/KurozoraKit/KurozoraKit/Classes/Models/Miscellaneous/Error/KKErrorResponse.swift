//
//  KKErrorResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 11/08/2020.
//

/// A root object that stores information about an error.
public struct KKErrorResponse: Codable, Sendable {
	// MARK: - Properties
	/// An array of one or more errors that occurred while executing the operation.
	let errors: [KKError]
}
