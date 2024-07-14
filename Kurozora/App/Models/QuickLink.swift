//
//  QuickLink.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/04/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

struct QuickLink: Hashable {
	// MARK: - Properties
	let title: String
	let image: UIImage?
	let url: String

	// MARK: - Initializers
	init(title: String, image: UIImage? = nil, url: String) {
		self.title = title
		self.image = image
		self.url = url
	}

	// MARK: - Functions
	static func == (lhs: QuickLink, rhs: QuickLink) -> Bool {
		lhs.title == rhs.title && lhs.url == rhs.url
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(self.title)
		hasher.combine(self.url)
	}
}
