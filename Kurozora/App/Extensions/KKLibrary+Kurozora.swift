//
//  KKLibraryKind+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/10/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit

extension KKLibrary.Kind {
	/// An array containing all `KKLibrary.Kind` key and value pairs.
	static var alertControllerItems: [(String, KKLibrary.Kind)] {
		var items = [(String, KKLibrary.Kind)]()
		for section in KKLibrary.Kind.allCases {
			items.append((section.stringValue, section))
		}
		return items
	}
}

// MARK: - Library preferences
extension UserSettings {
	/// Returns the user's preferred cell style for the given library kind and status.
	///
	/// - Parameters:
	///    - libraryKind: The library kind whose preferred cell style to look up.
	///    - status: The library status whose preferred cell style to look up.
	///
	/// - Returns: The stored `KKLibrary.CellStyle` for the given kind and status, or `.detailed` if none has been persisted.
	static func libraryCellStyle(for libraryKind: KKLibrary.Kind, status: KKLibrary.Status) -> KKLibrary.CellStyle {
		let rawValue = self.libraryCellStyles[self.libraryCellStyleKey(for: libraryKind, status: status)] ?? 0
		return KKLibrary.CellStyle(rawValue: rawValue) ?? .detailed
	}

	/// Persists the user's preferred cell style for the given library kind and status.
	///
	/// - Parameters:
	///    - cellStyle: The cell style to persist.
	///    - libraryKind: The library kind the cell style applies to.
	///    - status: The library status the cell style applies to.
	static func setLibraryCellStyle(_ cellStyle: KKLibrary.CellStyle, for libraryKind: KKLibrary.Kind, status: KKLibrary.Status) {
		var libraryLayouts = self.libraryCellStyles
		libraryLayouts[self.libraryCellStyleKey(for: libraryKind, status: status)] = cellStyle.rawValue
		self.set(libraryLayouts, forKey: .libraryCellStyles)
	}

	/// Returns the composite storage key used by the cell-style preference map.
	///
	/// - Parameters:
	///    - libraryKind: The library kind to encode into the key.
	///    - status: The library status to encode into the key.
	///
	/// - Returns: A string of the form `"{libraryKind.urlPathName}.{status.sectionValue}"`.
	private static func libraryCellStyleKey(for libraryKind: KKLibrary.Kind, status: KKLibrary.Status) -> String {
		return "\(libraryKind.urlPathName).\(status.sectionValue)"
	}

	/// Returns the user's column preferences for the given library kind and status.
	///
	/// Falls back to ``KKLibrary/ColumnPreferences/defaultShared`` when nothing has been
	/// persisted or decoding fails.
	///
	/// - Parameters:
	///    - libraryKind: The library kind whose column preferences to look up.
	///    - status: The library status whose column preferences to look up.
	/// - Returns: The stored ``KKLibrary/ColumnPreferences``, or the default.
	static func libraryColumnPreferences(for libraryKind: KKLibrary.Kind, status: KKLibrary.Status) -> KKLibrary.ColumnPreferences {
		let key = self.libraryColumnPreferencesKey(for: libraryKind, status: status)

		guard
			let blob = self.libraryColumnPreferencesMap[key],
			let decoded = try? JSONDecoder().decode(KKLibrary.ColumnPreferences.self, from: blob)
		else {
			return .defaultShared
		}

		return decoded
	}

	/// Persists the user's column preferences for the given library kind and status.
	///
	/// - Parameters:
	///    - preferences: The column preferences to persist.
	///    - libraryKind: The library kind the preferences apply to.
	///    - status: The library status the preferences apply to.
	static func setLibraryColumnPreferences(_ preferences: KKLibrary.ColumnPreferences, for libraryKind: KKLibrary.Kind, status: KKLibrary.Status) {
		guard let encoded = try? JSONEncoder().encode(preferences) else {
			return
		}

		var map = self.libraryColumnPreferencesMap
		map[self.libraryColumnPreferencesKey(for: libraryKind, status: status)] = encoded
		self.set(map, forKey: .libraryColumnPreferences)
	}

	/// The stored map of per-`(kind, status)` column preferences, encoded as JSON blobs.
	private static var libraryColumnPreferencesMap: [String: Data] {
		guard let stored = self.shared.dictionary(forKey: UserSettingsKey.libraryColumnPreferences.rawValue) as? [String: Data] else {
			return [:]
		}

		return stored
	}

	/// Returns the composite storage key used by the column-preferences map.
	///
	/// - Parameters:
	///    - libraryKind: The library kind to encode into the key.
	///    - status: The library status to encode into the key.
	/// - Returns: A string of the form `{libraryKind.urlPathName}.{status.sectionValue}`.
	private static func libraryColumnPreferencesKey(for libraryKind: KKLibrary.Kind, status: KKLibrary.Status) -> String {
		return "\(libraryKind.urlPathName).\(status.sectionValue)"
	}

	/// Returns the user's preferred compact-layout title visibility for the given library kind and status.
	///
	/// - Parameters:
	///    - libraryKind: The library kind whose preferred title visibility to look up.
	///    - status: The library status whose preferred title visibility to look up.
	///
	/// - Returns: The stored ``KKLibrary/CompactTitleVisibility`` for the given kind and status, or `.always` if none has been persisted.
	static func libraryCompactTitleVisibility(for libraryKind: KKLibrary.Kind, status: KKLibrary.Status) -> KKLibrary.CompactTitleVisibility {
		let rawValue = self.libraryCompactTitleVisibilities[self.libraryCompactTitleVisibilityKey(for: libraryKind, status: status)] ?? 0
		return KKLibrary.CompactTitleVisibility(rawValue: rawValue) ?? .always
	}

	/// Persists the user's preferred compact-layout title visibility for the given library kind and status.
	///
	/// - Parameters:
	///    - visibility: The compact title visibility to persist.
	///    - libraryKind: The library kind the visibility applies to.
	///    - status: The library status the visibility applies to.
	static func setLibraryCompactTitleVisibility(_ visibility: KKLibrary.CompactTitleVisibility, for libraryKind: KKLibrary.Kind, status: KKLibrary.Status) {
		var visibilities = self.libraryCompactTitleVisibilities
		visibilities[self.libraryCompactTitleVisibilityKey(for: libraryKind, status: status)] = visibility.rawValue
		self.set(visibilities, forKey: .libraryCompactTitleVisibilities)
	}

	/// The stored map of per-`(kind, status)` compact-layout title visibility preferences.
	private static var libraryCompactTitleVisibilities: [String: Int] {
		guard let stored = self.shared.dictionary(forKey: UserSettingsKey.libraryCompactTitleVisibilities.rawValue) as? [String: Int] else {
			return [:]
		}

		return stored
	}

	/// Returns the composite storage key used by the compact title-visibility preference map.
	///
	/// - Parameters:
	///    - libraryKind: The library kind to encode into the key.
	///    - status: The library status to encode into the key.
	///
	/// - Returns: A string of the form `"{libraryKind.urlPathName}.{status.sectionValue}"`.
	private static func libraryCompactTitleVisibilityKey(for libraryKind: KKLibrary.Kind, status: KKLibrary.Status) -> String {
		return "\(libraryKind.urlPathName).\(status.sectionValue)"
	}
}
