//
//  Location.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

/// A root object that stores information about a location resource.
public struct Location: Codable {
	// MARK: - Properties
	/// The type of the resource.
	public let type: String

	/// The attributes belonging to the location.
	public let attributes: Location.Attributes
}
