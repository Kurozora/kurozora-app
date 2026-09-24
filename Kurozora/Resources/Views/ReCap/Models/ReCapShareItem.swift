//
//  ReCapShareItem.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import LinkPresentation
import UIKit

/// The share sheet item of a rendered Re:CAP image.
final class ReCapShareItem: NSObject, UIActivityItemSource {
	// MARK: - Properties
	/// The rendered image.
	let image: UIImage

	/// The title the share sheet shows.
	let title: String

	// MARK: - Initializers
	/// Creates a share item of the given image.
	///
	/// - Parameters:
	///    - image: The rendered image.
	///    - title: The title the share sheet shows.
	init(image: UIImage, title: String) {
		self.image = image
		self.title = title
	}

	// MARK: - UIActivityItemSource
	func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
		return self.image
	}

	func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
		return self.image
	}

	func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
		let metadata = LPLinkMetadata()
		metadata.title = self.title
		metadata.imageProvider = NSItemProvider(object: self.image)
		metadata.iconProvider = NSItemProvider(object: self.image)
		return metadata
	}
}
