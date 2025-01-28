//
//  AdaptationSource.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 14/06/2021.
//

/// A root object that stores information about an adaptation source resource.
public struct AdaptationSource: Codable, Hashable, Sendable {
	// MARK: - Properties
	/// The name of the adaptation source.
	public let name: String

	/// The description of the adaptation source.
	public let description: String

	// MARK: - Functions
	public static func == (lhs: AdaptationSource, rhs: AdaptationSource) -> Bool {
		return lhs.name == rhs.name
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.name)
	}
}
