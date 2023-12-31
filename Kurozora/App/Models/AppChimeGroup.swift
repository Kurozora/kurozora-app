//
//  AppChimeGroup.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/12/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import Foundation

/// A struct that stores information about a collection of app chimes, such as the different collections of chimes.
struct AppChimeGroup: Codable {
	// MARK: - Properties
	/// The title of the chime group.
	let title: String

	/// The chimes in the chime group.
	let chimes: [AppChimeElement]
}

struct AppChimeElement: Codable {
	// MARK: - Properties
	/// The name of the chime.
	let name: String

	/// The file name of the chime.
	let file: String
}
