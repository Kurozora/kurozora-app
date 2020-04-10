//
//  KKSuccess.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 10/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

public class KKSuccess: JSONDecodable {
	// MARK: - Properties
	internal var success: Bool?
	public var message: String?

	// MARK: - Initializers
	required public init(json: JSON) {
		self.success = json["success"].boolValue
		self.message = json["error_message"].stringValue
	}
}
