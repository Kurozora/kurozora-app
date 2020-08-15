//
//  PrivacyPolicyAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 04/08/2020.
//

extension PrivacyPolicy {
	/**
		A root object that stores information about a single privacy policy, such as the policy's text.
	*/
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The text of the privacy policy.
		public let text: String
	}
}
