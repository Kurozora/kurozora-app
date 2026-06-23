//
//  LyricsLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

struct LyricsLayout {
	// MARK: - Properties
	static var originalFont: UIFont {
		return UserSettings.lyricsLargerText == .pronunciation
			? .systemFont(ofSize: 16, weight: .semibold)
			: .systemFont(ofSize: 26, weight: .bold)
	}

	static var romajiFont: UIFont {
		return UserSettings.lyricsLargerText == .pronunciation
			? .systemFont(ofSize: 26, weight: .bold)
			: .systemFont(ofSize: 16, weight: .semibold)
	}

	static let translationFont = UIFont.systemFont(ofSize: 15, weight: .regular)

	static let horizontalInset: CGFloat = 20
	static let topInset: CGFloat = 12
	static let bottomInset: CGFloat = 12
	static let translationSpacing: CGFloat = 6

	static let originalToRomajiSpacing: CGFloat = 2
	static let rowSpacing: CGFloat = 6
	static let pairSpacing: CGFloat = 4

	/// The distance a word lifts as it fills, in points.
	static let activeWordLift: CGFloat = 3

	/// The opacity of un-filled text.
	static let unsungTextAlpha: CGFloat = 0.35

	/// The softness of the fill's trailing edge, as a fraction of the line height.
	static let fillFeatherRatio: CGFloat = 0.6

	/// The blur added per line of distance from the active line, in points.
	static let blurRadiusPerLine: CGFloat = 1.5

	/// The maximum blur radius, in points.
	static let maxBlurRadius: CGFloat = 7

	/// The duration of the auto-recenter scroll, in seconds.
	static let scrollAnimationDuration: TimeInterval = 0.5

	/// The per-row delay of the auto-recenter domino, in seconds.
	static let scrollStaggerDelay: TimeInterval = 0.03

	/// The spring damping of the auto-recenter scroll.
	static let scrollSpringDamping: CGFloat = 0.9

	// MARK: - Initializers
	private init() {}

	// MARK: - Functions
	/// Returns the blur radius for a line a given number of lines from the active line.
	///
	/// - Parameter distance: The number of lines from the active line.
	///
	/// - Returns: The blur radius in points.
	static func blurRadius(forDistance distance: Int) -> CGFloat {
		guard distance > 0 else { return 0 }
		return min(self.maxBlurRadius, CGFloat(distance) * self.blurRadiusPerLine)
	}
}
