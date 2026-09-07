//
//  Episode+Watch.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 07/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit

extension Episode {
	/// The season and episode label, matching the format used by `EpisodeLockupCollectionViewCell`.
	var seasonEpisodeLabel: String {
		var label = "S\(self.attributes.seasonNumber) · E\(self.attributes.number)"

		if self.attributes.numberTotal != self.attributes.number {
			label += " (E\(self.attributes.numberTotal))"
		}

		return label
	}
}
