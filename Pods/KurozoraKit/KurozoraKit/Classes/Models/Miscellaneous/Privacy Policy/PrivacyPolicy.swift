//
//  PrivacyPolicy.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

/**
	A root object that stores information about a privacy policy resource.
*/
public struct PrivacyPolicy: Codable {
	// MARK: - Properties
	/// The type of the privacy policy.
	public let type: String

	/// The relative link to where the privacy policy is located.
	public let href: String

	/// The attributes belonging to the privacy policy.
	public let attributes: PrivacyPolicy.Attributes
}
