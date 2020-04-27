//
//  KKSuccess.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 10/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import SwiftyJSON
import TRON

/**
	An immutable object that stores information about a single successful request, such as the success message.
*/
public class KKSuccess: JSONDecodable {
	// MARK: - Properties
	/// The message of a successful request.
	public var message: String?

	// MARK: - Initializers
	required public init(json: JSON) {
		self.message = json["message"].stringValue
	}
}
