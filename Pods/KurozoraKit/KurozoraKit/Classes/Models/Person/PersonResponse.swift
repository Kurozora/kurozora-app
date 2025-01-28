//
//  PersonResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 09/09/2018.
//

/// A root object that stores information about a collection of people.
public struct PersonResponse: Codable, Sendable {
	// MARK: - Properties
	/// The data included in the response for a person object request.
	public let data: [Person]

	/// The relative URL to the next page in the paginated response.
	public let next: String?
}
