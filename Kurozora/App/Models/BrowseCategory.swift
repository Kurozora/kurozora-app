//
//  BrowseCategory.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/07/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

struct BrowseCategory: Hashable {
	// MARK: - Properties
	let title: String
	let image: UIImage?
	let searchType: KKSearchType?
	let segueIdentifier: (any SegueIdentifier)?

	// MARK: - Initializers
	init(
		title: String,
		image: UIImage?,
		searchType: KKSearchType? = nil,
		segueIdentifier: (any SegueIdentifier)? = nil
	) {
		self.title = title
		self.image = image
		self.searchType = searchType
		self.segueIdentifier = segueIdentifier
	}

	// MARK: - Functions
	static func == (lhs: BrowseCategory, rhs: BrowseCategory) -> Bool {
		lhs.title == rhs.title && lhs.searchType == rhs.searchType && lhs.segueIdentifier?.rawValue == rhs.segueIdentifier?.rawValue
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(self.title)
		hasher.combine(self.searchType)
		hasher.combine(self.segueIdentifier?.rawValue)
	}
}
