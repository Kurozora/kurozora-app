//
//  KKLibraryStatus+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit

extension KKLibrary.Kind {
	/// An array containing the string value of all search scopes.
	static var allString: [String] {
		return self.allCases.map { libraryKind in
			return libraryKind.stringValue
		}
	}
}

extension KKLibrary.Status {
	/// The string value of a library status type for shows.
	var showStringValue: String {
		switch self {
		case .inProgress:
			return "Watching"
		default:
			return self.stringValue
		}
	}

	/// The string value of a library status type for literatures.
	var literatureStringValue: String {
		switch self {
		case .inProgress:
			return "Reading"
		default:
			return self.stringValue
		}
	}

	/// The string value of a library status type for games.
	var gameStringValue: String {
		switch self {
		case .inProgress:
			return "Playing"
		default:
			return self.stringValue
		}
	}

	/// An array containing all `KKLibrary.Status` key and value pairs.
	///
	/// - Parameters:
	///    - libraryKind: The type of library.
	static func alertControllerItems(for libraryKind: KKLibrary.Kind) -> [(String, KKLibrary.Status)] {
		var items = [(String, KKLibrary.Status)]()
		for section in KKLibrary.Status.all {
			switch libraryKind {
			case .shows:
				items.append((section.showStringValue, section))
			case .literatures:
				items.append((section.literatureStringValue, section))
//			case .games:
//				items.append((section.gameStringValue, section))
			}
		}
		return items
	}
}
