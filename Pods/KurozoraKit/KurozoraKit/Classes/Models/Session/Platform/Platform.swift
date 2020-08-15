//
//  Platform.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

/**
	A root object that stores information about a platform resource.
*/
public struct Platform: Codable {
	// MARK: - Properties
	/// The type of the resource.
	public let type: String

	/// The attributes belonging to the platform.
	public let attributes: Platform.Attributes
}
