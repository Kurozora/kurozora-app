//
//  ParentalGuide.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

struct ParentalGuide {}

// MARK: - Media Type
extension ParentalGuide {
	/// The set of supported media surfaces that expose a parental guide.
	enum MediaType: Hashable, Sendable {
		// MARK: - Cases
		/// A show.
		case show(_ showIdentity: ShowIdentity, title: String?, ratingName: String?, ratingDescription: String?, slug: String? = nil)

		/// A literature.
		case literature(_ literatureIdentity: LiteratureIdentity, title: String?, ratingName: String?, ratingDescription: String?, slug: String? = nil)

		/// A game.
		case game(_ gameIdentity: GameIdentity, title: String?, ratingName: String?, ratingDescription: String?, slug: String? = nil)

		// MARK: - Properties
		/// The display title for the media item, if known.
		var title: String? {
			switch self {
			case .show(_, let title, _, _, _), .literature(_, let title, _, _, _), .game(_, let title, _, _, _):
				return title
			}
		}

		/// The display string for the overall TV rating, e.g. "PG-12 (Parental Guidance Suggested)".
		var ratingDisplay: String? {
			let name: String?
			let description: String?

			switch self {
			case .show(_, _, let n, let d, _), .literature(_, _, let n, let d, _), .game(_, _, let n, let d, _):
				name = n
				description = d
			}

			guard let name = name else { return nil }

			if let description = description, !description.isEmpty {
				return "\(name) (\(description))"
			}

			return name
		}

		/// The web URL for the media's parental guide page anchored at the given category, when the slug is known.
		///
		/// - Parameter category: The category to anchor the URL to. The category's kebab-case key is appended as a path segment.
		///
		/// - Returns: A URL like `https://kurozora.app/anime/{slug}/parentalguide/{category}`, or `nil` if no slug is known.
		func parentalGuideURL(for category: ParentalGuideCategory) -> URL? {
			let prefix: String
			let slug: String?

			switch self {
			case .show(_, _, _, _, let s):
				prefix = "anime"
				slug = s
			case .literature(_, _, _, _, let s):
				prefix = "manga"
				slug = s
			case .game(_, _, _, _, let s):
				prefix = "games"
				slug = s
			}

			guard let slug = slug, !slug.isEmpty else { return nil }

			let categorySlug = category.urlSlug
			return URL(string: "https://kurozora.app/\(prefix)/\(slug)/parentalguide/\(categorySlug)")
		}
	}
}

// MARK: - ParentalGuideStats
extension ParentalGuideStats {
	/// Returns the aggregate for the given category, or `nil` if absent.
	///
	/// - Parameter category: The category whose aggregate to return.
	///
	/// - Returns: The aggregate stats for the category, or `nil` if missing.
	func stats(for category: ParentalGuideCategory) -> ParentalGuideStats.CategoryStats? {
		let index = category.rawValue - 1
		guard self.categories.indices.contains(index) else { return nil }

		return self.categories[index]
	}
}

// MARK: - ParentalGuideCategory
extension ParentalGuideCategory {
	/// The SF Symbol that represents the category.
	var systemImageName: String {
		switch self {
		case .sexAndNudity:
			return "heart.text.square"
		case .violenceAndGore:
			return "burst"
		case .profanity:
			return "exclamationmark.bubble"
		case .alcoholDrugsAndSmoking:
			return "wineglass"
		case .frighteningAndIntenseScenes:
			return "theatermask.and.paintbrush"
		}
	}

	/// The display name of the category.
	var displayName: String {
		switch self {
		case .sexAndNudity:
			return L10n.pgSexAndNudity
		case .violenceAndGore:
			return L10n.pgViolenceAndGore
		case .profanity:
			return L10n.pgProfanity
		case .alcoholDrugsAndSmoking:
			return L10n.pgAlcoholDrugsAndSmoking
		case .frighteningAndIntenseScenes:
			return L10n.pgFrighteningAndIntenseScenes
		}
	}

	/// The kebab-case URL slug for the category, matching the web route binding.
	var urlSlug: String {
		switch self {
		case .sexAndNudity:
			return "sex-and-nudity"
		case .violenceAndGore:
			return "violence-and-gore"
		case .profanity:
			return "profanity"
		case .alcoholDrugsAndSmoking:
			return "alcohol-drugs-and-smoking"
		case .frighteningAndIntenseScenes:
			return "frightening-and-intense-scenes"
		}
	}
}
