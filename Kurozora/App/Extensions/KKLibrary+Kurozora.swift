//
//  KKLibraryKind+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/10/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import KurozoraKit

extension KKLibrary.Kind {
	/// An array containing all `KKLibrary.Kind` key and value pairs.
	static var alertControllerItems: [(String, KKLibrary.Kind)] {
		var items = [(String, KKLibrary.Kind)]()
		for section in KKLibrary.Kind.allCases {
			items.append((section.stringValue, section))
		}
		return items
	}
}
