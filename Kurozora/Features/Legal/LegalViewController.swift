//
//  LegalViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class LegalViewController: KViewController {
	// MARK: - Views
	private var doneBarButtonItem: UIBarButtonItem!
	private var navigationTitleView: UIView!
	private var navigationTitleLabel: KLabel = {
		let label = KLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private var scrollView: UIScrollView!
	private var titleLabel: KLabel!
	private var textView: KTextView!

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		NotificationCenter.default.addObserver(self, selector: #selector(self.updatePrivacyPolicyTheme), name: .ThemeUpdateNotification, object: nil)

		self.configureView()

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
		self.textView.setAttributedText(privacyPolicy)
	}

	/// Updates the privacy policy text theme with the user's selected theme.
	@objc fileprivate func updatePrivacyPolicyTheme() {
		self.setPrivacyPolicy(self.textView.attributedText)
	}

	/// Configures the navigation title view.
	private func configureNavigationTitleView() {
		self.navigationTitleView = UIView()
		self.navigationTitleView.alpha = 0

		self.navigationTitleLabel.text = Trans.kurozoraAndPrivacy
		if #unavailable(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0) {
			self.navigationTitleLabel.theme_textColor = KThemePicker.barTitleTextColor.rawValue
		}

		// Layout
		self.navigationItem.titleView = self.navigationTitleView
		self.navigationTitleView.addSubview(self.navigationTitleLabel)

		NSLayoutConstraint.activate([
			self.navigationTitleLabel.topAnchor.constraint(equalTo: self.navigationTitleView.topAnchor),
			self.navigationTitleLabel.bottomAnchor.constraint(equalTo: self.navigationTitleView.bottomAnchor),
			self.navigationTitleLabel.leadingAnchor.constraint(equalTo: self.navigationTitleView.leadingAnchor),
			self.navigationTitleLabel.trailingAnchor.constraint(equalTo: self.navigationTitleView.trailingAnchor),
			self.navigationTitleLabel.centerXAnchor.constraint(equalTo: self.navigationTitleView.centerXAnchor),
			self.navigationTitleLabel.centerYAnchor.constraint(equalTo: self.navigationTitleView.centerYAnchor)
		])
	}

	/// Configures the done bar button item.
	private func configureDoneBarButtonItem() {
		self.doneBarButtonItem = UIBarButtonItem(systemItem: .done, primaryAction: UIAction { [weak self] _ in
			guard let self = self else { return }
			self.dismiss(animated: true, completion: nil)
		})

		self.navigationItem.rightBarButtonItem = self.doneBarButtonItem
	}

	/// Configures the navigation items.
	private func configureNavigationItems() {
		if #unavailable(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0) {
			self.navigationController?.navigationBar.isTranslucent = true
			self.navigationController?.navigationBar.theme_barTintColor = KThemePicker.barTintColor.rawValue
			self.navigationController?.navigationBar.backgroundColor = .clear
		}

		self.configureNavigationTitleView()
		self.configureDoneBarButtonItem()
	}

	private func configureView() {
		self.configureViews()
		self.configureViewHierarchy()
		self.configureViewConstraints()
	}

	private func configureViews() {
		self.configureNavigationItems()
		self.configureScrollView()
		self.configureTitleLabel()
		self.configureTextView()
	}

	private func configureScrollView() {
		self.scrollView = UIScrollView()
		self.scrollView.translatesAutoresizingMaskIntoConstraints = false
		self.scrollView.delegate = self
	}

	private func configureTitleLabel() {
		self.titleLabel = KLabel()
		self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
		self.titleLabel.text = Trans.kurozoraAndPrivacy
		self.titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
		self.titleLabel.textAlignment = .center
	}

	private func configureTextView() {
		self.textView = KTextView()
		self.textView.translatesAutoresizingMaskIntoConstraints = false
		self.textView.backgroundColor = nil
		self.textView.isScrollEnabled = false
		self.textView.isSelectable = true
		self.textView.isEditable = false
	}

	private func configureViewHierarchy() {
		self.scrollView.addSubview(self.titleLabel)
		self.scrollView.addSubview(self.textView)

		self.view.addSubview(self.scrollView)
	}

	private func configureViewConstraints() {
		NSLayoutConstraint.activate([
			self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
			self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
			self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),

			self.titleLabel.topAnchor.constraint(equalTo: self.scrollView.topAnchor, constant: 20),
			self.titleLabel.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
			self.titleLabel.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor),
			self.titleLabel.centerXAnchor.constraint(equalTo: self.scrollView.centerXAnchor),

			self.textView.topAnchor.constraint(equalToSystemSpacingBelow: self.titleLabel.bottomAnchor, multiplier: 1.0),
			self.textView.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
			self.textView.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor),
			self.textView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor, constant: 0),
		])
	}
}

// MARK: - UIScrollViewDelegate
extension LegalViewController: UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		guard let navigationBar = navigationController?.navigationBar else { return }

		// Convert the label's frame into navigation bar coordinates
		let labelFrameInNavBar = self.titleLabel.superview?
			.convert(self.titleLabel.frame, to: navigationBar) ?? .zero

		// If the label intersects or is above the nav bar, show titleView
		let isUnderNavigationBar = labelFrameInNavBar.maxY <= navigationBar.bounds.maxY

		if isUnderNavigationBar {
			UIView.animate(withDuration: 0.25) {
				self.titleLabel.alpha = 0
				self.navigationTitleView.alpha = 1
			}
		} else {
			UIView.animate(withDuration: 0.25) {
				self.navigationTitleView.alpha = 0
				self.titleLabel.alpha = 1
			}
		}
	}
}
