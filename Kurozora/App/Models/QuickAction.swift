//
//  QuickAction.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/04/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

struct QuickAction: nonisolated Hashable, Sendable {
	// MARK: - Properties
	let title: String
	let image: UIImage?
	let segueID: any SegueIdentifier

	// MARK: - Initializers
	init(title: String, image: UIImage? = nil, segueID: any SegueIdentifier) {
		self.title = title
		self.image = image
		self.segueID = segueID
	}

	// MARK: - Functions
	nonisolated static func == (lhs: QuickAction, rhs: QuickAction) -> Bool {
		lhs.title == rhs.title && lhs.segueID.rawValue == rhs.segueID.rawValue
	}

	nonisolated func hash(into hasher: inout Hasher) {
		hasher.combine(self.title)
		hasher.combine(self.segueID.rawValue)
	}
}
