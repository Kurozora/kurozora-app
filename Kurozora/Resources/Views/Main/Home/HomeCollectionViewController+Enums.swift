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
	enum SectionLayoutKind: Hashable {
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

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .banner(let exploreCategory):
				hasher.combine(exploreCategory)
			case .small(let exploreCategory):
				hasher.combine(exploreCategory)
			case .medium(let exploreCategory):
				hasher.combine(exploreCategory)
			case .large(let exploreCategory):
				hasher.combine(exploreCategory)
			case .video(let exploreCategory):
				hasher.combine(exploreCategory)
			case .upcoming(let exploreCategory):
				hasher.combine(exploreCategory)
			case .profile(let exploreCategory):
				hasher.combine(exploreCategory)
			case .episode(let exploreCategory):
				hasher.combine(exploreCategory)
			case .music(let exploreCategory):
				hasher.combine(exploreCategory)
			case .quickLinks(let id):
				hasher.combine(id)
			case .quickActions(let id):
				hasher.combine(id)
			case .legal(let id):
				hasher.combine(id)
			}
		}

		static func == (lhs: SectionLayoutKind, rhs: SectionLayoutKind) -> Bool {
			switch (lhs, rhs) {
			case (.banner(let exploreCategory1), .banner(let exploreCategory2)):
				return exploreCategory1 == exploreCategory2
			case (.small(let exploreCategory1), .small(let exploreCategory2)):
				return exploreCategory1 == exploreCategory2
			case (.medium(let exploreCategory1), .medium(let exploreCategory2)):
				return exploreCategory1 == exploreCategory2
			case (.large(let exploreCategory1), .large(let exploreCategory2)):
				return exploreCategory1 == exploreCategory2
			case (.video(let exploreCategory1), .video(let exploreCategory2)):
				return exploreCategory1 == exploreCategory2
			case (.upcoming(let exploreCategory1), .upcoming(let exploreCategory2)):
				return exploreCategory1 == exploreCategory2
			case (.profile(let exploreCategory1), .profile(let exploreCategory2)):
				return exploreCategory1 == exploreCategory2
			case (.episode(let exploreCategory1), .episode(let exploreCategory2)):
				return exploreCategory1 == exploreCategory2
			case (.music(let exploreCategory1), .music(let exploreCategory2)):
				return exploreCategory1 == exploreCategory2
			case (.quickLinks(let id1), .quickLinks(let id2)):
				return id1 == id2
			case (.quickActions(let id1), .quickActions(let id2)):
				return id1 == id2
			case (.legal(let id1), .legal(let id2)):
				return id1 == id2
			default: return false
			}
		}
	}

	/// List of available Item Kind types.
	enum ItemKind: Hashable {
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

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .showIdentity(let showIdentity, let id):
				hasher.combine(showIdentity)
				hasher.combine(id)
			case .literatureIdentity(let literatureIdentity, let id):
				hasher.combine(literatureIdentity)
				hasher.combine(id)
			case .gameIdentity(let gameIdentity, let id):
				hasher.combine(gameIdentity)
				hasher.combine(id)
			case .episodeIdentity(let episodeIdentity, let id):
				hasher.combine(episodeIdentity)
				hasher.combine(id)
			case .showSong(let showSong, let id):
				hasher.combine(showSong)
				hasher.combine(id)
			case .genreIdentity(let genreIdentity, let id):
				hasher.combine(genreIdentity)
				hasher.combine(id)
			case .themeIdentity(let themeIdentity, let id):
				hasher.combine(themeIdentity)
				hasher.combine(id)
			case .characterIdentity(let characterIdentity, let id):
				hasher.combine(characterIdentity)
				hasher.combine(id)
			case .personIdentity(let personIdentity, let id):
				hasher.combine(personIdentity)
				hasher.combine(id)
			case .recap(let recap, let id):
				hasher.combine(recap)
				hasher.combine(id)
			case .quickLink(let quickLink, let id):
				hasher.combine(quickLink)
				hasher.combine(id)
			case .quickAction(let quickAction, let id):
				hasher.combine(quickAction)
				hasher.combine(id)
			case .legal(let id):
				hasher.combine(id)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.showIdentity(let showIdentity1, let id1), .showIdentity(let showIdentity2, let id2)):
				return showIdentity1 == showIdentity2 && id1 == id2
			case (.literatureIdentity(let literatureIdentity1, let id1), .literatureIdentity(let literatureIdentity2, let id2)):
				return literatureIdentity1 == literatureIdentity2 && id1 == id2
			case (.gameIdentity(let gameIdentity1, let id1), .gameIdentity(let gameIdentity2, let id2)):
				return gameIdentity1 == gameIdentity2 && id1 == id2
			case (.episodeIdentity(let episodeIdentity1, let id1), .episodeIdentity(let episodeIdentity2, let id2)):
				return episodeIdentity1 == episodeIdentity2 && id1 == id2
			case (.showSong(let showSong1, let id1), .showSong(let showSong2, let id2)):
				return showSong1 == showSong2 && id1 == id2
			case (.genreIdentity(let genreIdentity1, let id1), .genreIdentity(let genreIdentity2, let id2)):
				return genreIdentity1 == genreIdentity2 && id1 == id2
			case (.themeIdentity(let themeIdentity1, let id1), .themeIdentity(let themeIdentity2, let id2)):
				return themeIdentity1 == themeIdentity2 && id1 == id2
			case (.characterIdentity(let characterIdentity1, let id1), .characterIdentity(let characterIdentity2, let id2)):
				return characterIdentity1 == characterIdentity2 && id1 == id2
			case (.personIdentity(let personIdentity1, let id1), .personIdentity(let personIdentity2, let id2)):
				return personIdentity1 == personIdentity2 && id1 == id2
			case (.recap(let recap1, let id1), .recap(let recap2, let id2)):
				return recap1 == recap2 && id1 == id2
			case (.quickLink(let quickLink1, let id1), .quickLink(let quickLink2, let id2)):
				return quickLink1 == quickLink2 && id1 == id2
			case (.quickAction(let quickAction1, let id1), .quickAction(let quickAction2, let id2)):
				return quickAction1 == quickAction2 && id1 == id2
			case (.legal(let id1), .legal(let id2)):
				return id1 == id2
			default:
				return false
			}
		}
	}
}
