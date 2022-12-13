//
//  SeasonResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 11/10/2018.
//

/// A root object that stores information about a collection of seasons.
public struct SeasonResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a season object request.
	public let data: [Season]

	/// The realtive URL to the next page in the paginated response.
	public let next: String?
}
