//
//  FloatingLyricsHostView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import AVFoundation
import UIKit

/// A view backed by an `AVSampleBufferDisplayLayer`, hosting the Picture in Picture content.
final class FloatingLyricsHostView: UIView {
	// MARK: - Properties
	override static var layerClass: AnyClass {
		return AVSampleBufferDisplayLayer.self
	}

	/// The sample buffer layer frames are enqueued into.
	var sampleBufferDisplayLayer: AVSampleBufferDisplayLayer? {
		return self.layer as? AVSampleBufferDisplayLayer
	}
}
