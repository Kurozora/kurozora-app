//
//  KKLibraryStatus+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit

extension KKLibrary.Status {
	/// The section value string of a library section.
	var sectionValue: String {
		switch self {
		case .onHold:
			return "OnHold"
		default:
			return self.stringValue
		}
	}

	/// An array containing all library section string value and its equivalent section value.
	static var alertControllerItems: [(String, KKLibrary.Status)] {
		var items = [(String, KKLibrary.Status)]()
		for section in KKLibrary.Status.all {
			items.append((section.stringValue, section))
		}
		return items
	}
}
