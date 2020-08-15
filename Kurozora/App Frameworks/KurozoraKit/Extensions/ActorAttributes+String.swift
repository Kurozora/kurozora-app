//
//  ActorAttributes+String.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit

// MARK: - Helpers
extension Actor.Attributes {
	// MARK: - Properties
	/// The full name of the actor.
	public var fullName: String {
		return lastName.isEmpty ? firstName : lastName + ", " + firstName
	}
}
