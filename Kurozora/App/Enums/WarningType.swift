//
//  WarningType.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/12/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

/// Set of available warning types.
enum WarningType {
	// MARK: - Cases
	/// Indiates the app requires an update to be used.
	case forceUpdate

	/// Indiates the API is in maintenance mode.
	case maintenance

	/// Indiates the app cannot connect to the internet.
	case noSignal

	// MARK: - Properties
	/// The title value of a warning type.
	var title: String {
		switch self {
		case .forceUpdate:
			return Trans.forceUpdateTitle
		case .maintenance:
			return Trans.maintenanceModeTitle
		case .noSignal:
			return Trans.noSignalTitle
		}
	}

	/// The message value of a warning type.
	var message: String {
		switch self {
		case .forceUpdate:
			return Trans.forceUpdateMessage
		case .maintenance:
			return Trans.maintenanceModeMessage
		case .noSignal:
			return Trans.noSignalMessage
		}
	}

	/// The button title value of a warning type.
	var buttonTitle: String {
		switch self {
		case .forceUpdate:
			return Trans.update
		case .maintenance:
			return Trans.openTwitter
		case .noSignal:
			return Trans.reconnect
		}
	}

	/// The image value of a warning type.
	var image: UIImage? {
		switch self {
		case .forceUpdate:
            return .Icons.appStore
		case .maintenance:
            return .Icons.wrenchAndScrewdriverFill
		case .noSignal:
            return .Icons.noSignal
		}
	}
}
