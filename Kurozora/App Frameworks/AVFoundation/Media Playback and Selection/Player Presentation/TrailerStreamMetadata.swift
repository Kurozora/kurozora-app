//
//  TrailerStreamMetadata.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

/// The details a trailer shows wherever it plays outside the app.
struct TrailerStreamMetadata {
	/// The title of the work the trailer belongs to.
	let title: String

	/// The synopsis of the work.
	let synopsis: String?

	/// The address of the artwork representing the work.
	let artworkURL: String?
}
