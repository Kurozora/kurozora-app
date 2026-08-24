//
//  MediaViewerCloseMethod.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

/// The gesture or control that closed the media viewer.
enum MediaViewerCloseMethod {
	/// The close button was tapped.
	case button

	/// The media was flicked away.
	case flick

	/// The media was dragged past the dismiss threshold and released.
	case drag

	// MARK: - Properties
	/// The duration of the dismissal animation.
	var duration: TimeInterval {
		switch self {
		case .button:
			return 0.4
		case .flick:
			return 0.25
		case .drag:
			return 0.4
		}
	}
}
