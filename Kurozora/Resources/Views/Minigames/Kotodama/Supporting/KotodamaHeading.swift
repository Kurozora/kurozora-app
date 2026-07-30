//
//  KotodamaHeading.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

struct KotodamaHeading: Hashable {
	// MARK: - Properties
	/// The text to show.
	let text: String

	/// Whether the text reads as a section heading rather than a footnote.
	let isProminent: Bool
}
