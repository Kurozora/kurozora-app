//
//  KTrailerPlayerView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/02/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import AVFoundation
import UIKit

/// A view that displays the visual contents of a player object.
class KTrailerPlayerView: UIView {
	// Make AVPlayerLayer the view's backing layer.
	override static var layerClass: AnyClass { AVPlayerLayer.self }

	// The associated player object.
	var player: AVPlayer? {
		get {
			self.playerLayer.player
		}
		set {
			self.playerLayer.player = newValue
		}
	}

	var playerLayer: AVPlayerLayer {
		guard let layer = self.layer as? AVPlayerLayer else {
			fatalError("Layer is not of expected type AVPlayerLayer.")
		}
		return layer
	}
}
