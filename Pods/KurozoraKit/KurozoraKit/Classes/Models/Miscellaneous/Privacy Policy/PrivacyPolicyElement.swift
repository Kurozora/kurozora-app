//
//  PrivacyPolicyElement.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about a single privacy policy, such as the policy's text, and last updated date.
*/
public class PrivacyPolicyElement: JSONDecodable {
	// MARK: - Properties
	/// The text of the privacy policy.
	public let text: String?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.text = json["text"].stringValue
	}
}
