//
//  MediaType.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 14/06/2021.
//

/// A root object that stores information about a media type resource.
public struct MediaType: Codable, Hashable {
	// MARK: - Properties
	/// The name of the media type.
	public let name: String

	/// The description of the media type.
	public let description: String

	// MARK: - Functions
	public static func == (lhs: MediaType, rhs: MediaType) -> Bool {
		return lhs.name == rhs.name
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.name)
	}
}
