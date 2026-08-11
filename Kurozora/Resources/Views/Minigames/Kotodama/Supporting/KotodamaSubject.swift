//
//  KotodamaSubject.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit

/// The full catalog entry behind a finished game's answer.
enum KotodamaSubject {
	// MARK: - Cases
	/// The subject is a show.
	case show(Show)

	/// The subject is a literature.
	case literature(Literature)

	/// The subject is a game.
	case game(Game)

	/// The subject is a character.
	case character(Character)

	/// The subject is a person.
	case person(Person)

	/// The subject is a studio.
	case studio(Studio)

	/// The subject is a song.
	case song(Song)

	// MARK: - Initializers
	/// Creates a subject by fetching the catalog entry of the given kind.
	///
	/// - Parameters:
	///    - kind: The kind of the subject to fetch.
	///    - subjectID: The id of the subject to fetch.
	init?(kind: KotodamaSubjectKind, subjectID: KurozoraItemID) async {
		do {
			switch kind {
			case .shows:
				guard let show = try await KService.detail(ShowIdentity(id: subjectID)).response().data.first else { return nil }
				self = .show(show)
			case .literatures:
				guard let literature = try await KService.detail(LiteratureIdentity(id: subjectID)).response().data.first else { return nil }
				self = .literature(literature)
			case .games:
				guard let game = try await KService.detail(GameIdentity(id: subjectID)).response().data.first else { return nil }
				self = .game(game)
			case .characters:
				guard let character = try await KService.detail(CharacterIdentity(id: subjectID)).response().data.first else { return nil }
				self = .character(character)
			case .people:
				guard let person = try await KService.detail(PersonIdentity(id: subjectID)).response().data.first else { return nil }
				self = .person(person)
			case .studios:
				guard let studio = try await KService.detail(StudioIdentity(id: subjectID)).response().data.first else { return nil }
				self = .studio(studio)
			case .songs:
				guard let song = try await KService.detail(SongIdentity(id: subjectID)).response().data.first else { return nil }
				self = .song(song)
			}
		} catch {
			return nil
		}
	}
}
