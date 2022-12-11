//
//  WarningModels.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/12/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

enum Warning {
	enum ConfigureView {
		struct Request { }

		struct Response {
			let warningType: WarningType
		}

		struct ViewModel {
			let warningType: WarningType
		}
	}

	enum ActionButtonPressed {
		struct Request { }

		struct Response {
			let window: UIWindow?
			let warningType: WarningType
		}

		struct ViewModel {
			let window: UIWindow?
			let warningType: WarningType
		}
	}
}
