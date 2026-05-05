//
//  MediaURL+MediaID.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

#if DEBUG
import Foundation

extension URL {
	// MARK: - Properties
	/// Returns the Kurozora media ID encoded in the URL path, if present.
	///
	/// The path segment immediately before the filename is the media row's primary key.
	var kurozoraMediaID: Int? {
		let components = self.pathComponents.filter { $0 != "/" }

		guard components.count >= 2 else {
			return nil
		}

		return Int(components[components.count - 2])
	}
}
#endif
