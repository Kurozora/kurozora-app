//
//  LibraryStatus+Watch.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 07/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit

extension LibraryStatus {
	/// The status title shown on the Watch.
	var watchTitle: String {
		// The Watch library carries shows only, so this matches the iOS app's L10n.watching
		// wording instead of the kind agnostic stringValue.
		switch self {
		case .inProgress:
			return L10n.watching
		case .none:
			return L10n.libraryNone
		case .planning:
			return L10n.planning
		case .completed:
			return L10n.completed
		case .onHold:
			return L10n.onHold
		case .dropped:
			return L10n.dropped
		case .interested:
			return L10n.interested
		case .ignored:
			return L10n.ignored
		}
	}
}
