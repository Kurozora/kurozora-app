//
//  MALImport.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/02/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about a single import request, such as the import's message status.
*/
public class MALImport: JSONDecodable {
	// MARK: - Properties
	/// The status message of an import request.
	public var message: String?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.message = json["message"].stringValue
	}
}

// MARK: - Behavior
extension MALImport {
	/**
		The set of available MAL import behavior types.

		```
		case overwrite = 0
		```
	*/
	public enum Behavior: Int {
		/// The import will overwrite any existing shows in the library.
		case overwrite = 0

		// MARK: - Properties
		/// The string value of a MALImport behavior type.
		var stringValue: String {
			switch self {
			case .overwrite:
				return "overwrite"
			}
		}
	}
}
