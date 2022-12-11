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
	/// Sign up onboarding.
	case forceUpdate

	/// Sign up onboarding.
	case noSignal

	// MARK: - Properties
	/// The title value of a warning type.
	var title: String {
		switch self {
		case .forceUpdate:
			return Trans.forceUpdateTitle
		case .noSignal:
			return Trans.noSignalTitle
		}
	}

	/// The message value of a warning type.
	var message: String {
		switch self {
		case .forceUpdate:
			return Trans.forceUpdateMessage
		case .noSignal:
			return Trans.noSignalMessage
		}
	}

	/// The button title value of a warning type.
	var buttonTitle: String {
		switch self {
		case .forceUpdate:
			return Trans.update
		case .noSignal:
			return Trans.reconnect
		}
	}

	/// The image value of a warning type.
	var image: UIImage? {
		switch self {
		case .forceUpdate:
			return R.image.icons.appStore()
		case .noSignal:
			return R.image.icons.noSignal()
		}
	}
}
