//
//  QuickAction.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/04/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import Foundation

struct QuickAction: Hashable {
	let id: UUID = UUID()
	let title: String
	let segueID: String

	// MARK: - Functions
	public static func == (lhs: QuickAction, rhs: QuickAction) -> Bool {
		lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
