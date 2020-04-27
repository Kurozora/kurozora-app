//
//  PrivacyPolicys.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import SwiftyJSON
import TRON

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
