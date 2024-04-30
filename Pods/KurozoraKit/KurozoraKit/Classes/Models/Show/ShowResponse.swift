//
//  ShowDetails.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 09/10/2018.
//

/// A root object that stores information about a collection of shows.
public struct ShowResponse: Codable {
	// MARK: - Properties
	/// The data included in the response for a show object request.
	public let data: [Show]

	/// The realtive URL to the next page in the paginated response.
	public let next: String?
}
