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
	/// Indicates the app requires an update to be used.
	case forceUpdate

	/// Indicates the API is in maintenance mode.
	case maintenance

	/// Indicates the app cannot connect to the internet.
	case noSignal

	// MARK: - Properties
	/// The title value of a warning type.
	var title: String {
		switch self {
		case .forceUpdate:
			return L10n.forceUpdateTitle
		case .maintenance:
			return L10n.maintenanceModeTitle
		case .noSignal:
			return L10n.noSignalTitle
		}
	}

	/// The message value of a warning type.
	var message: String {
		switch self {
		case .forceUpdate:
			return L10n.forceUpdateMessage
		case .maintenance:
			return L10n.maintenanceModeMessage
		case .noSignal:
			return L10n.noSignalMessage
		}
	}

	/// The button title value of a warning type.
	var buttonTitle: String {
		switch self {
		case .forceUpdate:
			return L10n.update
		case .maintenance:
			return L10n.openTwitter
		case .noSignal:
			return L10n.reconnect
		}
	}

	/// The image value of a warning type.
	var image: UIImage? {
		switch self {
		case .forceUpdate:
			return .Icons.Brands.appStore
		case .maintenance:
            return .Icons.wrenchAndScrewdriverFill
		case .noSignal:
            return .Icons.wifiExclamationmark
		}
	}
}
