//
//  LanguageResponse.swift
//  Alamofire
//
//  Created by Khoren Katklian on 13/07/2021.
//

/// A root object that stores information about a collection of languages.
public struct LanguageResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a language object request.
	public let data: [Language]
}
