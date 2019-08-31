//
//  SynopsisViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/04/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class SynopsisViewController: UIViewController {
	@IBOutlet weak var synopsisTextView: UITextView! {
		didSet {
			synopsisTextView.theme_textColor = KThemePicker.textColor.rawValue
		}
	}

	var synopsis: String?

	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		synopsisTextView.text = synopsis
	}

	// MARK: - IBActions
	@IBAction func dismissPressed(_ sender: AnyObject) {
		self.dismiss(animated: true, completion: nil)
	}
}
