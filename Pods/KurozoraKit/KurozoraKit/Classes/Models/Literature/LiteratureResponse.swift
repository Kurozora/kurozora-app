//
//  LiteratureResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/01/2023.
//

/// A root object that stores information about a collection of literature.
public struct LiteratureResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a literature object request.
	public let data: [Literature]

	/// The realtive URL to the next page in the paginated response.
	public let next: String?
}
