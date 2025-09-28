//
//  MediaRendererFactory.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/09/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit

enum MediaRendererFactory {
	static func makeRenderer(for item: MediaItemV2) -> UIViewController & MediaRenderable {
		switch item.type {
		case .image:
			return ImageRendererViewController(mediaItem: item)
		case .video:
			return VideoRendererViewController(mediaItem: item)
		default:
			fatalError("Unsupported media type")
		}
	}
}
