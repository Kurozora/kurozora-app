//
//  VideoAutoplayPolicy.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

/// The conditions under which trailers may play automatically.
enum VideoAutoplayPolicy: Int, CaseIterable {
	// MARK: - Cases
	/// Trailers never play automatically.
	case never = 0

	/// Trailers play automatically only on Wi-Fi.
	case wifiOnly = 1

	/// Trailers play automatically on Wi-Fi and cellular.
	case wifiAndCellular = 2

	// MARK: - Properties
	/// The default autoplay policy.
	static let `default`: VideoAutoplayPolicy = .wifiOnly

	/// The localized title of the policy.
	var titleValue: String {
		switch self {
		case .never:
			return L10n.autoplayNever
		case .wifiOnly:
			return L10n.autoplayWiFiOnly
		case .wifiAndCellular:
			return L10n.autoplayAlways
		}
	}
}
