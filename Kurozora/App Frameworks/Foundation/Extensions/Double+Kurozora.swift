//
//  Double+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/05/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import Foundation

extension Double {
	/// String without trailing zeros.
	var withoutTrailingZeros: String {
		return String(format: "%g", self)
	}
}
