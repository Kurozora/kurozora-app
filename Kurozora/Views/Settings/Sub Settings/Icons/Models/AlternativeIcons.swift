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
	/// The collection of default icons.
	let defaultIcons: [AlternativeIconsElement]

	/// The collection of nature icons.
	let natureIcons: [AlternativeIconsElement]

	/// The collection of premium icons.
	let premiumIcons: [AlternativeIconsElement]

	/// The collection of limited time icons.
	let limitedIcons: [AlternativeIconsElement]

	// MARK: - Initializers
	/// Initializes a new instance of `AlternativeIcons` using the given dictionary.
	///
	/// - Parameter dict: The dictionary that contains the array of alternative icons.
	init(dict: [String: [String]]) {
		let defaultIconsArray = dict["Default"]!
		let natureIconsArray = dict["Nature"]!
		let premiumIconsArray = dict["Premium"]!
		let limitedIconsArray = dict["Limited"]!

		var defaultIcons = [AlternativeIconsElement]()
		var natureIcons = [AlternativeIconsElement]()
		var premiumIcons = [AlternativeIconsElement]()
		var limitedIcons = [AlternativeIconsElement]()

		for defaultIconItem in defaultIconsArray {
			let alternativeIconElement = AlternativeIconsElement(name: defaultIconItem)
			defaultIcons.append(alternativeIconElement)
		}

		for natureIconItem in natureIconsArray {
			let alternativeIconElement = AlternativeIconsElement(name: natureIconItem)
			natureIcons.append(alternativeIconElement)
		}

		for premiumIconItem in premiumIconsArray {
			let alternativeIconElement = AlternativeIconsElement(name: premiumIconItem)
			premiumIcons.append(alternativeIconElement)
		}

		for limitedIconItem in limitedIconsArray {
			let alternativeIconElement = AlternativeIconsElement(name: limitedIconItem)
			limitedIcons.append(alternativeIconElement)
		}

		self.defaultIcons = defaultIcons
		self.natureIcons = natureIcons
		self.premiumIcons = premiumIcons
		self.limitedIcons = limitedIcons
	}
}

/// A struct that stores information about a single alternative icon, such as the icon's name.
struct AlternativeIconsElement {
	// MARK: - Properties
	/// The name of the alternative icon.
	let name: String

	// MARK: - Initializers
	/// Initializes a new instance of `AlternativeIconsElement` using the given name.
	///
	/// - Parameter name: The name of the alternative icon.
	init(name: String) {
		self.name = name
	}
}
