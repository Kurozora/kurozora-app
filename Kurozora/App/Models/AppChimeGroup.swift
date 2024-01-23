//
//  AppChimeGroup.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/12/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import Foundation

/// A struct that stores information about a collection of app chimes, such as the different collections of chimes.
struct AppChimeGroup: Codable, Hashable {
	// MARK: - Properties
	/// The title of the chime group.
	let title: String

	/// The chimes in the chime group.
	let chimes: [[AppChimeElement]]

	// MARK: - Functions
	static func == (lhs: AppChimeGroup, rhs: AppChimeGroup) -> Bool {
		return lhs.title == rhs.title
	}
}

struct AppChimeElement: Codable, Hashable {
	// MARK: - Properties
	/// The name of the chime.
	let name: String

	/// The file name of the chime.
	let file: String

	/// The file name of an alternative version of the chime.
	let alternativeFile: String?

	/// The number of taps required to play the alternative file.
	let alternativeFileRequiredTaps: Int?

	// MARK: - Functions
	static func == (lhs: AppChimeElement, rhs: AppChimeElement) -> Bool {
		return lhs.name == rhs.name
	}
}
