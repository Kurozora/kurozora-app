//
//  TwoFactorToggleTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

protocol TwoFactorToggleTableViewCellDelegate: AnyObject {
	func twoFactorToggleDidTapToggle()
}

final class TwoFactorToggleTableViewCell: UITableViewCell {
	// MARK: - Properties
	private weak var delegate: TwoFactorToggleTableViewCellDelegate?

	private let toggleButton: KButton = {
		let button = KButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		let bodyPointSize = UIFont.preferredFont(forTextStyle: .body).pointSize
		button.titleLabel?.font = .systemFont(ofSize: bodyPointSize, weight: .semibold)
		return button
	}()

	// MARK: - Initializers
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.selectionStyle = .none
		self.backgroundColor = .clear
		self.contentView.backgroundColor = .clear
		self.setupLayout()
		self.toggleButton.addTarget(self, action: #selector(self.toggleTapped), for: .touchUpInside)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) is not supported")
	}

	// MARK: - Functions
	private func setupLayout() {
		self.contentView.addSubview(self.toggleButton)

		NSLayoutConstraint.activate([
			self.toggleButton.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),
			self.toggleButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10),
			self.toggleButton.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
			self.toggleButton.leadingAnchor.constraint(greaterThanOrEqualTo: self.contentView.layoutMarginsGuide.leadingAnchor),
			self.toggleButton.trailingAnchor.constraint(lessThanOrEqualTo: self.contentView.layoutMarginsGuide.trailingAnchor)
		])
	}

	func configure(title: String, delegate: TwoFactorToggleTableViewCellDelegate) {
		self.toggleButton.setTitle(title, for: .normal)
		self.delegate = delegate
	}

	// MARK: - Actions
	@objc private func toggleTapped() {
		self.delegate?.twoFactorToggleDidTapToggle()
	}
}
