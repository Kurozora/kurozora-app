//
//  KKLibraryKind+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/10/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

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
}
