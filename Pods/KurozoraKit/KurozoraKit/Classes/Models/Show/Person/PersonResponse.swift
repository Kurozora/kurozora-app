//
//  PersonResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 09/09/2018.
//

/**
	A root object that stores information about a collection of people.
*/
public struct PersonResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a person object request.
	public let data: [Person]
}
