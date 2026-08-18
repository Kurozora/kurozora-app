//
//  LocalLibraryEntry+Rendering.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension LocalLibraryEntry {
	// MARK: - Properties
	/// The short information line, composed from the cached media-type label and review score.
	var informationStringShort: String {
		var information = self.mediaTypeName ?? ""
		if let score = self.review?.score?.doubleValue, score > 0 {
			if !information.isEmpty {
				information += " · "
			}
			information += "☆ \(score)"
		}
		return information
	}

	// MARK: - Functions
	/// Sets the poster image on the given image view, applying the cached background color
	/// and falling back to a kind-specific placeholder when the URL is missing.
	///
	/// - Parameter imageView: The image view on which to set the poster.
	func posterImage(imageView: UIImageView?) {
		guard let imageView = imageView else { return }
		imageView.image = nil

		if let backgroundColor = self.posterBackgroundColor {
			imageView.backgroundColor = UIColor(hexString: backgroundColor)
		} else {
			imageView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}

		imageView.setLibraryImage(with: self.posterURL ?? "", placeholder: self.posterPlaceholder)
	}

	/// Sets the banner image on the given image view, falling back to the poster when no banner exists.
	///
	/// - Parameter imageView: The image view on which to set the banner.
	func bannerImage(imageView: UIImageView?) {
		guard let imageView = imageView else { return }
		imageView.image = nil

		if let backgroundColor = self.bannerBackgroundColor ?? self.posterBackgroundColor {
			imageView.backgroundColor = UIColor(hexString: backgroundColor)
		} else {
			imageView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}

		imageView.setLibraryImage(with: self.bannerURL ?? self.posterURL ?? "", placeholder: self.bannerPlaceholder)
	}

	// MARK: - Helpers
	private var posterPlaceholder: UIImage {
		return .Placeholders.showPoster
	}

	private var bannerPlaceholder: UIImage {
		return .Placeholders.showBanner
	}
}
