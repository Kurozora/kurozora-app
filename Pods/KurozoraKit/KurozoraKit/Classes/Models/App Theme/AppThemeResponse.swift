//
//  AppThemeResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 04/08/2020.
//

/// A root object that stores information about a collection of app themes.
public struct AppThemeResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for an app theme object request.
	public let data: [AppTheme]
}
