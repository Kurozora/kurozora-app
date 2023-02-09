//
//  RelatedLiteratureResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/01/2023.
//

/// A root object that stores information about a collection of related literature.
public struct RelatedLiteratureResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a related literature object request.
	public let data: [RelatedLiterature]

	/// The realtive URL to the next page in the paginated response.
	public let next: String?
}
