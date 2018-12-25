//
//  Array+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import Foundation

extension Array {
	public func append(contentsOf: [Element]?) {
		var matching = self
		guard let append = contentsOf else { return }
		for element in append {
			matching.append(element)
		}
	}
}
