//
//  PrivacyPolicys.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class PrivacyPolicy: JSONDecodable {
    let success: Bool?
	let privacyPolicy: PrivacyPolicyElement?

    required init(json: JSON) throws {
        self.success = json["success"].boolValue
		self.privacyPolicy = try? PrivacyPolicyElement(json: json["privacy_policy"])
    }
}

class PrivacyPolicyElement: JSONDecodable {
	let text: String?
	let lastUpdate: String?

	required init(json: JSON) throws {
		self.text = json["text"].stringValue
		self.lastUpdate = json["last_update"].stringValue
	}
}
