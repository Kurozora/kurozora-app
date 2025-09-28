//
//  MediaActionBar.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/09/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit

// final class MediaActionBar: UIView {
//	// MARK: - Buttons
//	let shareButton = UIButton(type: .system)
//	let saveButton = UIButton(type: .system)
//	let moreButton = UIButton(type: .system)
//
//	override init(frame: CGRect) {
//		super.init(frame: frame)
//		self.setup()
//	}
//
//	@available(*, unavailable)
//	required init?(coder: NSCoder) { fatalError() }
//
//	private func setup() {
//		backgroundColor = UIColor.black.withAlphaComponent(0.4)
//		layer.cornerRadius = 12
//		layer.masksToBounds = true
//
//		let stack = UIStackView(arrangedSubviews: [
//			shareButton, saveButton, moreButton,
//		])
//		stack.axis = .horizontal
//		stack.distribution = .equalSpacing
//		stack.alignment = .center
//		stack.spacing = 16
//		stack.translatesAutoresizingMaskIntoConstraints = false
//		addSubview(stack)
//
//		NSLayoutConstraint.activate([
//			stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
//			stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
//			stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
//			stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
//		])
//
//		// Setup icons
//		self.shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
//		self.saveButton.setImage(UIImage(systemName: "square.and.arrow.down"), for: .normal)
//		self.moreButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
//
//		for item in [self.shareButton, self.saveButton, self.moreButton] {
//			item.tintColor = .white
//		}
//	}
// }

enum MediaAction {
	case copy
	case share
	case save
	case more(UIMenu)
}

final class MediaActionBar: UIView {
	private(set) var stackView = UIStackView()

	// Keep buttons private
	private let copyButton = UIButton(type: .system)
	let shareButton = UIButton(type: .system)
	private let saveButton = UIButton(type: .system)
	let moreButton = UIButton(type: .system)

	var onAction: ((MediaAction) -> Void)?

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setupUI()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setupUI()
	}

	private func setupUI() {
		self.stackView.axis = .horizontal
		self.stackView.spacing = 32
		self.stackView.distribution = .equalSpacing
		self.stackView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(self.stackView)

		NSLayoutConstraint.activate([
			self.stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
			self.stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
			self.stackView.topAnchor.constraint(equalTo: topAnchor),
			self.stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
		])

		// Assign button styles/icons
		self.copyButton.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
		self.shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
		self.saveButton.setImage(UIImage(systemName: "tray.and.arrow.down"), for: .normal)
		self.moreButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)

		self.copyButton.addTarget(self, action: #selector(self.copyTapped), for: .touchUpInside)
		self.shareButton.addTarget(self, action: #selector(self.shareTapped), for: .touchUpInside)
		self.saveButton.addTarget(self, action: #selector(self.saveTapped), for: .touchUpInside)
	}

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

	// MARK: - Button handlers
	@objc private func copyTapped() { self.onAction?(.copy) }
	@objc private func shareTapped() { self.onAction?(.share) }
	@objc private func saveTapped() { self.onAction?(.save) }
}
