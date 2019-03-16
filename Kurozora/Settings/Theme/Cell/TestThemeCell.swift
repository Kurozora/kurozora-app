//
//  TestThemeCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/02/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class TestThemeCell: UICollectionViewCell {
	@IBOutlet weak var button: UIButton!

	var themeElement: ThemesElement? {
		didSet {
			update()
		}
	}
	var row: Int!

	func update() {
		guard let themeElement = themeElement else { return }

		if let themeName = themeElement.name {
			button.setTitle(themeName, for: .normal)
		}

		if row == 0 {
			button.backgroundColor = #colorLiteral(red: 0.2174186409, green: 0.2404800057, blue: 0.332449615, alpha: 1)
			button.setTitleColor(#colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1),for: .normal)
			button.addTarget(self, action: #selector(tapDefault(_:)), for: .touchUpInside)
		} else if row == 1 {
			button.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.9568627451, alpha: 1)
			button.setTitleColor(#colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1),for: .normal)
			button.addTarget(self, action: #selector(tapDay(_:)), for: .touchUpInside)
		} else if row == 2 {
			button.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
			button.setTitleColor(#colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1),for: .normal)
			button.addTarget(self, action: #selector(tapNight(_:)), for: .touchUpInside)
		}
	}

	// MARK: - IBActions
	@objc func tapDefault(_ sender: AnyObject) {
		KurozoraThemes.switchTo(.default)
	}

	@objc func tapDay(_ sender: AnyObject) {
		KurozoraThemes.switchTo(.day)
	}

	@objc func tapNight(_ sender: AnyObject) {
		KurozoraThemes.switchTo(.night)
	}
}
