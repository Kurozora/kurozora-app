//
//  PrivacyPolicys.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

/**
	A mutable object that stores information about a single privacy policy object.
*/
public class PrivacyPolicy: JSONDecodable {
	// MARK: - Properties
	/// The single privacy policy object.
	public let privacyPolicy: PrivacyPolicyElement?

	// MARK: - Initializers
    required public init(json: JSON) throws {
		self.privacyPolicy = try? PrivacyPolicyElement(json: json["privacy_policy"])
    }
}

/**
	A mutable object that stores information about a single privacy policy, such as the policy's text, and last updated date.
*/
public class PrivacyPolicyElement: JSONDecodable {
	// MARK: - Properties
	/// The text of the privacy policy.
	public let text: String?

	/// The alst updated date of the privavcy policy.
	public let lastUpdate: String?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.text = json["text"].stringValue
		self.lastUpdate = json["last_update"].stringValue
	}
}
