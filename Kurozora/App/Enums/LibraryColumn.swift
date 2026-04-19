//
//  LibraryColumn.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

// MARK: - Column
extension KKLibrary {
	enum Column: String, Codable, CaseIterable, Hashable {
		// MARK: - Cases
		/// The item's title. Always visible and always the first column.
		///
		/// When ``KKLibrary/ColumnPreferences/showPoster`` is `true`, the title cell also renders
		/// the poster, rating, and favorite/reminder affordances inline.
		case title

		/// The item's media type, such as `TV`, `Movie`, `Novel`, or `Game`.
		case type

		/// The airing or publishing status, such as `Finished Airing` or `Currently Airing`.
		case status

		/// The item's library rating as a star-and-score number.
		///
		/// Hidden when the poster is shown inside the title cell.
		case rating

		/// A boolean that indicates whether the item is favorited.
		///
		/// Hidden when the poster is shown inside the title cell.
		case favorite

		/// A boolean that indicates whether the item has a reminder set.
		///
		/// Hidden when the poster is shown inside the title cell.
		case reminder

		/// A comma-separated list of the item's genres.
		case genres

		/// The release year, derived from the `startedAt` timestamp.
		case year

		/// The studio, publisher, or developer attached to the item.
		case studio

		/// The date the item was added to the user's library.
		case dateAdded

		/// A composite progress indicator, such as `12/25`.
		case progress

		/// The TV rating, such as `G` or `PG-12`.
		case tvRating

		/// The total number of episodes. Applies to shows only.
		case episodes

		/// The total number of chapters. Applies to literature only.
		case chapters

		/// The total number of volumes. Applies to literature only.
		case volumes

		/// The total number of editions. Applies to games only.
		case editions

		// MARK: - Properties
		/// The localized header title for the column. Empty for icon-only columns.
		var title: String {
			switch self {
			case .title: return L10n.columnTitle
			case .type: return L10n.columnType
			case .status: return L10n.columnStatus
			case .rating: return ""
			case .favorite: return ""
			case .reminder: return ""
			case .genres: return L10n.columnGenres
			case .year: return L10n.columnYear
			case .studio: return L10n.studio
			case .dateAdded: return L10n.columnDateAdded
			case .progress: return L10n.columnProgress
			case .tvRating: return L10n.tvRating
			case .episodes: return L10n.episodes
			case .chapters: return L10n.columnChapters
			case .volumes: return L10n.columnVolumes
			case .editions: return L10n.columnEditions
			}
		}

		/// The icon system name of the column.
		var headerIconSystemName: String? {
			switch self {
			case .rating: return "star.fill"
			case .favorite: return "heart.fill"
			case .reminder: return "bell.fill"
			default: return nil
			}
		}

		/// The accessibility label of the column.
		var accessibilityLabel: String {
			switch self {
			case .rating: return L10n.rating
			case .favorite: return L10n.favorite
			case .reminder: return L10n.reminder
			default: return self.title
			}
		}

		/// The default width applied when the column has not been resized by the user.
		var defaultWidth: CGFloat {
			switch self {
			case .title: return 280
			case .type: return 80
			case .status: return 110
			case .rating: return 96
			case .favorite: return 52
			case .reminder: return 52
			case .genres: return 200
			case .year: return 72
			case .studio: return 140
			case .dateAdded: return 120
			case .progress: return 88
			case .tvRating: return 88
			case .episodes: return 88
			case .chapters: return 88
			case .volumes: return 88
			case .editions: return 88
			}
		}

		/// The smallest width the column may be resized to.
		var minWidth: CGFloat {
			switch self {
			case .title: return 180
			case .favorite, .reminder: return 48
			default: return 56
			}
		}

		/// A boolean that indicates whether the column is pinned visible and cannot be hidden.
		var isAlwaysVisible: Bool {
			return self == .title
		}

		/// A boolean that indicates whether the column is subsumed by the title cell's inline chrome when the poster is shown.
		var isSubsumedByTitleWhenPosterShown: Bool {
			switch self {
			case .rating, .favorite, .reminder: return true
			default: return false
			}
		}

		/// A boolean that indicates whether a backing field exists for the column.
		var hasBackingData: Bool {
			switch self {
			case .dateAdded, .progress: return false
			default: return true
			}
		}

		/// Returns a Boolean that indicates whether this column is meaningful for the given kind.
		///
		/// - Parameter kind: The library kind to evaluate applicability against.
		///
		/// - Returns: `true` if the column can surface a value for the given kind; otherwise, `false`.
		func isApplicable(to kind: KKLibrary.Kind) -> Bool {
			switch self {
			case .episodes: return kind == .shows
			case .chapters, .volumes: return kind == .literatures
			case .editions: return kind == .games
			case .reminder: return kind == .shows
			default: return true
			}
		}
	}
}

// MARK: - ColumnPreferences
extension KKLibrary {
	struct ColumnPreferences: Codable, Hashable {
		// MARK: - Properties
		/// The left-to-right order of every column the user may interact with.
		var order: [Column]

		/// A map of user-adjusted column widths.
		///
		/// Columns missing from the map use ``Column/defaultWidth``.
		var widths: [Column: CGFloat]

		/// The columns the user has explicitly hidden.
		var hidden: Set<Column>

		/// A boolean that indicates whether the title cell renders a poster with inline
		/// rating, favorite, and reminder chrome.
		///
		/// When `true`, the ``Column/rating``, ``Column/favorite``, and ``Column/reminder``
		/// standalone columns are filtered out of the layout.
		var showPoster: Bool

		/// The shared default preferences.
		static let defaultShared: ColumnPreferences = .init(
			order: [.title, .type, .status, .rating, .favorite, .reminder, .genres,
			        .year, .studio, .dateAdded, .progress, .tvRating,
			        .episodes, .chapters, .volumes, .editions],
			widths: [:],
			hidden: [.year, .studio, .dateAdded, .progress, .tvRating,
			         .episodes, .chapters, .volumes, .editions],
			showPoster: true
		)

		// MARK: - Codable
		private enum CodingKeys: String, CodingKey {
			case order, widths, hidden, showPoster
		}

		// MARK: - Initializers
		init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)

			let rawOrder = (try? container.decode([String].self, forKey: .order)) ?? []
			self.order = rawOrder.compactMap { Column(rawValue: $0) }

			let rawWidths = (try? container.decode([String: CGFloat].self, forKey: .widths)) ?? [:]
			self.widths = Dictionary(uniqueKeysWithValues: rawWidths.compactMap { key, value in
				Column(rawValue: key).map { ($0, value) }
			})

			let rawHidden = (try? container.decode([String].self, forKey: .hidden)) ?? []
			self.hidden = Set(rawHidden.compactMap { Column(rawValue: $0) })

			self.showPoster = (try? container.decode(Bool.self, forKey: .showPoster)) ?? true

			let missing = Column.allCases.filter { !self.order.contains($0) }
			self.order.append(contentsOf: missing)
		}

		/// Creates column preferences with the supplied field values.
		///
		/// - Parameters:
		///    - order: The left-to-right order of every column.
		///    - widths: The user-adjusted widths keyed by column.
		///    - hidden: The columns the user has hidden.
		///    - showPoster: A boolean that indicates whether the title cell renders the poster inline.
		init(order: [Column], widths: [Column: CGFloat], hidden: Set<Column>, showPoster: Bool) {
			self.order = order
			self.widths = widths
			self.hidden = hidden
			self.showPoster = showPoster
		}

		func encode(to encoder: Encoder) throws {
			var container = encoder.container(keyedBy: CodingKeys.self)
			try container.encode(self.order.map(\.rawValue), forKey: .order)
			try container.encode(Dictionary(uniqueKeysWithValues: self.widths.map { ($0.key.rawValue, $0.value) }), forKey: .widths)
			try container.encode(self.hidden.map(\.rawValue), forKey: .hidden)
			try container.encode(self.showPoster, forKey: .showPoster)
		}

		// MARK: - Functions
		/// Returns the columns to render for the given library kind, in left-to-right order.
		///
		/// - Parameter kind: The library kind the table is rendering.
		///
		/// - Returns: The visible columns, in left-to-right order.
		func visibleColumns(for kind: KKLibrary.Kind) -> [Column] {
			return self.order.filter { column in
				guard column.hasBackingData else { return false }
				guard !self.hidden.contains(column) else { return false }
				guard column.isApplicable(to: kind) else { return false }

				if self.showPoster, column.isSubsumedByTitleWhenPosterShown {
					return false
				}

				return true
			}
		}

		/// Returns the resolved width for the given column.
		///
		/// - Parameter column: The column whose width to resolve.
		///
		/// - Returns: The user-adjusted width, or ``Column/defaultWidth`` when none has been set.
		func width(for column: Column) -> CGFloat {
			return self.widths[column] ?? column.defaultWidth
		}
	}
}
