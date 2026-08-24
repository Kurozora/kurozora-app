//
//  MediaPlayerView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import AVFoundation
import UIKit

/// A view that renders an `AVPlayer`'s output.
final class MediaPlayerView: UIView {
	// MARK: - Properties
	override static var layerClass: AnyClass {
		return AVPlayerLayer.self
	}

	/// The layer that renders the player's output.
	var playerLayer: AVPlayerLayer? {
		return self.layer as? AVPlayerLayer
	}

	/// The player whose output this view renders.
	var player: AVPlayer? {
		get {
			return self.playerLayer?.player
		}
		set {
			self.playerLayer?.player = newValue
		}
	}
}
