//
//  LibraryImportBehavior+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/01/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import KurozoraKit

extension LibraryImport.Behavior {
	/// An array containing all `LibraryImport.Behavior` key and value pairs.
	static var alertControllerItems: [(String, LibraryImport.Behavior)] {
		var items = [(String, LibraryImport.Behavior)]()
		for section in LibraryImport.Behavior.allCases {
			items.append((section.stringValue, section))
		}
		return items
	}
}
