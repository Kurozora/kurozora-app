//
//  MediaRenderable.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/09/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit

protocol MediaRenderable where Self: UIViewController {
	/// The item this renderer displays.
	var mediaItem: MediaItem { get }

	/// The scroll view that hosts the zoomable media.
	var scrollView: UIScrollView { get }

	/// The view whose bounds match the visible media.
	var mediaView: UIView { get }

	/// A still representation of the media.
	var mediaImage: UIImage? { get }

	/// A Boolean value that indicates whether text inside the media is selected.
	var hasActiveTextSelection: Bool { get }

	/// Returns a Boolean value that indicates whether the system recognized selectable content at the given point.
	///
	/// - Parameter point: A point in ``mediaView``'s coordinate space.
	/// - Returns: `true` if selectable content exists at `point`.
	func hasInteractiveItem(at point: CGPoint) -> Bool
}
