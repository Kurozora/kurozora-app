//
//  LocationResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 05/08/2020.
//

/// A root object that stores information about a collection of locations.
public struct LocationResponse: Codable {
	// MARK: - Properties
	/// The data included in the response for a location object request.
	public let data: [Location]
}
