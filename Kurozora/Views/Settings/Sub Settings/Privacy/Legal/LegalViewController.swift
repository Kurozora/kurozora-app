//
//  LegalViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class LegalViewController: KViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var navigationTitleView: UIView!
	@IBOutlet weak var navigationTitleLabel: UILabel! {
		didSet {
			navigationTitleLabel.theme_textColor = KThemePicker.barTitleTextColor.rawValue
		}
	}

	@IBOutlet weak var titleLabel: KLabel!
	@IBOutlet weak var privacyPolicyTextView: UITextView! {
		didSet {
			privacyPolicyTextView.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var lastUpdatedLabel: KLabel!
	@IBOutlet weak var scrollView: UIScrollView!

	// MARK: - View
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.navigationController?.navigationBar.isTranslucent = true
		self.navigationController?.navigationBar.theme_barTintColor = KThemePicker.barTintColor.rawValue
		self.navigationController?.navigationBar.backgroundColor = .clear

		KService.getPrivacyPolicy { result in
			switch result {
			case .success(let privacyPolicy):
				if let privacyPolicyText = privacyPolicy.text {
					self.privacyPolicyTextView.text = privacyPolicyText
				}

				if let lastUpdatedAt = privacyPolicy.lastUpdate {
					self.lastUpdatedLabel.text = "Last updated at: \(lastUpdatedAt)"
				}
			case .failure: break
			}
		}
		self.navigationTitleView.alpha = 0

		scrollView.delegate = self
	}

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	// MARK: - IBActions
	@IBAction func doneButtonPressed(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}
}

// MARK: - UIScrollViewDelegate
extension LegalViewController: UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if !scrollView.bounds.contains(titleLabel.center) {
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
