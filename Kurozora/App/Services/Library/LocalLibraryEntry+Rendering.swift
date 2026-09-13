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
		var information = self.trackable?.mediaTypeName ?? ""
		if let score = self.review?.score?.doubleValue, score > 0 {
			if !information.isEmpty {
				information += " · "
			}
			information += "☆ \(score)"
		}
		return information
	}

	/// The entry's duration in hours and minutes.
	var durationString: String {
		guard let durationCount = self.trackable?.durationCount?.intValue, durationCount > 0 else { return "-" }

		return Self.durationFormatter.string(from: TimeInterval(durationCount)) ?? "-"
	}

	/// The weekday and time the entry airs or publishes.
	var broadcastString: String {
		guard let airingDate = self.trackable?.airingDate else { return "-" }

		return airingDate.formatted(.dateTime.weekday(.wide).hour().minute())
	}

	/// The time until the entry next airs or publishes.
	var relativeBroadcastString: String? {
		guard let airingDate = self.trackable?.airingDate else { return nil }

		return airingDate.formatted(.relative(presentation: .named, unitsStyle: .abbreviated))
	}

	/// The formatter that renders a duration in hours and minutes.
	private static let durationFormatter: DateComponentsFormatter = {
		let formatter = DateComponentsFormatter()
		formatter.allowedUnits = [.hour, .minute]
		formatter.unitsStyle = .abbreviated
		return formatter
	}()

	// MARK: - Functions
	/// Sets the poster image on the given image view, applying the cached background color
	/// and falling back to a kind-specific placeholder when the URL is missing.
	///
	/// - Parameter imageView: The image view on which to set the poster.
	func posterImage(imageView: UIImageView?) {
		guard let imageView = imageView else { return }
		imageView.image = nil

		if let backgroundColor = self.trackable?.posterBackgroundColor {
			imageView.backgroundColor = UIColor(hexString: backgroundColor)
		} else {
			imageView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}

		imageView.setLibraryImage(with: self.trackable?.posterURL ?? "", placeholder: self.posterPlaceholder)
	}

	/// Sets the banner image on the given image view, falling back to the poster when no banner exists.
	///
	/// - Parameter imageView: The image view on which to set the banner.
	func bannerImage(imageView: UIImageView?) {
		guard let imageView = imageView else { return }
		imageView.image = nil

		if let backgroundColor = self.trackable?.bannerBackgroundColor ?? self.trackable?.posterBackgroundColor {
			imageView.backgroundColor = UIColor(hexString: backgroundColor)
		} else {
			imageView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}

		imageView.setLibraryImage(with: self.trackable?.bannerURL ?? self.trackable?.posterURL ?? "", placeholder: self.bannerPlaceholder)
	}

	// MARK: - Helpers
	private var posterPlaceholder: UIImage {
		return .Placeholders.showPoster
	}

	private var bannerPlaceholder: UIImage {
		return .Placeholders.showBanner
	}
}
