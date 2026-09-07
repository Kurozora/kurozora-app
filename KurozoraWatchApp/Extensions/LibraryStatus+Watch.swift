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
	/// The status title shown on the Watch for the given library kind.
	///
	/// - Parameter kind: The library kind the status belongs to.
	///
	/// - Returns: The title, using the iOS app's per kind wording for the in progress status.
	func watchTitle(for kind: LibraryKind) -> String {
		switch self {
		case .inProgress:
			switch kind {
			case .shows:
				return L10n.watching
			case .literatures:
				return L10n.reading
			case .games:
				return L10n.playing
			}
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
