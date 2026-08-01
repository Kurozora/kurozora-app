//
//  LibraryKind+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/10/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit

extension LibraryKind {
	// MARK: - Initializers
	/// Creates a library kind from a deep-link path component.
	///
	/// - Parameter pathComponent: The path component to parse.
	init?(pathComponent: String) {
		switch pathComponent.lowercased() {
		case "anime", "show", "shows":
			self = .shows
		case "manga", "literature", "literatures":
			self = .literatures
		case "game", "games":
			self = .games
		default:
			return nil
		}
	}

	/// An array containing the string value of all library kinds.
	static var allString: [String] {
		return self.allCases.map { libraryKind in
			return libraryKind.stringValue
		}
	}

	/// The url path name of a library kind.
	var urlPathName: String {
		switch self {
		case .shows:
			return "anime"
		case .literatures:
			return "manga"
		case .games:
			return "games"
		}
	}

	/// An array containing all `LibraryKind` key and value pairs.
	static var alertControllerItems: [(String, LibraryKind)] {
		var items = [(String, LibraryKind)]()
		for section in LibraryKind.allCases {
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
	/// - Returns: The stored `LibraryCellStyle` for the given kind and status, or `.detailed` if none has been persisted.
	static func libraryCellStyle(for libraryKind: LibraryKind, status: LibraryStatus) -> LibraryCellStyle {
		let rawValue = self.libraryCellStyles[self.libraryCellStyleKey(for: libraryKind, status: status)] ?? 0
		return LibraryCellStyle(rawValue: rawValue) ?? .detailed
	}

	/// Persists the user's preferred cell style for the given library kind and status.
	///
	/// - Parameters:
	///    - cellStyle: The cell style to persist.
	///    - libraryKind: The library kind the cell style applies to.
	///    - status: The library status the cell style applies to.
	static func setLibraryCellStyle(_ cellStyle: LibraryCellStyle, for libraryKind: LibraryKind, status: LibraryStatus) {
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
	private static func libraryCellStyleKey(for libraryKind: LibraryKind, status: LibraryStatus) -> String {
		return "\(libraryKind.urlPathName).\(status.sectionValue)"
	}

	/// Returns the user's column preferences for the given library kind and status.
	///
	/// Falls back to ``LibraryColumnPreferences/defaultShared`` when nothing has been
	/// persisted or decoding fails.
	///
	/// - Parameters:
	///    - libraryKind: The library kind whose column preferences to look up.
	///    - status: The library status whose column preferences to look up.
	/// - Returns: The stored ``LibraryColumnPreferences``, or the default.
	static func libraryColumnPreferences(for libraryKind: LibraryKind, status: LibraryStatus) -> LibraryColumnPreferences {
		let key = self.libraryColumnPreferencesKey(for: libraryKind, status: status)

		guard
			let blob = self.libraryColumnPreferencesMap[key],
			let decoded = try? JSONDecoder().decode(LibraryColumnPreferences.self, from: blob)
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
	static func setLibraryColumnPreferences(_ preferences: LibraryColumnPreferences, for libraryKind: LibraryKind, status: LibraryStatus) {
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
	private static func libraryColumnPreferencesKey(for libraryKind: LibraryKind, status: LibraryStatus) -> String {
		return "\(libraryKind.urlPathName).\(status.sectionValue)"
	}

	/// Returns the user's preferred compact-layout title visibility for the given library kind and status.
	///
	/// - Parameters:
	///    - libraryKind: The library kind whose preferred title visibility to look up.
	///    - status: The library status whose preferred title visibility to look up.
	///
	/// - Returns: The stored ``LibraryCompactTitleVisibility`` for the given kind and status, or `.always` if none has been persisted.
	static func libraryCompactTitleVisibility(for libraryKind: LibraryKind, status: LibraryStatus) -> LibraryCompactTitleVisibility {
		let rawValue = self.libraryCompactTitleVisibilities[self.libraryCompactTitleVisibilityKey(for: libraryKind, status: status)] ?? 0
		return LibraryCompactTitleVisibility(rawValue: rawValue) ?? .always
	}

	/// Persists the user's preferred compact-layout title visibility for the given library kind and status.
	///
	/// - Parameters:
	///    - visibility: The compact title visibility to persist.
	///    - libraryKind: The library kind the visibility applies to.
	///    - status: The library status the visibility applies to.
	static func setLibraryCompactTitleVisibility(_ visibility: LibraryCompactTitleVisibility, for libraryKind: LibraryKind, status: LibraryStatus) {
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
	private static func libraryCompactTitleVisibilityKey(for libraryKind: LibraryKind, status: LibraryStatus) -> String {
		return "\(libraryKind.urlPathName).\(status.sectionValue)"
	}
}
