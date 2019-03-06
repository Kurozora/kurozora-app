//
//  LegalViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SCLAlertView

class LegalViewController: UIViewController {
	@IBOutlet weak var navigationTitleView: UIView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var privacyPolicyTextView: UITextView!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
	@IBOutlet weak var scrollView: UIScrollView!

	override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

	self.navigationController?.navigationBar.isTranslucent = true
		self.navigationController?.navigationBar.theme_barTintColor = "Global.barTintColor"
		self.navigationController?.navigationBar.backgroundColor = .clear

        Service.shared.getPrivacyPolicy(withSuccess: { (privacyPolicy) in
            if let privacyPolicyText = privacyPolicy?.text {
                self.privacyPolicyTextView.text = privacyPolicyText
            }
            
            if let lastUpdatedAt = privacyPolicy?.lastUpdate {
                self.lastUpdatedLabel.text = "Last updated at: \(lastUpdatedAt)"
            }
        })
		self.navigationTitleView.alpha = 0

		scrollView.delegate = self
    }

	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = "Global.backgroundColor"
		titleLabel.theme_textColor = "Global.textColor"
		privacyPolicyTextView.theme_textColor = "Global.textColor"
		lastUpdatedLabel.theme_textColor = "Global.textColor"
	}

	@IBAction func doneButtonPressed(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}
}

extension LegalViewController: UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let titleFrame = titleLabel.frame
		let container = CGRect(origin: scrollView.contentOffset, size: scrollView.frame.size)

		if (!container.intersects(titleFrame)) {
			if self.navigationTitleView.alpha == 0 {
				UIView.animate(withDuration: 0.5) {
					self.titleLabel.alpha = 0
					self.navigationTitleView.alpha = 1
				}
			}
		} else {
			if self.titleLabel.alpha == 0 {
				UIView.animate(withDuration: 0.5) {
					self.navigationTitleView.alpha = 0
					self.titleLabel.alpha = 1
				}
			}
		}
	}
}
