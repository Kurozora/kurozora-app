//
//  Language.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 13/07/2021.
//

/// A root object that stores information about a language resource.
public struct Language: Codable, Hashable {
	// MARK: - Properties
	/// The language's name.
	public let name: String

	/// The language's ISO 639-2 code.
	public let code: String

	/// The language's ISO 639-3 code.
	public let iso6393: String

	// MARK: - Functions
	public static func == (lhs: Language, rhs: Language) -> Bool {
		return lhs.code == rhs.code
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.code)
	}
}
