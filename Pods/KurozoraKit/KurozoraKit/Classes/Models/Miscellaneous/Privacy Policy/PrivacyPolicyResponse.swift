//
//  PrivacyPolicyResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 09/09/2018.
//

/**
	A root object that stores information about a single privacy policy object.
*/
public struct PrivacyPolicyResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a privacy policy object request.
	public let data: PrivacyPolicy
}
