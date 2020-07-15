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
	@IBOutlet weak var privacyPolicyTextView: KTextView!
	@IBOutlet weak var scrollView: UIScrollView!

	// MARK: - Initializers
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		DispatchQueue.global(qos: .background).async {
			self.fetchData()
		}
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		DispatchQueue.global(qos: .background).async {
			self.fetchData()
		}
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		NotificationCenter.default.addObserver(self, selector: #selector(updatePrivacyPolicyTheme), name: .ThemeUpdateNotification, object: nil)

		self.navigationController?.navigationBar.isTranslucent = true
		self.navigationController?.navigationBar.theme_barTintColor = KThemePicker.barTintColor.rawValue
		self.navigationController?.navigationBar.backgroundColor = .clear

		self.navigationTitleView.alpha = 0

		scrollView.delegate = self
	}

	// MARK: - Functions
	/// Makes an API request to fetch the relevant data for the view.
	func fetchData() {
		KService.getPrivacyPolicy { result in
			switch result {
			case .success(let privacyPolicy):
				if let privacyPolicyText = privacyPolicy.text {
					self.privacyPolicyTextView.attributedText = privacyPolicyText.htmlAttributedString()?.colored(with: KThemePicker.textColor.colorValue)
				}
			case .failure: break
			}
		}
	}

	/// Updates the privacy policy text theme with the user's selected theme.
	@objc fileprivate func updatePrivacyPolicyTheme() {
		self.privacyPolicyTextView.attributedText = self.privacyPolicyTextView.attributedText.colored(with: KThemePicker.textColor.colorValue)
	}

	// MARK: - IBActions
	@IBAction func doneButtonPressed(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}
}

// MARK: - UIScrollViewDelegate
extension LegalViewController: UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if !scrollView.bounds.contains(titleLabel.frame.origin) {
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
