//
//  ThemeCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import Kingfisher

class ThemeCell: UICollectionViewCell {
    @IBOutlet weak var themeScreenshot: UIImageView!
	@IBOutlet weak var titleLabel: UILabel! {
		didSet {
			titleLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var downloadCountLabel: UILabel! {
		didSet {
			downloadCountLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}
	@IBOutlet weak var buyButton: UIButton! {
		didSet {
			buyButton.theme_backgroundColor = KThemePicker.tintColor.rawValue
			buyButton.theme_setTitleColor(KThemePicker.tintedButtonTextColor.rawValue, forState: .normal)
		}
	}

	var row: Int!
	var themesElement: ThemesElement? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	fileprivate func configureCell() {
		guard let themesElement = themesElement else { return }
		titleLabel.text = themesElement.name

		if let downloadCount = themesElement.downloadCount {
			switch downloadCount {
			case 0:
				downloadCountLabel.text = ""
			case 1:
				downloadCountLabel.text = "\(downloadCount) Download"
			default:
				downloadCountLabel.text = "\(downloadCount.kFormatted) Downloads"
			}
		}

		if let themeBought = themesElement.userProfile?.themeBought {
			buyButton.setTitle((themeBought ? "" : "GET"), for: .normal)
		}

		if row == 0 {
			themeScreenshot.backgroundColor = #colorLiteral(red: 0.2174186409, green: 0.2404800057, blue: 0.332449615, alpha: 1)
			buyButton.addTarget(self, action: #selector(tapDefault(_:)), for: .touchUpInside)
		} else if row == 1 {
			themeScreenshot.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
			buyButton.addTarget(self, action: #selector(tapDay(_:)), for: .touchUpInside)
		} else if row == 2 {
			themeScreenshot.backgroundColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
			buyButton.addTarget(self, action: #selector(tapNight(_:)), for: .touchUpInside)
		} else {
			themeScreenshot.backgroundColor = UIColor.random
		}
	}

	@objc func tapDefault(_ sender: AnyObject) {
		KThemeStyle.switchTo(.default)
	}

	@objc func tapDay(_ sender: AnyObject) {
		KThemeStyle.switchTo(.day)
	}

	@objc func tapNight(_ sender: AnyObject) {
		KThemeStyle.switchTo(.night)
	}
}
