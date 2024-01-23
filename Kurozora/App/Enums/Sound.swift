//
//  Sound.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/12/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import Foundation

enum Sound {
	enum Section: Int, CaseIterable {
		// MARK: Cases
		case main
	}

	enum Row: Int, CaseIterable {
		// MARK: Cases
		case selectChime
		case toggleChime
		case toggleUISounds
		case toggleHaptics

		static var settingsCases: [Sound.Row] {
			#if targetEnvironment(macCatalyst)
			return [.selectChime, .toggleChime, .toggleUISounds]
			#else
			return [.selectChime, .toggleChime, .toggleUISounds, .toggleHaptics]
			#endif
		}

		// MARK: Properties
		var titleValue: String {
			switch self {
			case .selectChime:
				return Trans.chimeSound
			case .toggleChime:
				return Trans.chimeOnStartup
			case .toggleUISounds:
				return Trans.uiSounds
			case .toggleHaptics:
				return Trans.haptics
			}
		}
	}
}
