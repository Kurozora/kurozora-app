//
//  EmojiScore+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit

extension EmojiScore {
	// MARK: - Properties
	/// The localized description of the emoji score.
	var localizedDescription: String {
		switch self {
		case .disliked:
			return L10n.emojiScoreDisliked
		case .neutral:
			return L10n.emojiScoreNeutral
		case .liked:
			return L10n.emojiScoreLiked
		}
	}

	/// The formatted star rating the emoji score is stored as.
	var formattedScore: String {
		return self.score.formatted(.number.precision(.fractionLength(0...1)))
	}
}
