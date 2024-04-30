//
//  CastResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 15/08/2020.
//

/// A root object that stores information about a collection of cast.
public struct CastResponse: Codable {
	// MARK: - Properties
	/// The data included in the response for a cast object request.
	public let data: [Cast]

	/// The realtive URL to the next page in the paginated response.
	public let next: String?
}
