//
//  Motion.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/12/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import Foundation

enum Motion {
	enum Section: Int, CaseIterable {
		// MARK: Cases
		case animations
		case reduceMotion

		// MARK: Properties
		/// The title of a section type.
		var titleValue: String {
			switch self {
			case .animations:
				return Trans.animations
			case .reduceMotion:
				return Trans.reduceMotion
			}
		}

		/// The rows of a section type.
		var rows: [Motion.Row] {
			switch self {
			case .animations:
				return [.splashScreen]
			case .reduceMotion:
				return [.toggleReduceMotion, .toggleReduceMotionSync]
			}
		}
	}

	enum Row: Int, CaseIterable {
		// MARK: Cases
		case splashScreen
		case toggleReduceMotion
		case toggleReduceMotionSync

		// MARK: Properties
		var titleValue: String {
			switch self {
			case .splashScreen:
				return Trans.splashScreen
			case .toggleReduceMotion:
				return Trans.reduceMotion
			case .toggleReduceMotionSync:
				return Trans.syncWithDeviceSettings
			}
		}
	}
}
