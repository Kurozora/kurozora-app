//
//  LegalResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 09/09/2018.
//

/**
	A root object that stores information about a single legal object.
*/
public struct LegalResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a legal object request.
	public let data: Legal
}
