//
//  LibraryStatus+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit

extension LibraryStatus {
	/// The string value of a library status type for shows.
	var showStringValue: String {
		switch self {
		case .inProgress:
			return L10n.watching
		default:
			return self.stringValue
		}
	}

	/// The string value of a library status type for literatures.
	var literatureStringValue: String {
		switch self {
		case .inProgress:
			return L10n.reading
		default:
			return self.stringValue
		}
	}

	/// The string value of a library status type for games.
	var gameStringValue: String {
		switch self {
		case .inProgress:
			return L10n.playing
		default:
			return self.stringValue
		}
	}

	/// An array containing all `LibraryStatus` key and value pairs.
	///
	/// - Parameters:
	///    - libraryKind: The type of library.
	static func alertControllerItems(for libraryKind: LibraryKind) -> [(String, LibraryStatus)] {
		var items = [(String, LibraryStatus)]()
		for section in LibraryStatus.all {
			switch libraryKind {
			case .shows:
				items.append((section.showStringValue, section))
			case .literatures:
				items.append((section.literatureStringValue, section))
			case .games:
				items.append((section.gameStringValue, section))
			}
		}
		return items
	}
}
