//
//  StaffAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 15/06/2021.
//

extension Staff {
	/**
		A root object that stores information about a single staff, such as the staff's role.
	*/
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The role of the staff.
		public let role: StaffRole
	}
}
