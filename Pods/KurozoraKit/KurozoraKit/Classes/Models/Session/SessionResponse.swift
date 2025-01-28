//
//  SessionResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 19/09/2018.
//

/// A root object that stores information about a session response.
public struct SessionResponse: Codable, Sendable {
	// MARK: - Properties
	/// The data included in the response for a session object request.
	public let data: [Session]

	/// The relative URL to the next page in the paginated response.
	public let next: String?
}
