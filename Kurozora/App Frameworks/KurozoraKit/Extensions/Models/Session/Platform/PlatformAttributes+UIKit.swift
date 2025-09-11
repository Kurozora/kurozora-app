//
//  PlatformAttributes+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/07/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension Platform.Attributes {
	/// An image corresponding to the device model.
	var deviceImage: UIImage? {
		guard let deviceModel = self.deviceModel?.lowercased() else {
			return UIImage(systemName: "bolt.horizontal")
		}

		if deviceModel.contains("iphone") {
			return UIImage(systemName: "iphone")
		} else if deviceModel.contains("ipad") {
			return UIImage(systemName: "ipad.landscape")
		} else if deviceModel.contains("tv") {
			return UIImage(systemName: "appletv")
		} else if deviceModel.contains("mac") || deviceModel.contains("windows") || deviceModel.contains("linux") {
			return UIImage(systemName: "laptopcomputer")
		}

		return UIImage(systemName: "bolt.horizontal")
	}
}
