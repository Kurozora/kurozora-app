//
//  PrivacyPolicys.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

public class PrivacyPolicy: JSONDecodable {
    public let success: Bool?
	public let privacyPolicy: PrivacyPolicyElement?

    required public init(json: JSON) throws {
        self.success = json["success"].boolValue
		self.privacyPolicy = try? PrivacyPolicyElement(json: json["privacy_policy"])
    }
}

public class PrivacyPolicyElement: JSONDecodable {
	public let text: String?
	public let lastUpdate: String?

	required public init(json: JSON) throws {
		self.text = json["text"].stringValue
		self.lastUpdate = json["last_update"].stringValue
	}
}
