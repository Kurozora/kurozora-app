//
//  AlternativeIcons.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/// A struct that stores information about a collection of alternative icons, such as the different collections of icons.
struct AlternativeIcons {
	// MARK: - Properties
	let title: String
	let icons: [AlternativeIconsElement]

	// MARK: - Initializers
	/// Initializes a new instance of `AlternativeIcons`.
	///
	/// - Parameters:
	///    - title: The title of the group
	///    - icons: The icons in the group
	init(title: String, icons: [String]) {
		self.title = title
		self.icons = icons.map { iconName in
			return AlternativeIconsElement(name: iconName)
		}
	}
}

/// A struct that stores information about a single alternative icon, such as the icon's name.
struct AlternativeIconsElement {
	// MARK: - Properties
	/// The name of the alternative icon.
	let name: String
}
