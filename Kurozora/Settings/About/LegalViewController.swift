//
//  LegalViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class LegalViewController: UIViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var navigationTitleView: UIView!
	@IBOutlet weak var navigationTitleLabel: UILabel! {
		didSet {
			navigationTitleLabel.theme_textColor = KThemePicker.barTitleTextColor.rawValue
		}
	}

	@IBOutlet weak var titleLabel: UILabel! {
		didSet {
			titleLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var privacyPolicyTextView: UITextView! {
		didSet {
			privacyPolicyTextView.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var lastUpdatedLabel: UILabel! {
		didSet {
			lastUpdatedLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var scrollView: UIScrollView!

	// MARK: - View
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.navigationController?.navigationBar.isTranslucent = true
		self.navigationController?.navigationBar.theme_barTintColor = KThemePicker.barTintColor.rawValue
		self.navigationController?.navigationBar.backgroundColor = .clear

		KService.shared.getPrivacyPolicy(withSuccess: { (privacyPolicy) in
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
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
	}

	// MARK: - Functions
	/**
		Instantiates and returns a view controller from the relevant storyboard.

		- Returns: a view controller from the relevant storyboard.
	*/
	static func instantiateFromStoryboard() -> UIViewController? {
		let storyboard = UIStoryboard(name: "about", bundle: nil)
		return storyboard.instantiateViewController(withIdentifier: "LegalViewController")
	}

	// MARK: - IBActions
	@IBAction func doneButtonPressed(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}
}

// MARK: - UIScrollViewDelegate
extension LegalViewController: UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let titleFrame = titleLabel.frame
		let container = CGRect(origin: scrollView.contentOffset, size: scrollView.frame.size)

		if !container.intersects(titleFrame) {
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
