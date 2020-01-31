//
//  DarkThemeOption.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

/**
	List of dark theme options.

	```
	case automatic = 0
	case custom = 1
	```
*/
enum DarkThemeOption: Int {
	/// The app switches between dark and light theme at sunset and sunrise.
	case automatic	= 0

	/// The app switches between dark and light theme at a custom time specified by the user.
	case custom
}
