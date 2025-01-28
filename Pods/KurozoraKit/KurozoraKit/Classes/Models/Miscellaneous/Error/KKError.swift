//
//  KKError.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 22/12/2018.
//

/// Information about an error that occurred while processing a request.
public struct KKError: Codable, Sendable {
	// MARK: - Properties
	/// A unique identifier for this occurrence of the error.
	let id: Int

	/// The [HTTP Status Code](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status) for this problem.
	let status: Int

	/// A long description of the problem.
	let detail: String

	/// A short description of the problem.
	let title: String
}
