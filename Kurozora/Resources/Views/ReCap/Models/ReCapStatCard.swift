//
//  ReCapStatCard.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit

/// A habit or activity stat shown on a Re:CAP card.
struct ReCapStatCard: nonisolated Hashable {
	// MARK: - Types
	/// The group a stat card belongs to.
	nonisolated enum Group: Hashable, CaseIterable {
		case habits
		case activity

		/// The title of the group.
		@MainActor
		var title: String {
			switch self {
			case .habits:
				return L10n.recapYourHabits
			case .activity:
				return L10n.recapYourActivity
			}
		}
	}

	// MARK: - Properties
	let title: String
	let value: String
	let caption: String?

	// MARK: - Functions
	/// Returns the stat cards of the given stats keyed by group.
	///
	/// - Parameters:
	///    - recapStats: The stats of the period.
	///    - shows: The shows the stats refer to keyed by identity.
	///
	/// - Returns: The stat cards keyed by group.
	static func cards(from recapStats: [RecapStat], shows: [KurozoraItemID: Show]) -> [Group: [ReCapStatCard]] {
		let stats = Dictionary(recapStats.map { ($0.attributes.stat, $0) }, uniquingKeysWith: { first, _ in first })
		let value: (RecapStatType) -> Int? = { stats[$0]?.attributes.value }
		var habits: [ReCapStatCard] = []
		var activity: [ReCapStatCard] = []

		if let weekday = value(.busiestWeekday), weekday > 0 {
			let weekdaySymbols = Self.calendar.standaloneWeekdaySymbols
			habits.append(ReCapStatCard(title: L10n.recapBusiestDay, value: weekdaySymbols[weekday % 7], caption: nil))
		}

		if let hour = value(.busiestHour), let date = Self.calendar.date(bySettingHour: hour, minute: 0, second: 0, of: .now) {
			habits.append(ReCapStatCard(title: L10n.recapFavoriteTime, value: Self.hourFormatter.string(from: date), caption: nil))
		}

		if let streak = stats[.longestStreak] {
			let caption = streak.attributes.occurredAt.map { L10n.recapEnded(Self.dayFormatter.string(from: $0)) }
			habits.append(ReCapStatCard(title: L10n.recapLongestStreak, value: L10n.recapDays(streak.attributes.value), caption: caption))
		}

		if let binge = stats[.biggestBinge] {
			let caption = binge.attributes.occurredAt.map { Self.dayFormatter.string(from: $0) }
			habits.append(ReCapStatCard(title: L10n.recapBiggestBinge, value: L10n.recapEpisodes(binge.attributes.value), caption: caption))
		}

		for (statType, title) in [(RecapStatType.firstTitle, L10n.recapFirstWatch), (.lastTitle, L10n.recapLastWatch)] {
			guard
				let recapStat = stats[statType],
				let showID = recapStat.relationships?.shows?.data.first?.id,
				let show = shows[showID]
			else { continue }

			habits.append(ReCapStatCard(title: title, value: show.attributes.title, caption: L10n.recapEpisodes(recapStat.attributes.value)))
		}

		if let recapStat = stats[.topProvider], let provider = recapStat.relationships?.providers?.data.first {
			habits.append(ReCapStatCard(title: L10n.recapWhereYouWatched, value: provider.attributes.name, caption: L10n.recapEpisodes(recapStat.attributes.value)))
		}

		if let ratingsGiven = value(.ratingsGiven), ratingsGiven > 0 {
			let averageRating = value(.averageRating).flatMap { $0 > 0 ? Double($0) / 100.0 : nil }
			let caption = averageRating.map { L10n.recapAverageOf($0.formatted(.number.precision(.fractionLength(1)))) }
			activity.append(ReCapStatCard(title: L10n.recapRatingsGiven, value: ratingsGiven.formatted(), caption: caption))
		}

		let countStats: [(RecapStatType, String)] = [
			(.reviewsWritten, L10n.recapReviewsWritten),
			(.titlesCompleted, L10n.recapTitlesCompleted),
			(.titlesAdded, L10n.recapTitlesAdded),
			(.titlesDropped, L10n.recapTitlesDropped),
			(.favoritesAdded, L10n.recapFavoritesAdded),
			(.achievementsEarned, L10n.recapAchievementsEarned),
		]

		for (statType, title) in countStats {
			guard let count = value(statType), count > 0 else { continue }
			activity.append(ReCapStatCard(title: title, value: count.formatted(), caption: nil))
		}

		return [.habits: habits, .activity: activity]
	}

	// MARK: - Formatters
	/// The calendar the stats are formatted with.
	private static var calendar: Calendar {
		var calendar = Calendar(identifier: .gregorian)
		calendar.locale = LanguageManager.shared.locale
		return calendar
	}

	/// The formatter of an hour of the day.
	private static var hourFormatter: DateFormatter {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = LanguageManager.shared.locale
		dateFormatter.setLocalizedDateFormatFromTemplate("j")
		return dateFormatter
	}

	/// The formatter of a day of the year.
	private static var dayFormatter: DateFormatter {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = LanguageManager.shared.locale
		dateFormatter.setLocalizedDateFormatFromTemplate("MMMd")
		return dateFormatter
	}
}
