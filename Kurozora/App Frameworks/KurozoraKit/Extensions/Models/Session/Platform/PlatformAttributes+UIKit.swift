//
//  PlatformAttributes+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/07/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension Platform.Attributes {
	/// An image corresponding to the device model.
	var deviceImage: UIImage? {
		guard let deviceModel = self.deviceModel else {
			return UIImage(systemName: "bolt.horizontal")
		}

		if deviceModel.contains("iPhone", caseSensitive: false) {
			return UIImage(systemName: "iphone")
		} else if deviceModel.contains("iPad", caseSensitive: false) {
			return UIImage(systemName: "ipad.landscape")
		} else if deviceModel.contains("TV", caseSensitive: false) {
			return UIImage(systemName: "appletv")
		} else if deviceModel.contains("Mac", caseSensitive: false) {
			return UIImage(systemName: "laptopcomputer")
		}

		return UIImage(systemName: "bolt.horizontal")
	}
}
