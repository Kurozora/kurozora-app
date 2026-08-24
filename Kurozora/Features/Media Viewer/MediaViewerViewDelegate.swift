//
//  MediaViewerViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 21/02/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

protocol MediaViewerViewDelegate: AnyObject {
	func mediaViewerViewDelegate(_ view: UIView, didTapImage imageView: UIImageView, at index: Int)
}

/// A collection view cell whose image views participate in the media viewer's transition.
protocol MediaViewerHeaderCell: UICollectionViewCell {
	/// The delegate that receives tap events from the cell's media image views.
	var mediaViewerDelegate: MediaViewerViewDelegate? { get set }

	/// Returns the image view for the media item at the given index.
	///
	/// - Parameter index: The zero-based index of the media item.
	/// - Returns: The image view at `index`.
	func imageView(at index: Int) -> UIImageView?
}
