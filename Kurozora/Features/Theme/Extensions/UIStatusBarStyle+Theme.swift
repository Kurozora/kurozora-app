//
//  UIStatusBarStyle+Theme.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

extension UIStatusBarStyle {
	static func fromString(_ string: String) -> UIStatusBarStyle {
		switch string {
		case "LightContent":
			return .lightContent
		default:
			return .default
		}
	}
}
