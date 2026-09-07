//
//  LibraryStatus+Watch.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 07/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit

extension LibraryStatus {
	/// The status title shown on the Watch.
	var watchTitle: String {
		// The Watch library carries shows only, so this matches the iOS app's L10n.watching
		// wording instead of the kind agnostic stringValue.
		switch self {
		case .inProgress:
			return "Watching"
		case .none:
			return "None"
		case .planning:
			return "Planning"
		case .completed:
			return "Completed"
		case .onHold:
			return "On-Hold"
		case .dropped:
			return "Dropped"
		case .interested:
			return "Interested"
		case .ignored:
			return "Ignored"
		}
	}
}
