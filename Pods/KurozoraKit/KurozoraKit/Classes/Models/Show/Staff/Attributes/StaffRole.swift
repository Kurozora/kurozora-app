//
//  StaffRole.swift
//  Alamofire
//
//  Created by Khoren Katklian on 15/06/2021.
//

import Foundation

/// A root object that stores information about a staff role resource.
public struct StaffRole: Codable, Hashable {
	// MARK: - Properties
	/// The name of the staff role.
	public let name: String

	/// The description of the staff role.
	public let description: String

	// MARK: - Functions
	public static func == (lhs: StaffRole, rhs: StaffRole) -> Bool {
		return lhs.name == rhs.name
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.name)
	}
}
