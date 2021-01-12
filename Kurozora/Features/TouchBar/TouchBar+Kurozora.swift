//
//  TouchBar+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/12/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

#if targetEnvironment(macCatalyst)
extension NSTouchBarItem.Identifier {
	static let toggleShowIsFavorite = NSTouchBarItem.Identifier("com.kurozora.tracker.toggleShowIsFavorite")
	static let toggleShowIsReminded = NSTouchBarItem.Identifier("com.kurozora.tracker.toggleShowIsReminded")
}
#endif
