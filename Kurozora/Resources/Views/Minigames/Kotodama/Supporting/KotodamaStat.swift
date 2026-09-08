//
//  KotodamaStat.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

struct KotodamaStat: nonisolated Hashable, Sendable {
	// MARK: - Properties
	/// The name of the value.
	let title: String

	/// The value itself.
	let value: String
}
