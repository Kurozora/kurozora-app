//
//  KotodamaPalette.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

enum KotodamaPalette {
	// MARK: - Properties
	/// The color of a letter that sits in the right place.
	static let hit = UIColor(red: 255 / 255, green: 147 / 255, blue: 0 / 255, alpha: 1)

	/// The color of a letter that appears elsewhere in the answer.
	static let present = UIColor(red: 165 / 255, green: 80 / 255, blue: 204 / 255, alpha: 1)

	/// The color of a letter that does not appear in the answer.
	static let miss = UIColor(red: 0 / 255, green: 0 / 255, blue: 0 / 255, alpha: 1)

	/// The color of the letter drawn on a revealed tile.
	static let revealedLetter = UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1)

	// MARK: - Functions
	/// Returns the color of a tile for the given feedback.
	///
	/// - Parameter feedback: The feedback the tile represents.
	///
	/// - Returns: The color of the tile.
	static func color(for feedback: KotodamaTileFeedback) -> UIColor {
		switch feedback {
		case .hit:
			return self.hit
		case .present:
			return self.present
		case .miss:
			return self.miss
		}
	}
}
