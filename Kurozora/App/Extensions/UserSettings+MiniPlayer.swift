//
//  UserSettings+MiniPlayer.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

// The accessor lives app-side because the settings store is shared with the widget.
extension UserSettings {
	/// The conditions under which the MiniPlayer reveals its metadata and controls.
	static var miniPlayerChromeVisibility: MiniPlayerChromeVisibility {
		guard let visibility = MiniPlayerChromeVisibility(rawValue: self.shared.integer(forKey: UserSettingsKey.miniPlayerChromeVisibility.rawValue)) else { return .default }
		return visibility
	}
}
