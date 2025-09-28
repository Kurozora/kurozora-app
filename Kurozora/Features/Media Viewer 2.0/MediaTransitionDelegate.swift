//
//  MediaTransitionDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/09/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit

protocol MediaTransitionDelegate: AnyObject {
	/// Returns the thumbnail view for the specific media index, if visible.
	func imageViewForMedia(at index: Int) -> UIImageView?

	/// Optional: Ensure the thumbnail for this index is visible in the feed.
	func scrollThumbnailIntoView(for index: Int)
}
