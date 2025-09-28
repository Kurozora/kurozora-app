//
//  MediaRenderable.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/09/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit

protocol MediaRenderable where Self: UIViewController {
	var mediaItem: MediaItemV2 { get }
	var mediaView: UIView { get } // used for transitions (imageView/videoView)
}
