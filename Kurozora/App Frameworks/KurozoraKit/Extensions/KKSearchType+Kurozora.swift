//
//  KKSearchType+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/06/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit

extension KKSearchType {
	/// The string value of a search type.
	var stringValue: String {
		switch self {
		case .characters:
			return Trans.characters
		case .episodes:
			return Trans.episodes
		case .games:
			return Trans.games
		case .literatures:
			return Trans.literatures
		case .people:
			return Trans.people
		case .shows:
			return Trans.anime
		case .songs:
			return Trans.songs
		case .studios:
			return Trans.studios
		case .users:
			return Trans.users
		}
	}

	/// The filterable attributes of a search type.
	var filterableAttributes: [(key: FilterKey, value: FilterableAttribute)] {
		switch self {
		case .characters:
			let days = Array(1...31)

			return [
				(key: .status, value: FilterableAttribute(name: "Status", type: .singleSelection, options: CharacterStatus.allCases.map { characterStatus in
					return (characterStatus.title, characterStatus.rawValue)
				})),
				(key: .age, value: FilterableAttribute(name: "Age (years)", type: .stepper, options: nil)),
				(key: .birthDay, value: FilterableAttribute(name: "Birth Day", type: .singleSelection, options: days.map { day in
					let key = day < 10 ? "0\(day)" : "\(day)"
					return (key, day)
				})),
				(key: .birthMonth, value: FilterableAttribute(name: "Birth Month", type: .singleSelection, options: Month.allCases.map { month in
					return (month.name, month.rawValue)
				})),
				(key: .height, value: FilterableAttribute(name: "Height", type: .text, options: nil)),
				(key: .weight, value: FilterableAttribute(name: "Weight", type: .text, options: nil)),
				(key: .bust, value: FilterableAttribute(name: "Bust", type: .text, options: nil)),
				(key: .waist, value: FilterableAttribute(name: "Waist", type: .text, options: nil)),
				(key: .hip, value: FilterableAttribute(name: "Hip", type: .text, options: nil)),
				(key: .astrologicalSign, value: FilterableAttribute(name: "Astrological Sign", type: .singleSelection, options: AstrologicalSign.allCases.map { astrologicalSign in
					return ("\(astrologicalSign.title) \(astrologicalSign.emoji)", astrologicalSign.rawValue)
				}))
			]
		case .episodes:
			var filterableAttributes: [(key: FilterKey, value: FilterableAttribute)] = [
				(key: .duration, value: FilterableAttribute(name: "Duration (minutes)", type: .stepper, options: nil)),
				(key: .tvRating, value: FilterableAttribute(name: "TV Rating", type: .singleSelection, options: TVRating.allCases.map { tvRating in
					return (tvRating.name, tvRating.rawValue)
				})),
				(key: .isFiller, value: FilterableAttribute(name: "Fillers", type: .singleSelection, options: [
					("Shown", 1),
					("Hidden", 0)
				])),
				(key: .isPremiere, value: FilterableAttribute(name: "Premieres", type: .singleSelection, options: [
					("Shown", 1),
					("Hidden", 0)
				])),
				(key: .isFinale, value: FilterableAttribute(name: "Finales", type: .singleSelection, options: [
					("Shown", 1),
					("Hidden", 0)
				])),
				(key: .isSpecial, value: FilterableAttribute(name: "Specials", type: .singleSelection, options: [
					("Shown", 1),
					("Hidden", 0)
				]))
			]

			if self.includeNSFW() {
				filterableAttributes.append((key: .isNSFW, value: FilterableAttribute(name: "NSFW", type: .singleSelection, options: [
					("Shown", 1),
					("Hidden", 0)
				])))
			}

			filterableAttributes.append(contentsOf: [
				(key: .number, value: FilterableAttribute(name: "Number", type: .text, options: nil)),
				(key: .numberTotal, value: FilterableAttribute(name: "Number Total", type: .text, options: nil)),
				(key: .startedAt, value: FilterableAttribute(name: "First Aired", type: .date, options: nil)),
				(key: .endedAt, value: FilterableAttribute(name: "Last Aired", type: .date, options: nil))
			])

			return filterableAttributes
		case .games:
			var filterableAttributes: [(key: FilterKey, value: FilterableAttribute)] = [
				(key: .mediaType, value: FilterableAttribute(name: "Media Type", type: .singleSelection, options: GameType.allCases.map { gameType in
					return (gameType.name, gameType.rawValue)
				})),
				(key: .status, value: FilterableAttribute(name: "Status", type: .singleSelection, options: GameStatus.allCases.map { gameStatus in
					return (gameStatus.name, gameStatus.rawValue)
				})),
				(key: .source, value: FilterableAttribute(name: "Source", type: .singleSelection, options: SourceType.allCases.map { sourceType in
					return (sourceType.name, sourceType.rawValue)
				})),
				(key: .tvRating, value: FilterableAttribute(name: "TV Rating", type: .singleSelection, options: TVRating.allCases.map { tvRating in
					return (tvRating.name, tvRating.rawValue)
				})),
				(key: .editionCount, value: FilterableAttribute(name: "Editions", type: .stepper, options: nil)),
				(key: .publicationSeason, value: FilterableAttribute(name: "Publication Season", type: .singleSelection, options: SeasonOfYear.allCases.map { seasonOfYear in
					return (seasonOfYear.name, seasonOfYear.rawValue)
				})),
				(key: .publicationDay, value: FilterableAttribute(name: "Publication Day", type: .singleSelection, options: DayOfWeek.allCases.map { dayOfWeek in
					return (dayOfWeek.name, dayOfWeek.rawValue)
				})),
				(key: .duration, value: FilterableAttribute(name: "Duration (minutes)", type: .stepper, options: nil)),
				(key: .startedAt, value: FilterableAttribute(name: "First Published", type: .date, options: nil))
			]

			if self.includeNSFW() {
				filterableAttributes.append((key: .isNSFW, value: FilterableAttribute(name: "NSFW", type: .singleSelection, options: [
					("Shown", 1),
					("Hidden", 0)
				])))
			}

			return filterableAttributes
		case .literatures:
			var filterableAttributes: [(key: FilterKey, value: FilterableAttribute)] = [
				(key: .mediaType, value: FilterableAttribute(name: "Media Type", type: .singleSelection, options: LiteratureType.allCases.map { literatureType in
					return (literatureType.name, literatureType.rawValue)
				})),
				(key: .status, value: FilterableAttribute(name: "Status", type: .singleSelection, options: LiteratureStatus.allCases.map { literatureStatus in
					return (literatureStatus.name, literatureStatus.rawValue)
				})),
				(key: .source, value: FilterableAttribute(name: "Source", type: .singleSelection, options: SourceType.allCases.map { sourceType in
					return (sourceType.name, sourceType.rawValue)
				})),
				(key: .tvRating, value: FilterableAttribute(name: "TV Rating", type: .singleSelection, options: TVRating.allCases.map { tvRating in
					return (tvRating.name, tvRating.rawValue)
				})),
				(key: .volumeCount, value: FilterableAttribute(name: "Volumes", type: .stepper, options: nil)),
				(key: .chapterCount, value: FilterableAttribute(name: "Chapters", type: .stepper, options: nil)),
				(key: .pageCount, value: FilterableAttribute(name: "Pages", type: .stepper, options: nil)),
				(key: .duration, value: FilterableAttribute(name: "Duration (minutes)", type: .stepper, options: nil)),
				(key: .publicationSeason, value: FilterableAttribute(name: "Publication Season", type: .singleSelection, options: SeasonOfYear.allCases.map { seasonOfYear in
					return (seasonOfYear.name, seasonOfYear.rawValue)
				})),
				(key: .publicationDay, value: FilterableAttribute(name: "Publication Day", type: .singleSelection, options: DayOfWeek.allCases.map { dayOfWeek in
					return (dayOfWeek.name, dayOfWeek.rawValue)
				})),
				(key: .publicationTime, value: FilterableAttribute(name: "Publication Time", type: .time, options: nil)),
				(key: .startedAt, value: FilterableAttribute(name: "First Published", type: .date, options: nil)),
				(key: .endedAt, value: FilterableAttribute(name: "Last Published", type: .date, options: nil))
			]

			if self.includeNSFW() {
				filterableAttributes.append((key: .isNSFW, value: FilterableAttribute(name: "NSFW", type: .singleSelection, options: [
					("Shown", 1),
					("Hidden", 0)
				])))
			}

			return filterableAttributes
		case .people:
			return [
				(key: .birthDate, value: FilterableAttribute(name: "Birth Date", type: .date, options: nil)),
				(key: .deceasedDate, value: FilterableAttribute(name: "Deceased Date", type: .date, options: nil)),
				(key: .astrologicalSign, value: FilterableAttribute(name: "Astrological Sign", type: .singleSelection, options: AstrologicalSign.allCases.map { astrologicalSign in
					return ("\(astrologicalSign.title) \(astrologicalSign.emoji)", astrologicalSign.rawValue)
				}))
			]
		case .shows:
			var filterableAttributes: [(key: FilterKey, value: FilterableAttribute)] = [
				(key: .mediaType, value: FilterableAttribute(name: "Media Type", type: .singleSelection, options: ShowType.allCases.map { showType in
					return (showType.name, showType.rawValue)
				})),
				(key: .status, value: FilterableAttribute(name: "Status", type: .singleSelection, options: ShowStatus.allCases.map { showStatus in
					return (showStatus.name, showStatus.rawValue)
				})),
				(key: .tvRating, value: FilterableAttribute(name: "TV Rating", type: .singleSelection, options: TVRating.allCases.map { tvRating in
					return (tvRating.name, tvRating.rawValue)
				})),
				(key: .seasonCount, value: FilterableAttribute(name: Trans.seasons, type: .stepper, options: nil)),
				(key: .episodeCount, value: FilterableAttribute(name: Trans.episodes, type: .stepper, options: nil)),
				(key: .airDay, value: FilterableAttribute(name: "Air Day", type: .singleSelection, options: DayOfWeek.allCases.map { dayOfWeek in
					return (dayOfWeek.name, dayOfWeek.rawValue)
				})),
				(key: .airTime, value: FilterableAttribute(name: "Air Time", type: .time, options: nil)),
				(key: .airSeason, value: FilterableAttribute(name: "Air Season", type: .singleSelection, options: SeasonOfYear.allCases.map { seasonOfYear in
					return (seasonOfYear.name, seasonOfYear.rawValue)
				})),
				(key: .duration, value: FilterableAttribute(name: "Duration (minutes)", type: .stepper, options: nil)),
				(key: .startedAt, value: FilterableAttribute(name: "First Aired", type: .date, options: nil)),
				(key: .endedAt, value: FilterableAttribute(name: "Last Aired", type: .date, options: nil)),
				(key: .source, value: FilterableAttribute(name: "Source", type: .singleSelection, options: SourceType.allCases.map { sourceType in
					return (sourceType.name, sourceType.rawValue)
				}))
			]

			if self.includeNSFW() {
				filterableAttributes.append((key: .isNSFW, value: FilterableAttribute(name: "NSFW", type: .singleSelection, options: [
					("Shown", 1),
					("Hidden", 0)
				])))
			}

			return filterableAttributes
		case .songs:
			return []
		case .studios:
			var filterableAttributes: [(key: FilterKey, value: FilterableAttribute)] = [
				(key: .type, value: FilterableAttribute(name: "Type", type: .singleSelection, options: StudioType.allCases.map { studioType in
					return (studioType.name, studioType.rawValue)
				})),
				(key: .address, value: FilterableAttribute(name: "Address", type: .text, options: nil)),
				(key: .founded, value: FilterableAttribute(name: "Founded", type: .date, options: nil))
			]

			if self.includeNSFW() {
				filterableAttributes.append((key: .isNSFW, value: FilterableAttribute(name: "NSFW", type: .singleSelection, options: [
					("Shown", 1),
					("Hidden", 0)
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
