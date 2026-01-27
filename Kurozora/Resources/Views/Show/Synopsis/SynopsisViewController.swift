//
//  SynopsisViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/04/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class SynopsisViewController: KViewController {
	// MARK: - Views
	private var closeBarButtonItem: UIBarButtonItem!
	private var scrollView: UIScrollView!
	private var textView: KTextView!

	// MARK: - Properties
	var synopsis: String?

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = Trans.synopsis

		self.configureView()

		self.textView.text = self.synopsis
	}

	// MARK: - Functions
	private func configureView() {
		self.configureViews()
		self.configureViewHierarchy()
		self.configureViewConstraints()
	}

	private func configureViews() {
		self.configureNavigationItems()
		self.configureScrollView()
		self.configureTextView()
	}

	private func configureScrollView() {
		self.scrollView = UIScrollView()
		self.scrollView.translatesAutoresizingMaskIntoConstraints = false
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
		self.scrollView.addSubview(self.textView)
		self.view.addSubview(self.scrollView)
	}

	private func configureViewConstraints() {
		NSLayoutConstraint.activate([
			self.scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
			self.scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
			self.scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
			self.scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),

			self.textView.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor),
			self.textView.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
			self.textView.trailingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
			self.textView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor),
			self.textView.widthAnchor.constraint(equalTo: self.scrollView.frameLayoutGuide.widthAnchor, constant: -32)
		])
	}

	/// Configures the close bar button item.
	private func configureCloseBarButtonItem() {
		self.closeBarButtonItem = UIBarButtonItem(systemItem: .close, primaryAction: UIAction { [weak self] _ in
			guard let self = self else { return }
			self.dismiss(animated: true, completion: nil)
		})
		self.navigationItem.leftBarButtonItem = self.closeBarButtonItem
	}

	/// Configures the navigation items.
	private func configureNavigationItems() {
		self.configureCloseBarButtonItem()
	}
}
