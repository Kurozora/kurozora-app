//
//  VideoQuality.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

/// The quality levels a trailer can be held at.
enum VideoQuality: Int, CaseIterable {
	// MARK: - Cases
	/// The trailer adapts its quality to the connection.
	case auto = 0

	/// The trailer holds at 2160p.
	case p2160 = 2160

	/// The trailer holds at 1440p.
	case p1440 = 1440

	/// The trailer holds at 1080p.
	case p1080 = 1080

	/// The trailer holds at 720p.
	case p720 = 720

	/// The trailer holds at 480p.
	case p480 = 480

	/// The trailer holds at 360p.
	case p360 = 360

	/// The trailer holds at 240p.
	case p240 = 240

	/// The trailer holds at 144p.
	case p144 = 144

	// MARK: - Properties
	/// The default quality on Wi-Fi.
	static let defaultWiFi: VideoQuality = .auto

	/// The default quality on cellular.
	static let defaultCellular: VideoQuality = .auto

	/// The localized title of the quality.
	var titleValue: String {
		switch self {
		case .auto:
			return L10n.automatic
		default:
			return self.preferredLevel
		}
	}

	/// The level requested from the player.
	var preferredLevel: String {
		switch self {
		case .auto:
			return "auto"
		default:
			return "\(self.rawValue)p"
		}
	}
}
