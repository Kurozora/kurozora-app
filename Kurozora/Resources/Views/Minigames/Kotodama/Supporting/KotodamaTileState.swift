//
//  KotodamaTileState.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit

enum KotodamaTileState: Hashable {
	// MARK: - Cases
	/// The tile holds no letter.
	case empty

	/// The tile holds a letter that has not been submitted.
	case pending(letter: Swift.Character)

	/// The tile holds a submitted letter and its feedback.
	case revealed(letter: Swift.Character, feedback: KotodamaTileFeedback)

	// MARK: - Properties
	/// The letter drawn on the tile.
	var letter: Swift.Character? {
		switch self {
		case .empty:
			return nil
		case .pending(let letter):
			return letter
		case .revealed(let letter, _):
			return letter
		}
	}

	/// The feedback the tile represents.
	var feedback: KotodamaTileFeedback? {
		switch self {
		case .empty, .pending:
			return nil
		case .revealed(_, let feedback):
			return feedback
		}
	}
}
