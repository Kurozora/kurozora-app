//
//  MediaTransitionDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/09/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit

protocol MediaTransitionDelegate: AnyObject {
	/// Returns the thumbnail for the media at the given index.
	///
	/// - Parameter index: The zero-based index of the media item.
	/// - Returns: The thumbnail the viewer grows from and shrinks back into.
	func imageViewForMedia(at index: Int) -> UIImageView?

	/// Brings the thumbnail for the given index on screen.
	///
	/// - Parameters:
	///    - index: The zero-based index of the media item.
	///    - animated: Whether to animate the scroll. Pass `false` to scroll and lay out immediately.
	func scrollThumbnailIntoView(for index: Int, animated: Bool)
}
