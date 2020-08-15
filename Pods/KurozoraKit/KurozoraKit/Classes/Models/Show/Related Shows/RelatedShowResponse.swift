//
//  RelatedShowResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 13/08/2020.
//

/**
	A root object that stores information about a collection of related shows.
*/
public struct RelatedShowResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a related show object request.
	public let data: [RelatedShow]
}
