//
//  LibraryImport.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 17/02/2020.
//

/// A root object that stores information about a single import request, such as the import's message status.
public struct LibraryImport: Codable, Sendable {
	// MARK: - Properties
	/// The status message of an import request.
	public var message: String?
}

// MARK: - Behavior
extension LibraryImport {
	/// The set of available Library import service types.
	public enum Service: Int, CaseIterable, Sendable {
		/// Indicates the imported file is from MyAnimeList.
		case mal = 0

		/// Indicates the imported file is from Kitsu.
		case kitsu = 1

		// MARK: - Properties
		/// The string value of a LibraryImport service type.
		public var stringValue: String {
			switch self {
			case .mal:
				return "MyAnimeList"
			case .kitsu:
				return "Kitsu"
			}
		}
	}

	/// The set of available Library import behavior types.
	public enum Behavior: Int, CaseIterable, Sendable {
		/// The import will overwrite any existing shows in the library.
		case overwrite = 0

		/// The import will merge any existing shows in the library with the import.
		case merge = 1

		// MARK: - Properties
		/// The string value of a LibraryImport behavior type.
		public var stringValue: String {
			switch self {
			case .overwrite:
				return "Overwrite"
			case .merge:
				return "Merge"
			}
		}
	}
}
