//
//  AiringStatus.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 14/06/2021.
//

import Foundation

/// A root object that stores information about an airing status resource.
public struct AiringStatus: Codable, Hashable {
	// MARK: - Properties
	/// The name of the airing status.
	public let name: String

	/// The description of the airing status.
	public let description: String

	/// The color of the airing status.
	public let color: String

	// MARK: - Functions
	public static func == (lhs: AiringStatus, rhs: AiringStatus) -> Bool {
		return lhs.name == rhs.name
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.name)
	}
}
