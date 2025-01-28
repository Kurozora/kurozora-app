//
//  LanguageAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 13/07/2021.
//

extension Language {
	/// A root object that stores information about a single language, such as the language's name, and code.
	public struct Attributes: Codable, Sendable {
		// MARK: - Properties
		/// The name of the language.
		public let name: String

		/// The code of the language.
		public let code: String
	}
}
