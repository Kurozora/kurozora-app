//
//  LibraryImportService+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/01/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import KurozoraKit

extension LibraryImport.Service {
	/// An array containing all `LibraryImport.Service` key and value pairs.
	static var alertControllerItems: [(String, LibraryImport.Service)] {
		var items = [(String, LibraryImport.Service)]()
		for section in LibraryImport.Service.allCases {
			items.append((section.stringValue, section))
		}
		return items
	}
}
