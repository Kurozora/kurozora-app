//
//  SearchType+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/06/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit

extension SearchType {
	/// The string value of a search type.
	var stringValue: String {
		switch self {
		case .characters:
			return L10n.characters
		case .episodes:
			return L10n.episodes
		case .games:
			return L10n.games
		case .literatures:
			return L10n.literatures
		case .people:
			return L10n.people
		case .shows:
			return L10n.shows
		case .songs:
			return L10n.songs
		case .studios:
			return L10n.studios
		case .users:
			return L10n.users
		}
	}

	/// Lowercased synonyms used to match a typed keyword to this search type.
	var tokenKeywords: [String] {
		switch self {
		case .shows:
			return ["anime", "show", "shows", "tv"]
		case .literatures:
			return ["manga", "literature", "literatures", "novel"]
		case .games:
			return ["game", "games"]
		case .characters:
			return ["character", "characters"]
		case .episodes:
			return ["episode", "episodes"]
		case .people:
			return ["person", "people"]
		case .songs:
			return ["song", "songs", "music"]
		case .studios:
			return ["studio", "studios"]
		case .users:
			return ["user", "users"]
		}
	}

	/// The filterable attributes of a search type.
	var filterableAttributes: [(key: FilterKey, value: FilterableAttribute)] {
		switch self {
		case .characters:
			let days = Array(1...31)

			return [
				(key: .status, value: FilterableAttribute(name: L10n.columnStatus, type: .singleSelection, options: CharacterStatus.allCases.map { characterStatus in
					return (characterStatus.title, characterStatus.rawValue)
				})),
				(key: .age, value: FilterableAttribute(name: L10n.ageYears, type: .stepper, options: nil)),
				(key: .birthDay, value: FilterableAttribute(name: L10n.birthDay, type: .singleSelection, options: days.map { day in
					let key = day < 10 ? "0\(day)" : "\(day)"
					return (key, day)
				})),
				(key: .birthMonth, value: FilterableAttribute(name: L10n.birthMonth, type: .singleSelection, options: Month.allCases.map { month in
					return (month.name, month.rawValue)
				})),
				(key: .height, value: FilterableAttribute(name: L10n.height, type: .text, options: nil)),
				(key: .weight, value: FilterableAttribute(name: L10n.weight, type: .text, options: nil)),
				(key: .bust, value: FilterableAttribute(name: L10n.bust, type: .text, options: nil)),
				(key: .waist, value: FilterableAttribute(name: L10n.waist, type: .text, options: nil)),
				(key: .hip, value: FilterableAttribute(name: L10n.hip, type: .text, options: nil)),
				(key: .astrologicalSign, value: FilterableAttribute(name: L10n.astrologicalSign, type: .singleSelection, options: AstrologicalSign.allCases.map { astrologicalSign in
					return ("\(astrologicalSign.title) \(astrologicalSign.emoji)", astrologicalSign.rawValue)
				}))
			]
		case .episodes:
			var filterableAttributes: [(key: FilterKey, value: FilterableAttribute)] = [
				(key: .duration, value: FilterableAttribute(name: L10n.durationMinutes, type: .stepper, options: nil)),
				(key: .tvRating, value: FilterableAttribute(name: L10n.tvRating, type: .singleSelection, options: TVRating.allCases.map { tvRating in
					return (tvRating.name, tvRating.rawValue)
				})),
				(key: .isFiller, value: FilterableAttribute(name: L10n.fillers, type: .singleSelection, options: [
					(L10n.shown, 1),
					(L10n.hidden, 0)
				])),
				(key: .isPremiere, value: FilterableAttribute(name: L10n.premieres, type: .singleSelection, options: [
					(L10n.shown, 1),
					(L10n.hidden, 0)
				])),
				(key: .isFinale, value: FilterableAttribute(name: L10n.finales, type: .singleSelection, options: [
					(L10n.shown, 1),
					(L10n.hidden, 0)
				])),
				(key: .isSpecial, value: FilterableAttribute(name: L10n.specials, type: .singleSelection, options: [
					(L10n.shown, 1),
					(L10n.hidden, 0)
				]))
			]

			if self.includeNSFW() {
				filterableAttributes.append((key: .isNSFW, value: FilterableAttribute(name: L10n.nsfw, type: .singleSelection, options: [
					(L10n.shown, 1),
					(L10n.hidden, 0)
				])))
			}

			filterableAttributes.append(contentsOf: [
				(key: .number, value: FilterableAttribute(name: L10n.number, type: .stepper, options: nil)),
				(key: .numberTotal, value: FilterableAttribute(name: L10n.numberTotal, type: .stepper, options: nil)),
				(key: .startedAt, value: FilterableAttribute(name: L10n.firstAired, type: .date, options: nil)),
				(key: .endedAt, value: FilterableAttribute(name: L10n.lastAired, type: .date, options: nil))
			])

			return filterableAttributes
		case .games:
			var filterableAttributes: [(key: FilterKey, value: FilterableAttribute)] = [
				(key: .mediaType, value: FilterableAttribute(name: L10n.mediaType, type: .singleSelection, options: GameType.allCases.map { gameType in
					return (gameType.name, gameType.rawValue)
				})),
				(key: .status, value: FilterableAttribute(name: L10n.columnStatus, type: .singleSelection, options: GameStatus.allCases.map { gameStatus in
					return (gameStatus.name, gameStatus.rawValue)
				})),
				(key: .source, value: FilterableAttribute(name: L10n.source, type: .singleSelection, options: SourceType.allCases.map { sourceType in
					return (sourceType.name, sourceType.rawValue)
				})),
				(key: .tvRating, value: FilterableAttribute(name: L10n.tvRating, type: .singleSelection, options: TVRating.allCases.map { tvRating in
					return (tvRating.name, tvRating.rawValue)
				})),
				(key: .countryOfOrigin, value: FilterableAttribute(name: L10n.countryOfOrigin, type: .singleSelection, options: CountryOfOrigin.allCases.map { countryOfOrigin in
					return (countryOfOrigin.name, countryOfOrigin.rawValue)
				})),
				(key: .editionCount, value: FilterableAttribute(name: L10n.columnEditions, type: .stepper, options: nil)),
				(key: .publicationSeason, value: FilterableAttribute(name: L10n.publicationSeason, type: .singleSelection, options: SeasonOfYear.allCases.map { seasonOfYear in
					return (seasonOfYear.name, seasonOfYear.rawValue)
				})),
				(key: .publicationDay, value: FilterableAttribute(name: L10n.publicationDay, type: .singleSelection, options: DayOfWeek.allCases.map { dayOfWeek in
					return (dayOfWeek.name, dayOfWeek.rawValue)
				})),
				(key: .duration, value: FilterableAttribute(name: L10n.durationMinutes, type: .stepper, options: nil)),
				(key: .publishedAt, value: FilterableAttribute(name: L10n.firstPublished, type: .date, options: nil))
			]

			if self.includeNSFW() {
				filterableAttributes.append((key: .isNSFW, value: FilterableAttribute(name: L10n.nsfw, type: .singleSelection, options: [
					(L10n.shown, 1),
					(L10n.hidden, 0)
				])))
			}

			return filterableAttributes
		case .literatures:
			var filterableAttributes: [(key: FilterKey, value: FilterableAttribute)] = [
				(key: .mediaType, value: FilterableAttribute(name: L10n.mediaType, type: .singleSelection, options: LiteratureType.allCases.map { literatureType in
					return (literatureType.name, literatureType.rawValue)
				})),
				(key: .status, value: FilterableAttribute(name: L10n.columnStatus, type: .singleSelection, options: LiteratureStatus.allCases.map { literatureStatus in
					return (literatureStatus.name, literatureStatus.rawValue)
				})),
				(key: .source, value: FilterableAttribute(name: L10n.source, type: .singleSelection, options: SourceType.allCases.map { sourceType in
					return (sourceType.name, sourceType.rawValue)
				})),
				(key: .tvRating, value: FilterableAttribute(name: L10n.tvRating, type: .singleSelection, options: TVRating.allCases.map { tvRating in
					return (tvRating.name, tvRating.rawValue)
				})),
				(key: .countryOfOrigin, value: FilterableAttribute(name: L10n.countryOfOrigin, type: .singleSelection, options: CountryOfOrigin.allCases.map { countryOfOrigin in
					return (countryOfOrigin.name, countryOfOrigin.rawValue)
				})),
				(key: .volumeCount, value: FilterableAttribute(name: L10n.columnVolumes, type: .stepper, options: nil)),
				(key: .chapterCount, value: FilterableAttribute(name: L10n.columnChapters, type: .stepper, options: nil)),
				(key: .pageCount, value: FilterableAttribute(name: L10n.pages, type: .stepper, options: nil)),
				(key: .duration, value: FilterableAttribute(name: L10n.durationMinutes, type: .stepper, options: nil)),
				(key: .publicationSeason, value: FilterableAttribute(name: L10n.publicationSeason, type: .singleSelection, options: SeasonOfYear.allCases.map { seasonOfYear in
					return (seasonOfYear.name, seasonOfYear.rawValue)
				})),
				(key: .publicationDay, value: FilterableAttribute(name: L10n.publicationDay, type: .singleSelection, options: DayOfWeek.allCases.map { dayOfWeek in
					return (dayOfWeek.name, dayOfWeek.rawValue)
				})),
				(key: .publicationTime, value: FilterableAttribute(name: L10n.publicationTime, type: .time, options: nil)),
				(key: .startedAt, value: FilterableAttribute(name: L10n.firstPublished, type: .date, options: nil)),
				(key: .endedAt, value: FilterableAttribute(name: L10n.lastPublished, type: .date, options: nil))
			]

			if self.includeNSFW() {
				filterableAttributes.append((key: .isNSFW, value: FilterableAttribute(name: L10n.nsfw, type: .singleSelection, options: [
					(L10n.shown, 1),
					(L10n.hidden, 0)
				])))
			}

			return filterableAttributes
		case .people:
			return [
				(key: .birthDate, value: FilterableAttribute(name: L10n.birthDate, type: .date, options: nil)),
				(key: .deceasedDate, value: FilterableAttribute(name: L10n.deceasedDate, type: .date, options: nil)),
				(key: .astrologicalSign, value: FilterableAttribute(name: L10n.astrologicalSign, type: .singleSelection, options: AstrologicalSign.allCases.map { astrologicalSign in
					return ("\(astrologicalSign.title) \(astrologicalSign.emoji)", astrologicalSign.rawValue)
				}))
			]
		case .shows:
			var filterableAttributes: [(key: FilterKey, value: FilterableAttribute)] = [
				(key: .mediaType, value: FilterableAttribute(name: L10n.mediaType, type: .singleSelection, options: ShowType.allCases.map { showType in
					return (showType.name, showType.rawValue)
				})),
				(key: .status, value: FilterableAttribute(name: L10n.columnStatus, type: .singleSelection, options: ShowStatus.allCases.map { showStatus in
					return (showStatus.name, showStatus.rawValue)
				})),
				(key: .tvRating, value: FilterableAttribute(name: L10n.tvRating, type: .singleSelection, options: TVRating.allCases.map { tvRating in
					return (tvRating.name, tvRating.rawValue)
				})),
				(key: .countryOfOrigin, value: FilterableAttribute(name: L10n.countryOfOrigin, type: .singleSelection, options: CountryOfOrigin.allCases.map { countryOfOrigin in
					return (countryOfOrigin.name, countryOfOrigin.rawValue)
				})),
				(key: .seasonCount, value: FilterableAttribute(name: L10n.seasons, type: .stepper, options: nil)),
				(key: .episodeCount, value: FilterableAttribute(name: L10n.episodes, type: .stepper, options: nil)),
				(key: .airDay, value: FilterableAttribute(name: L10n.airDay, type: .singleSelection, options: DayOfWeek.allCases.map { dayOfWeek in
					return (dayOfWeek.name, dayOfWeek.rawValue)
				})),
				(key: .airTime, value: FilterableAttribute(name: L10n.airTime, type: .time, options: nil)),
				(key: .airSeason, value: FilterableAttribute(name: L10n.airSeason, type: .singleSelection, options: SeasonOfYear.allCases.map { seasonOfYear in
					return (seasonOfYear.name, seasonOfYear.rawValue)
				})),
				(key: .duration, value: FilterableAttribute(name: L10n.durationMinutes, type: .stepper, options: nil)),
				(key: .startedAt, value: FilterableAttribute(name: L10n.firstAired, type: .date, options: nil)),
				(key: .endedAt, value: FilterableAttribute(name: L10n.lastAired, type: .date, options: nil)),
				(key: .source, value: FilterableAttribute(name: L10n.source, type: .singleSelection, options: SourceType.allCases.map { sourceType in
					return (sourceType.name, sourceType.rawValue)
				}))
			]

			if self.includeNSFW() {
				filterableAttributes.append((key: .isNSFW, value: FilterableAttribute(name: L10n.nsfw, type: .singleSelection, options: [
					(L10n.shown, 1),
					(L10n.hidden, 0)
				])))
			}

			return filterableAttributes
		case .songs:
			return []
		case .studios:
			var filterableAttributes: [(key: FilterKey, value: FilterableAttribute)] = [
				(key: .type, value: FilterableAttribute(name: L10n.columnType, type: .singleSelection, options: StudioType.allCases.map { studioType in
					return (studioType.name, studioType.rawValue)
				})),
				(key: .tvRating, value: FilterableAttribute(name: L10n.tvRating, type: .singleSelection, options: TVRating.allCases.map { tvRating in
					return (tvRating.name, tvRating.rawValue)
				})),
				(key: .address, value: FilterableAttribute(name: L10n.address, type: .text, options: nil)),
				(key: .foundedAt, value: FilterableAttribute(name: L10n.founded, type: .date, options: nil)),
				(key: .defunctAt, value: FilterableAttribute(name: L10n.defunct, type: .date, options: nil))
			]

			if self.includeNSFW() {
				filterableAttributes.append((key: .isNSFW, value: FilterableAttribute(name: L10n.nsfw, type: .singleSelection, options: [
					(L10n.shown, 1),
					(L10n.hidden, 0)
				])))
			}

			return filterableAttributes
		case .users:
			return []
		}
	}

	/// Determines whether to include NSFW filterable attributes.
	fileprivate func includeNSFW() -> Bool {
		guard let preferredTVRating = User.current?.attributes.preferredTVRating else { return false }
		guard let tvRating = TVRating(rawValue: preferredTVRating) else { return false }

		return tvRating.isNSFW
	}
}
