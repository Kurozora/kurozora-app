//
//  HomeCollectionViewController+Enums.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension HomeCollectionViewController {
	/// List of available Section Layout Kind types.
	enum SectionLayoutKind: nonisolated Hashable {
		// MARK: - Cases
		/// Indicates a banner section layout type.
		case banner(_: ExploreCategory)

		/// Indicates a small section layout type.
		case small(_: ExploreCategory)

		/// Indicates a medium section layout type.
		case medium(_: ExploreCategory)

		/// Indicates a large section layout type.
		case large(_: ExploreCategory)

		/// Indicates a video section layout type.
		case video(_: ExploreCategory)

		/// Indicates a upcoming section layout type.
		case upcoming(_: ExploreCategory)

		/// Indicates a genre section layout type.
		case profile(_: ExploreCategory)

		/// Indicates a episode section layout type.
		case episode(_: ExploreCategory)

		/// Indicates a music section layout type.
		case music(_: ExploreCategory)

		/// Indicates a quick links section layout type.
		case quickLinks(id: UUID = UUID())

		/// Indicates a quick actions section layout type.
		case quickActions(id: UUID = UUID())

		/// Indicates a legal section layout type.
		case legal(id: UUID = UUID())
	}

	/// List of available Item Kind types.
	enum ItemKind: nonisolated Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `ShowIdentity` object.
		case showIdentity(_: ShowIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `LiteratureIdentity` object.
		case literatureIdentity(_: LiteratureIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `GameIdentity` object.
		case gameIdentity(_: GameIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `EpisodeIdentity` object.
		case episodeIdentity(_: EpisodeIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `ShowSong` object.
		case showSong(_: ShowSong, id: UUID = UUID())

		/// Indicates the item kind contains a `GenreIdentity` object.
		case genreIdentity(_: GenreIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `ThemeIdentity` object.
		case themeIdentity(_: ThemeIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `CharacterIdentity` object.
		case characterIdentity(_: CharacterIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `PersonIdentity` object.
		case personIdentity(_: PersonIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `Recap` object.
		case recap(_: Recap, id: UUID = UUID())

		/// Indicates the item kind contains a `QuickLink` object.
		case quickLink(_: QuickLink, id: UUID = UUID())

		/// Indicates the item kind contains a `QuickAction` object.
		case quickAction(_: QuickAction, id: UUID = UUID())

		/// Indicates a legal section layout type.
		case legal(id: UUID = UUID())
	}
}
