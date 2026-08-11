//
//  KotodamaSubjectKind+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension KotodamaSubjectKind {
	// MARK: - Properties
	/// The name of the kind.
	var stringValue: String {
		switch self {
		case .shows:
			return L10n.show
		case .literatures:
			return L10n.literature
		case .games:
			return L10n.game
		case .characters:
			return L10n.character
		case .people:
			return L10n.person
		case .studios:
			return L10n.studio
		case .songs:
			return L10n.song
		}
	}

	/// The image shown while the subject's own image loads.
	var placeholderImage: UIImage {
		switch self {
		case .shows, .literatures, .games:
			return .Placeholders.showPoster
		case .characters, .people:
			return .Placeholders.personPoster
		case .studios:
			return .Placeholders.studioProfile
		case .songs:
			return .Placeholders.musicAlbum
		}
	}

	// MARK: - Functions
	/// Returns the details view controller for a subject of this kind.
	///
	/// - Parameter subjectID: The id of the subject to show.
	///
	/// - Returns: The details view controller for the subject.
	func detailsViewController(for subjectID: KurozoraItemID) -> UIViewController {
		switch self {
		case .shows:
			return ShowDetailsCollectionViewController()(with: subjectID)
		case .literatures:
			return LiteratureDetailsCollectionViewController()(with: subjectID)
		case .games:
			return GameDetailsCollectionViewController()(with: subjectID)
		case .characters:
			return CharacterDetailsCollectionViewController()(with: subjectID)
		case .people:
			return PersonDetailsCollectionViewController()(with: subjectID)
		case .studios:
			return StudioDetailsCollectionViewController()(with: subjectID)
		case .songs:
			return SongDetailsCollectionViewController()(with: subjectID)
		}
	}
}
