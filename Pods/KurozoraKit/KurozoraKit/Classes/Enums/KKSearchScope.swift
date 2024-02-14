//
//  KKSearchScope.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 07/06/2022.
//

/// The list of available search scopes.
///
/// - `kurozora`: searches in the Kurozora catalog.
/// - `library`: searches in the user's library.
///
/// - Tag: KKSearchScope
public enum KKSearchScope: Int, CaseIterable {
	// MARK: - Cases
	/// Searches in the Kurozora catalog.
	///
	/// - Tag: KKSearchScope-kurozora
	case kurozora = 0

	/// Searches in the user's library list.
	///
	/// - Tag: KKSearchScope-library
	case library

	// MARK: - Properties
	/// The query value of a search scope.
	internal var queryValue: String {
		switch self {
		case .kurozora:
			return "kurozora"
		case .library:
			return "library"
		}
	}
}
