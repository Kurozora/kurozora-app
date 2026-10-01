//
//  SearchType+Filters.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit

// MARK: - Descriptors
extension SearchType {
	/// The filters a search type offers.
	var filterDescriptors: [FilterDescriptor] {
		switch self {
		case .characters:
			return [
				FilterDescriptor(key: .status, title: L10n.columnStatus, control: .numberPills(Self.options(CharacterStatus.allCases.map { ($0.title, $0.rawValue) }))),
				FilterDescriptor(key: .age, title: L10n.ageYears, control: .buckets(Self.ageBuckets)),
				FilterDescriptor(key: .birthMonth, title: L10n.birthMonth, control: .numberPills(Self.options(Month.allCases.map { ($0.name, $0.rawValue) }))),
				FilterDescriptor(key: .astrologicalSign, title: L10n.astrologicalSign, control: .numberPills(Self.options(AstrologicalSign.allCases.map { ("\($0.title) \($0.emoji)", $0.rawValue) }))),
				FilterDescriptor(key: .height, title: L10n.height, control: .text),
				FilterDescriptor(key: .weight, title: L10n.weight, control: .text),
				FilterDescriptor(key: .bust, title: L10n.bust, control: .text),
				FilterDescriptor(key: .waist, title: L10n.waist, control: .text),
				FilterDescriptor(key: .hip, title: L10n.hip, control: .text)
			]
		case .episodes:
			var descriptors: [FilterDescriptor] = [
				FilterDescriptor(key: .duration, title: L10n.duration, control: .duration(Self.screenDurations)),
				FilterDescriptor(key: .tvRating, title: L10n.tvRating, control: .numberPills(Self.options(TVRating.allCases.map { ($0.name, $0.rawValue) }))),
				FilterDescriptor(key: .fillerKind, title: L10n.fillers, control: .numberPills(Self.options(EpisodeFillerKind.allCases.map { ($0.stringValue, $0.rawValue) }))),
				FilterDescriptor(key: .isPremiere, title: L10n.premieres, control: .booleanPills(trueTitle: L10n.shown, falseTitle: L10n.hidden)),
				FilterDescriptor(key: .isFinale, title: L10n.finales, control: .booleanPills(trueTitle: L10n.shown, falseTitle: L10n.hidden)),
				FilterDescriptor(key: .isSpecial, title: L10n.specials, control: .booleanPills(trueTitle: L10n.shown, falseTitle: L10n.hidden))
			]

			if self.includeNSFW() {
				descriptors.append(FilterDescriptor(key: .isNSFW, title: L10n.nsfw, control: .booleanPills(trueTitle: L10n.shown, falseTitle: L10n.hidden)))
			}

			descriptors.append(contentsOf: [
				FilterDescriptor(key: .number, title: L10n.number, control: .buckets(Self.episodeBuckets)),
				FilterDescriptor(key: .startedAt, title: L10n.firstAired, control: .date),
				FilterDescriptor(key: .endedAt, title: L10n.lastAired, control: .date)
			])

			return descriptors
		case .games:
			var descriptors: [FilterDescriptor] = [
				FilterDescriptor(key: .duration, title: L10n.duration, control: .duration(Self.playDurations)),
				FilterDescriptor(key: .mediaType, title: L10n.mediaType, control: .numberPills(Self.options(GameType.allCases.map { ($0.name, $0.rawValue) }))),
				FilterDescriptor(key: .source, title: L10n.source, control: .numberPills(Self.options(SourceType.allCases.map { ($0.name, $0.rawValue) }))),
				FilterDescriptor(key: .countryOfOrigin, title: L10n.countryOfOrigin, control: .textPills(CountryOfOrigin.allCases.map { FilterOption(title: $0.name, value: $0.value) })),
				FilterDescriptor(key: .publicationSeason, title: L10n.publicationSeason, control: .numberPills(Self.options(SeasonOfYear.allCases.map { ($0.name, $0.rawValue) }))),
				FilterDescriptor(key: .publicationDay, title: L10n.publicationDay, control: .numberPills(Self.options(DayOfWeek.allCases.map { ($0.name, $0.rawValue) }))),
				FilterDescriptor(key: .status, title: L10n.columnStatus, control: .numberPills(Self.options(GameStatus.allCases.map { ($0.name, $0.rawValue) }))),
				FilterDescriptor(key: .tvRating, title: L10n.tvRating, control: .numberPills(Self.options(TVRating.allCases.map { ($0.name, $0.rawValue) })))
			]

			if self.includeNSFW() {
				descriptors.append(FilterDescriptor(key: .isNSFW, title: L10n.nsfw, control: .booleanPills(trueTitle: L10n.shown, falseTitle: L10n.hidden)))
			}

			descriptors.append(contentsOf: [
				FilterDescriptor(key: .editionCount, title: L10n.columnEditions, control: .buckets(Self.editionBuckets)),
				FilterDescriptor(key: .publishedAt, title: L10n.firstPublished, control: .date)
			])

			return descriptors
		case .literatures:
			var descriptors: [FilterDescriptor] = [
				FilterDescriptor(key: .duration, title: L10n.duration, control: .duration(Self.readDurations)),
				FilterDescriptor(key: .mediaType, title: L10n.mediaType, control: .numberPills(Self.options(LiteratureType.allCases.map { ($0.name, $0.rawValue) }))),
				FilterDescriptor(key: .source, title: L10n.source, control: .numberPills(Self.options(SourceType.allCases.map { ($0.name, $0.rawValue) }))),
				FilterDescriptor(key: .countryOfOrigin, title: L10n.countryOfOrigin, control: .textPills(CountryOfOrigin.allCases.map { FilterOption(title: $0.name, value: $0.value) })),
				FilterDescriptor(key: .publicationSeason, title: L10n.publicationSeason, control: .numberPills(Self.options(SeasonOfYear.allCases.map { ($0.name, $0.rawValue) }))),
				FilterDescriptor(key: .publicationDay, title: L10n.publicationDay, control: .numberPills(Self.options(DayOfWeek.allCases.map { ($0.name, $0.rawValue) }))),
				FilterDescriptor(key: .status, title: L10n.columnStatus, control: .numberPills(Self.options(LiteratureStatus.allCases.map { ($0.name, $0.rawValue) }))),
				FilterDescriptor(key: .tvRating, title: L10n.tvRating, control: .numberPills(Self.options(TVRating.allCases.map { ($0.name, $0.rawValue) })))
			]

			if self.includeNSFW() {
				descriptors.append(FilterDescriptor(key: .isNSFW, title: L10n.nsfw, control: .booleanPills(trueTitle: L10n.shown, falseTitle: L10n.hidden)))
			}

			descriptors.append(contentsOf: [
				FilterDescriptor(key: .volumeCount, title: L10n.columnVolumes, control: .buckets(Self.volumeBuckets)),
				FilterDescriptor(key: .chapterCount, title: L10n.columnChapters, control: .buckets(Self.chapterBuckets)),
				FilterDescriptor(key: .pageCount, title: L10n.pages, control: .buckets(Self.pageBuckets)),
				FilterDescriptor(key: .publicationTime, title: L10n.publicationTime, control: .numberPills(Self.dayPartOptions)),
				FilterDescriptor(key: .startedAt, title: L10n.firstPublished, control: .date),
				FilterDescriptor(key: .endedAt, title: L10n.lastPublished, control: .date)
			])

			return descriptors
		case .people:
			return [
				FilterDescriptor(key: .astrologicalSign, title: L10n.astrologicalSign, control: .numberPills(Self.options(AstrologicalSign.allCases.map { ("\($0.title) \($0.emoji)", $0.rawValue) }))),
				FilterDescriptor(key: .birthDate, title: L10n.birthDate, control: .date),
				FilterDescriptor(key: .deceasedDate, title: L10n.deceasedDate, control: .date)
			]
		case .shows:
			var descriptors: [FilterDescriptor] = [
				FilterDescriptor(key: .duration, title: L10n.duration, control: .duration(Self.screenDurations)),
				FilterDescriptor(key: .mediaType, title: L10n.mediaType, control: .numberPills(Self.options(ShowType.allCases.map { ($0.name, $0.rawValue) }))),
				FilterDescriptor(key: .source, title: L10n.source, control: .numberPills(Self.options(SourceType.allCases.map { ($0.name, $0.rawValue) }))),
				FilterDescriptor(key: .countryOfOrigin, title: L10n.countryOfOrigin, control: .textPills(CountryOfOrigin.allCases.map { FilterOption(title: $0.name, value: $0.value) })),
				FilterDescriptor(key: .airSeason, title: L10n.airSeason, control: .numberPills(Self.options(SeasonOfYear.allCases.map { ($0.name, $0.rawValue) }))),
				FilterDescriptor(key: .airDay, title: L10n.airDay, control: .numberPills(Self.options(DayOfWeek.allCases.map { ($0.name, $0.rawValue) }))),
				FilterDescriptor(key: .status, title: L10n.columnStatus, control: .numberPills(Self.options(ShowStatus.allCases.map { ($0.name, $0.rawValue) }))),
				FilterDescriptor(key: .tvRating, title: L10n.tvRating, control: .numberPills(Self.options(TVRating.allCases.map { ($0.name, $0.rawValue) })))
			]

			if self.includeNSFW() {
				descriptors.append(FilterDescriptor(key: .isNSFW, title: L10n.nsfw, control: .booleanPills(trueTitle: L10n.shown, falseTitle: L10n.hidden)))
			}

			descriptors.append(contentsOf: [
				FilterDescriptor(key: .seasonCount, title: L10n.seasons, control: .buckets(Self.seasonBuckets)),
				FilterDescriptor(key: .episodeCount, title: L10n.episodes, control: .buckets(Self.episodeBuckets)),
				FilterDescriptor(key: .airTime, title: L10n.airTime, control: .numberPills(Self.dayPartOptions)),
				FilterDescriptor(key: .startedAt, title: L10n.firstAired, control: .date),
				FilterDescriptor(key: .endedAt, title: L10n.lastAired, control: .date)
			])

			return descriptors
		case .songs:
			return []
		case .studios:
			var descriptors: [FilterDescriptor] = [
				FilterDescriptor(key: .type, title: L10n.columnType, control: .numberPills(Self.options(StudioType.allCases.map { ($0.name, $0.rawValue) }))),
				FilterDescriptor(key: .tvRating, title: L10n.tvRating, control: .numberPills(Self.options(TVRating.allCases.map { ($0.name, $0.rawValue) })))
			]

			if self.includeNSFW() {
				descriptors.append(FilterDescriptor(key: .isNSFW, title: L10n.nsfw, control: .booleanPills(trueTitle: L10n.shown, falseTitle: L10n.hidden)))
			}

			descriptors.append(contentsOf: [
				FilterDescriptor(key: .address, title: L10n.address, control: .text),
				FilterDescriptor(key: .foundedAt, title: L10n.founded, control: .date),
				FilterDescriptor(key: .defunctAt, title: L10n.defunct, control: .date)
			])

			return descriptors
		case .users:
			return []
		}
	}

	/// Returns the descriptor registered under the given key.
	///
	/// - Parameter key: The key of the descriptor.
	///
	/// - Returns: The matching descriptor.
	func filterDescriptor(for key: FilterKey) -> FilterDescriptor? {
		return self.filterDescriptors.first { $0.key == key }
	}
}

// MARK: - Options
private extension SearchType {
	/// The durations offered for something watched.
	static var screenDurations: [TimeInterval] {
		return [300, 900, 1800, 2700, 3600, 7200, 10800]
	}

	/// The durations offered for something read.
	static var readDurations: [TimeInterval] {
		return [300, 600, 900, 1800, 3600]
	}

	/// The durations offered for something played.
	static var playDurations: [TimeInterval] {
		return [7200, 18000, 36000, 72000, 180000, 360000]
	}

	/// The parts of the day a title airs or publishes.
	static var dayPartOptions: [FilterOption<Int>] {
		return DayPart.allCases.map { dayPart in
			FilterOption(title: dayPart.name, subtitle: dayPart.rangeDescription, value: dayPart.rawValue)
		}
	}

	/// The season counts offered.
	static var seasonBuckets: [FilterBucket] {
		return [
			FilterBucket(title: "1", minimum: 1, maximum: 1),
			FilterBucket(title: "2-3", minimum: 2, maximum: 3),
			FilterBucket(title: "4-6", minimum: 4, maximum: 6),
			FilterBucket(title: "7+", minimum: 7)
		]
	}

	/// The episode counts offered.
	static var episodeBuckets: [FilterBucket] {
		return [
			FilterBucket(title: "1", minimum: 1, maximum: 1),
			FilterBucket(title: "2-12", minimum: 2, maximum: 12),
			FilterBucket(title: "13-26", minimum: 13, maximum: 26),
			FilterBucket(title: "27-50", minimum: 27, maximum: 50),
			FilterBucket(title: "51-100", minimum: 51, maximum: 100),
			FilterBucket(title: "100+", minimum: 101)
		]
	}

	/// The volume counts offered.
	static var volumeBuckets: [FilterBucket] {
		return [
			FilterBucket(title: "1", minimum: 1, maximum: 1),
			FilterBucket(title: "2-5", minimum: 2, maximum: 5),
			FilterBucket(title: "6-15", minimum: 6, maximum: 15),
			FilterBucket(title: "16-30", minimum: 16, maximum: 30),
			FilterBucket(title: "31+", minimum: 31)
		]
	}

	/// The chapter counts offered.
	static var chapterBuckets: [FilterBucket] {
		return [
			FilterBucket(title: "1-25", minimum: 1, maximum: 25),
			FilterBucket(title: "26-100", minimum: 26, maximum: 100),
			FilterBucket(title: "101-300", minimum: 101, maximum: 300),
			FilterBucket(title: "301+", minimum: 301)
		]
	}

	/// The page counts offered.
	static var pageBuckets: [FilterBucket] {
		return [
			FilterBucket(title: "1-50", minimum: 1, maximum: 50),
			FilterBucket(title: "51-150", minimum: 51, maximum: 150),
			FilterBucket(title: "151-400", minimum: 151, maximum: 400),
			FilterBucket(title: "401+", minimum: 401)
		]
	}

	/// The edition counts offered.
	static var editionBuckets: [FilterBucket] {
		return [
			FilterBucket(title: "1", minimum: 1, maximum: 1),
			FilterBucket(title: "2-3", minimum: 2, maximum: 3),
			FilterBucket(title: "4+", minimum: 4)
		]
	}

	/// The ages offered.
	static var ageBuckets: [FilterBucket] {
		return [
			FilterBucket(title: "0-12", minimum: 0, maximum: 12),
			FilterBucket(title: "13-17", minimum: 13, maximum: 17),
			FilterBucket(title: "18-29", minimum: 18, maximum: 29),
			FilterBucket(title: "30+", minimum: 30)
		]
	}

	/// Returns choices built from the given titles and values.
	///
	/// - Parameter pairs: The title and value of each choice.
	///
	/// - Returns: The choices the control offers.
	static func options(_ pairs: [(String, Int)]) -> [FilterOption<Int>] {
		return pairs.map { title, value in
			FilterOption(title: title, value: value)
		}
	}

	/// Determines whether to include NSFW filters.
	func includeNSFW() -> Bool {
		guard let preferredTVRating = User.current?.attributes.preferredTVRating else { return false }

		return TVRating.includesNSFW(preferredTVRating)
	}
}
