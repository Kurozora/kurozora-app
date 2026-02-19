//
//  MediaActionBar.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/09/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit

enum MediaAction {
	case copy
	case share
	case save
	case more(UIMenu)
}

final class MediaActionBar: UIView {
	// MARK: - Views
	private(set) var stackView = UIStackView()

	// MARK: - Properties
	private let copyButton = CircularButton()
	let shareButton = CircularButton()
	private let saveButton = CircularButton()
	let moreButton = CircularButton()

	var onAction: ((MediaAction) -> Void)?

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.configureView()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.configureView()
	}

	// MARK: - Functions
	func configure(with actions: [MediaAction]) {
		// Reset stack
		self.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

		for action in actions {
			switch action {
			case .copy:
				self.stackView.addArrangedSubview(self.copyButton)
			case .share: self.stackView.addArrangedSubview(self.shareButton)
			case .save: self.stackView.addArrangedSubview(self.saveButton)
			case .more(let menu):
				self.moreButton.menu = menu
				self.moreButton.showsMenuAsPrimaryAction = true
				self.stackView.addArrangedSubview(self.moreButton)
			}
		}

		self.isHidden = actions.isEmpty
	}

	private func configureView() {
		self.configureViews()
		self.configureViewHierarchy()
		self.configureViewConstraints()
	}

	private func configureViews() {
		self.configureStackView()
		self.configureCopyButton()
		self.configureSaveButton()
		self.configureShareButton()
		self.configureMoreButton()
	}

	private func configureStackView() {
		self.stackView.translatesAutoresizingMaskIntoConstraints = false
		self.stackView.axis = .horizontal
		self.stackView.spacing = 16
		self.stackView.distribution = .equalSpacing
	}

	private func configureCopyButton() {
		self.copyButton.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
		self.copyButton.addTarget(self, action: #selector(self.copyTapped), for: .touchUpInside)

		if #unavailable(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0) {
			self.copyButton.backgroundColor = .black.withAlphaComponent(0.4)
		}
	}

	private func configureShareButton() {
		self.shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
		self.shareButton.addTarget(self, action: #selector(self.shareTapped), for: .touchUpInside)

		if #unavailable(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0) {
			self.shareButton.backgroundColor = .black.withAlphaComponent(0.4)
		}
	}

	private func configureSaveButton() {
		self.saveButton.setImage(UIImage(systemName: "tray.and.arrow.down"), for: .normal)
		self.saveButton.addTarget(self, action: #selector(self.saveTapped), for: .touchUpInside)

		if #unavailable(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0) {
			self.saveButton.backgroundColor = .black.withAlphaComponent(0.4)
		}
	}

	private func configureMoreButton() {
		self.moreButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)

		if #unavailable(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0) {
			self.moreButton.backgroundColor = .black.withAlphaComponent(0.4)
		}
	}

	private func configureViewHierarchy() {
		self.addSubview(self.stackView)
	}

	private func configureViewConstraints() {
		NSLayoutConstraint.activate([
			self.stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
			self.stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
			self.stackView.topAnchor.constraint(equalTo: topAnchor),
			self.stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
			self.stackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44.0),

			self.copyButton.widthAnchor.constraint(equalTo: self.copyButton.heightAnchor),
			self.shareButton.widthAnchor.constraint(equalTo: self.shareButton.heightAnchor),
			self.saveButton.widthAnchor.constraint(equalTo: self.saveButton.heightAnchor),
			self.moreButton.widthAnchor.constraint(equalTo: self.moreButton.heightAnchor)
		])
	}

	// MARK: - handlers
	@objc private func copyTapped() { self.onAction?(.copy) }
	@objc private func shareTapped() { self.onAction?(.share) }
	@objc private func saveTapped() { self.onAction?(.save) }
}
