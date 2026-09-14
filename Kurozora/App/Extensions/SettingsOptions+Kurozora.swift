//
//  SettingsOptions+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

// MARK: - AuthenticationInterval
extension AuthenticationInterval {
	/// The string value of an authentication interval type.
	var stringValue: String {
		switch self {
		case .immediately:
			return L10n.immediately
		case .thirtySeconds:
			return L10n.thirtySeconds
		case .oneMinute:
			return L10n.oneMinute
		case .twoMinutes:
			return L10n.twoMinutes
		case .threeMinutes:
			return L10n.threeMinutes
		case .fourMinutes:
			return L10n.fourMinutes
		case .fiveMinutes:
			return L10n.fiveMinutes
		}
	}

	/// The footer string value of an authentication interval type.
	var footerStringValue: String {
		switch self {
		case .immediately:
			return L10n.immediateAuthenticationRequired
		case .thirtySeconds:
			return L10n.authenticationInterval(L10n.intervalThirtySeconds)
		case .oneMinute:
			return L10n.authenticationInterval(L10n.intervalOneMinute)
		case .twoMinutes:
			return L10n.authenticationInterval(L10n.intervalTwoMinutes)
		case .threeMinutes:
			return L10n.authenticationInterval(L10n.intervalThreeMinutes)
		case .fourMinutes:
			return L10n.authenticationInterval(L10n.intervalFourMinutes)
		case .fiveMinutes:
			return L10n.authenticationInterval(L10n.intervalFiveMinutes)
		}
	}
}

// MARK: - LyricsFloatingWindowFontSize
extension LyricsFloatingWindowFontSize {
	/// The title of the option.
	var stringValue: String {
		switch self {
		case .standard:
			return L10n.fontSizeStandard
		case .big:
			return L10n.fontSizeBig
		}
	}
}

// MARK: - LyricsFloatingWindowRows
extension LyricsFloatingWindowRows {
	/// The title of the option.
	var stringValue: String {
		switch self {
		case .one:
			return L10n.oneLine
		case .two:
			return L10n.twoLines
		}
	}
}

// MARK: - LyricsLargerText
extension LyricsLargerText {
	/// The title of the option.
	var stringValue: String {
		switch self {
		case .lyrics:
			return L10n.lyrics
		case .pronunciation:
			return L10n.pronunciation
		}
	}

	/// The title of the lyrics menu action that reveals the smaller of the two texts.
	var showSecondaryTextTitle: String {
		switch self {
		case .lyrics:
			return L10n.showPronunciation
		case .pronunciation:
			return L10n.showOriginal
		}
	}

	/// The title of the lyrics menu action that hides the smaller of the two texts.
	var hideSecondaryTextTitle: String {
		switch self {
		case .lyrics:
			return L10n.hidePronunciation
		case .pronunciation:
			return L10n.hideOriginal
		}
	}
}

// MARK: - SplashScreenAnimation
extension SplashScreenAnimation {
	/// The title of the animation.
	var titleValue: String {
		switch self {
		case .none:
			return L10n.disabled
		case .default:
			return L10n.default
		case .furin:
			return L10n.furin
		case .iai:
			return L10n.iai
		case .shake:
			return L10n.shake
		case .shishiOdoshi:
			return L10n.shishiOdoshi
		case .sumie:
			return L10n.sumie
		case .gleam:
			return L10n.gleam
		case .glitch:
			return L10n.glitch
		case .impact:
			return L10n.impact
		case .scale:
			return L10n.scale
		case .anvil:
			return L10n.anvil
		case .spin:
			return L10n.spin
		case .heartbeat:
			return L10n.heartbeat
		case .bounce:
			return L10n.bounce
		}
	}
}

// MARK: - VideoAutoplayPolicy
extension VideoAutoplayPolicy {
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

// MARK: - VideoQuality
extension VideoQuality {
	/// The localized title of the quality.
	var titleValue: String {
		switch self {
		case .auto:
			return L10n.automatic
		default:
			return self.preferredLevel
		}
	}
}
