//
//  MusicAccessoryLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

@available(iOS 26.0, *)
struct MusicAccessoryLayout: Equatable {
	// MARK: - Properties
	/// Whether the context-menu (`•••`) button is visible.
	let showsContextMenuButton: Bool

	/// Whether the lyrics button is visible.
	let showsLyricsButton: Bool

	/// Whether the floating lyrics button is visible.
	let showsFloatingLyricsButton: Bool

	/// Whether the progress bar is visible.
	let showsProgressBar: Bool

	/// Whether the AirPlay route button is visible.
	let showsAirPlayButton: Bool

	/// Whether the volume control is visible.
	let showsVolumeControl: Bool

	/// Whether the play/pause button sits at the leading edge instead of the trailing edge.
	///
	/// When `true`, the full transport cluster (shuffle, skip, repeat) is shown alongside it.
	let playPauseIsLeading: Bool

	/// Whether the skip-forward button is visible.
	let showsSkipForward: Bool

	/// The width at or above which the accessory shows its richer layout.
	static let wideWidthThreshold: CGFloat = 500

	// MARK: - Functions
	/// Returns the layout for the given environment and available width.
	///
	/// - Parameters:
	///    - environment: The tab-accessory environment reported by the trait collection.
	///    - width: The accessory's available width.
	///
	/// - Returns: The resolved layout.
	static func layout(for environment: UITabAccessory.Environment, width: CGFloat) -> MusicAccessoryLayout {
		let isWide = width >= self.wideWidthThreshold

		switch environment {
		case .inline:
			return MusicAccessoryLayout(showsContextMenuButton: isWide, showsLyricsButton: false, showsFloatingLyricsButton: false, showsProgressBar: false, showsAirPlayButton: false, showsVolumeControl: false, playPauseIsLeading: false, showsSkipForward: false)
		default:
			return MusicAccessoryLayout(showsContextMenuButton: isWide, showsLyricsButton: isWide, showsFloatingLyricsButton: isWide, showsProgressBar: isWide, showsAirPlayButton: isWide, showsVolumeControl: isWide, playPauseIsLeading: isWide, showsSkipForward: true)
		}
	}
}
