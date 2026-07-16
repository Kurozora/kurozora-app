//
//  LocalLibraryEntry+Intents.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreSpotlight
import Intents
import KurozoraKit
import MobileCoreServices

extension LocalLibraryEntry {
	// MARK: - Properties
	/// The canonical webpage URL for the entry's catalog page; prefers slug, falls back
	/// to the trackable identifier when no slug has been synced yet.
	var webpageURLString: String {
		let identifier = self.slug ?? self.trackableID
		return "https://kurozora.app/\(self.kind.urlPathName)/\(identifier)"
	}

	/// Creates an NSUserActivity from the selected library entry.
	var openDetailUserActivity: NSUserActivity {
		let activityType: ActivityType
		switch self.kind {
		case .shows:
			activityType = .openShow
		case .literatures:
			activityType = .openLiterature
		case .games:
			activityType = .openGame
		}

		let entryTitle = self.title ?? ""
		let userActivity = NSUserActivity(activityType: activityType)
		userActivity.contentAttributeSet = self.contentAttributeSet
		userActivity.title = entryTitle
		try? userActivity.setTypedPayload(["id": KurozoraItemID(self.trackableID)])
		userActivity.requiredUserInfoKeys = ["id"]
		userActivity.suggestedInvocationPhrase = L10n.openTitle(entryTitle)
		userActivity.isEligibleForPrediction = true
		userActivity.isEligibleForSearch = true
		userActivity.isEligibleForHandoff = true
		userActivity.isEligibleForPublicIndexing = true
		userActivity.webpageURL = URL(string: self.webpageURLString)
		userActivity.persistentIdentifier = "\(self.persistentIdentifierPrefix):\(self.trackableID)"
		return userActivity
	}

	/// The metadata used to make the selected library entry searchable.
	var contentAttributeSet: CSSearchableItemAttributeSet {
		let contentType: UTType
		switch self.kind {
		case .shows:
			contentType = (self.mediaTypeName?.lowercased() == "movie") ? .movie : .audiovisualContent
		case .literatures, .games:
			contentType = .content
		}

		let attributeSet = CSSearchableItemAttributeSet(contentType: contentType)
		attributeSet.title = self.title
		attributeSet.contentDescription = self.tagline
		if let genres = self.genresLocalized, !genres.isEmpty {
			attributeSet.keywords = [self.title, genres].compactMap { $0 }
			attributeSet.genre = genres
		} else if let title = self.title {
			attributeSet.keywords = [title]
		}
		if let urlString = self.posterURL {
			attributeSet.thumbnailURL = URL(string: urlString)
		}
		if let score = self.publicRating {
			attributeSet.rating = score
		}
		attributeSet.startDate = self.startedAt
		attributeSet.endDate = self.endedAt
		attributeSet.url = URL(string: self.webpageURLString)
		attributeSet.domainIdentifier = self.persistentIdentifierPrefix
		return attributeSet
	}

	// MARK: - Helpers
	/// The persistent-identifier prefix used by activities and spotlight items.
	private var persistentIdentifierPrefix: String {
		switch self.kind {
		case .shows:
			return "shows"
		case .literatures:
			return "literatures"
		case .games:
			return "games"
		}
	}
}
