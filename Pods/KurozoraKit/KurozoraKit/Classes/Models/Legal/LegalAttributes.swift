//
//  LegalAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 04/08/2020.
//

extension Legal {
	/// A root object that stores information about a single legal resource, such as the legal text.
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The text of the legal resource.
		public let text: String
	}
}
