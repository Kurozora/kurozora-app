//
//  SynopsisViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/04/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import BottomPopup

class SynopsisViewController: BottomPopupViewController {
	@IBOutlet weak var synopsisTextView: UITextView! {
		didSet {
			synopsisTextView.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var grabberView: UIView! {
		didSet {
			grabberView.theme_backgroundColor = KThemePicker.separatorColor.rawValue
		}
	}

	var synopsis: String?

	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		synopsisTextView.text = synopsis
	}

	// Bottom popup delegate methods
	override func getPopupHeight() -> CGFloat {
		let height: CGFloat = UIScreen.main.bounds.size.height * 0.9
		return height
	}
}
