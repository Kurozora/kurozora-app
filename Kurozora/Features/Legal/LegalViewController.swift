//
//  LegalViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class LegalViewController: KViewController, StoryboardInstantiable {
	static var storyboardName: String = "Legal"

	// MARK: - IBOutlets
	@IBOutlet weak var navigationTitleView: UIView!
	@IBOutlet weak var navigationTitleLabel: UILabel! {
		didSet {
			self.navigationTitleLabel.theme_textColor = KThemePicker.barTitleTextColor.rawValue
		}
	}

	@IBOutlet weak var titleLabel: KLabel!
	@IBOutlet weak var privacyPolicyTextView: KTextView!
	@IBOutlet weak var scrollView: UIScrollView!

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		NotificationCenter.default.addObserver(self, selector: #selector(updatePrivacyPolicyTheme), name: .ThemeUpdateNotification, object: nil)

		self.navigationController?.navigationBar.isTranslucent = true
		self.navigationController?.navigationBar.theme_barTintColor = KThemePicker.barTintColor.rawValue
		self.navigationController?.navigationBar.backgroundColor = .clear

		self.navigationTitleView.alpha = 0

		self.scrollView.delegate = self

        Task { [weak self] in
            guard let self = self else { return }
            await self.fetchData()
        }
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.navigationController?.navigationBar.prefersLargeTitles = false
	}

	// MARK: - Functions
	/// Makes an API request to fetch the relevant data for the view.
	func fetchData() async {
		do {
			let legalResponse = try await KService.getPrivacyPolicy().value
			self.setPrivacyPolicy(legalResponse.data.attributes.text.htmlAttributedString())
		} catch {
			print(error.localizedDescription)
		}
	}

	func setPrivacyPolicy(_ privacyPolicy: NSAttributedString?) {
		self.privacyPolicyTextView.setAttributedText(privacyPolicy)
	}

	/// Updates the privacy policy text theme with the user's selected theme.
	@objc fileprivate func updatePrivacyPolicyTheme() {
		self.setPrivacyPolicy(self.privacyPolicyTextView.attributedText)
	}

	// MARK: - IBActions
	@IBAction func doneButtonPressed(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}
}

// MARK: - UIScrollViewDelegate
extension LegalViewController: UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let titleLabelPositionToNavigationBar = titleLabel.superview?.convert(titleLabel.frame.origin, to: navigationController?.navigationBar) ?? .zero

		if titleLabelPositionToNavigationBar.y <= titleLabel.frame.origin.y / 2 {
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
