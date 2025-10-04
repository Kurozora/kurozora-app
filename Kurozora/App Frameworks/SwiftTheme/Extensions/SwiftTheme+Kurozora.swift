//
//  SwiftTheme+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/10/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import SwiftTheme
import UIKit

extension ThemeVisualEffectPicker {
	convenience init(keyPath: String, vibrancyEnabled: Bool) {
		self.init(v: { ThemeVisualEffectPicker.getEffect(stringEffect: ThemeManager.string(for: keyPath) ?? "", vibrancyEnabled: vibrancyEnabled) })
	}

	class func getEffect(stringEffect: String, vibrancyEnabled: Bool = false) -> UIVisualEffect {
		var uiVisualEffect = UIBlurEffect()
		switch stringEffect.replacingOccurrences(of: "_", with: "").lowercased() {
		case "dark":
			uiVisualEffect = UIBlurEffect(style: .dark)
		case "extralight":
			uiVisualEffect = UIBlurEffect(style: .extraLight)
		case "prominent":
			if #available(iOS 10.0, *) {
				uiVisualEffect = UIBlurEffect(style: .prominent)
			} else {
				uiVisualEffect = UIBlurEffect(style: .light)
			}
		case "regular":
			if #available(iOS 10.0, *) {
				uiVisualEffect = UIBlurEffect(style: .regular)
			} else {
				uiVisualEffect = UIBlurEffect(style: .light)
			}
		default:
			uiVisualEffect = UIBlurEffect(style: .light)
		}
		return vibrancyEnabled ? UIVibrancyEffect(blurEffect: uiVisualEffect) : uiVisualEffect
	}
}
