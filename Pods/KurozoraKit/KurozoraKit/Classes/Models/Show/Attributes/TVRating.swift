//
//  TVRating.swift
//  Alamofire
//
//  Created by Khoren Katklian on 24/04/2021.
//

import Foundation

/**
	A root object that stores information about a TV rating resource.
*/
public struct TVRating: Codable, Hashable {
	// MARK: - Properties
	/// The name of the TV rating.
	public let name: String

	/// The description of the TV rating.
	public let description: String

	// MARK: - Functions
	public static func == (lhs: TVRating, rhs: TVRating) -> Bool {
		return lhs.name == rhs.name
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.name)
	}
}
