//
//  StaffRelationships.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 15/06/2021.
//

extension Staff {
	/**
		A root object that stores information about staff relationships, such as the people that belong to it.
	*/
	public struct Relationships: Codable {
		// MARK: - Properties
		/// The person who is a part of the staff.
		public let person: PersonResponse
	}
}
