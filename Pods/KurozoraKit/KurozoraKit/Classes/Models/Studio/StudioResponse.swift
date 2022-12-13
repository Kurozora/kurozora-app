//
//  StudioResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 22/06/2020.
//

/// A root object that stores information about a collection of studios.
public struct StudioResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a studio object request.
	public let data: [Studio]

	/// The realtive URL to the next page in the paginated response.
	public let next: String?
}
