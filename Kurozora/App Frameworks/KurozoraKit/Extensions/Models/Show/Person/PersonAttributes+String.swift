//
//  PersonAttributes+String.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit

// MARK: - Helpers
extension Person.Attributes {
	// MARK: - Properties
	/// The full name of the person.
	public var fullName: String {
		let lastName = self.lastName ?? ""

		if lastName.isEmpty {
			return self.firstName
		}

		return lastName + ", " + self.firstName
	}
}
