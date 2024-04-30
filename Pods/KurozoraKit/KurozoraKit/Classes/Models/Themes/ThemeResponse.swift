//
//  ThemeResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 09/08/2020.
//

/// A root object that stores information about a collection of themes.
public struct ThemeResponse: Codable {
	// MARK: - Properties
	/// The data included in the response for a theme object request.
	public let data: [Theme]
}
