//
//  KFMReplyTextEditorView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

final class KFMReplyTextEditorView: KView, KFeedMessageTextEditorViewProviding {
	let profileImageView = ProfileImageView(frame: .zero)
	let currentUsernameLabel = KLabel()
	let characterCountLabel = KSecondaryLabel()
	let commentTextView = KTextView()
	let commentPreviewContainer = UIView()
	let labelsButton = KButton()

	let opProfileImageView = ProfileImageView(frame: .zero)
	let opUsernameLabel = KLabel()
	let opMessageTextView = KSelectableTextView()
	let opDateTimeLabel = KSecondaryLabel()
	let opMessagePreviewContainer = UIView()

	private let scrollView = UIScrollView()
	private let scrollContentView = UIView()
	private let separatorView = SecondarySeparatorView()
	private let footerView = KView()
	private let footerSeparatorView = SecondarySeparatorView()
	private let footerStackView = UIStackView()
	private let footerSpacerView = UIView()

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.configure()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.configure()
	}
}

// MARK: - Configuration
private extension KFMReplyTextEditorView {
	func configure() {
		self.configureView()
		self.configureScrollView()
		self.configureOPMessagePreviewContainer()
		self.configureOPProfileImageView()
		self.configureOPUsernameLabel()
		self.configureOPDateTimeLabel()
		self.configureOPMessageTextView()
		self.configureSeparatorView()
		self.configureCommentPreviewContainer()
		self.configureProfileImageView()
		self.configureCurrentUsernameLabel()
		self.configureCharacterCountLabel()
		self.configureCommentTextView()
		self.configureFooterView()
		self.configureFooterSeparatorView()
		self.configureFooterStackView()
		self.configureLabelsButton()
		self.configureViewHierarchy()
		self.configureConstraints()
	}

	func configureView() {
		self.layoutMargins = .zero
	}

	func configureScrollView() {
		self.scrollView.translatesAutoresizingMaskIntoConstraints = false
		self.scrollView.showsHorizontalScrollIndicator = false
		self.scrollView.alwaysBounceVertical = true
		self.scrollContentView.translatesAutoresizingMaskIntoConstraints = false
	}

	func configureOPMessagePreviewContainer() {
		self.opMessagePreviewContainer.translatesAutoresizingMaskIntoConstraints = false
		self.opMessagePreviewContainer.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8)
		self.opMessagePreviewContainer.layerCornerRadius = 10
	}

	func configureOPProfileImageView() {
		self.opProfileImageView.translatesAutoresizingMaskIntoConstraints = false
		self.opProfileImageView.contentMode = .scaleAspectFill
	}

	func configureOPUsernameLabel() {
		self.opUsernameLabel.translatesAutoresizingMaskIntoConstraints = false
		self.opUsernameLabel.font = .preferredFont(forTextStyle: .headline)
		self.opUsernameLabel.lineBreakMode = .byTruncatingTail
		self.opUsernameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
	}

	func configureOPDateTimeLabel() {
		self.opDateTimeLabel.translatesAutoresizingMaskIntoConstraints = false
		self.opDateTimeLabel.font = .preferredFont(forTextStyle: .footnote)
		self.opDateTimeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
		self.opDateTimeLabel.setContentHuggingPriority(.required, for: .horizontal)
	}

	func configureOPMessageTextView() {
		self.opMessageTextView.translatesAutoresizingMaskIntoConstraints = false
		self.opMessageTextView.isScrollEnabled = false
		self.opMessageTextView.showsHorizontalScrollIndicator = false
		self.opMessageTextView.showsVerticalScrollIndicator = false
		self.opMessageTextView.bounces = false
		self.opMessageTextView.bouncesZoom = false
		self.opMessageTextView.font = .preferredFont(forTextStyle: .body)
	}

	func configureSeparatorView() {
		self.separatorView.translatesAutoresizingMaskIntoConstraints = false
	}

	func configureCommentPreviewContainer() {
		self.commentPreviewContainer.translatesAutoresizingMaskIntoConstraints = false
		self.commentPreviewContainer.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8)
		self.commentPreviewContainer.layerCornerRadius = 10
	}

	func configureProfileImageView() {
		self.profileImageView.translatesAutoresizingMaskIntoConstraints = false
		self.profileImageView.contentMode = .scaleAspectFill
	}

	func configureCurrentUsernameLabel() {
		self.currentUsernameLabel.translatesAutoresizingMaskIntoConstraints = false
		self.currentUsernameLabel.font = .preferredFont(forTextStyle: .headline)
		self.currentUsernameLabel.lineBreakMode = .byTruncatingTail
		self.currentUsernameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
	}

	func configureCharacterCountLabel() {
		self.characterCountLabel.translatesAutoresizingMaskIntoConstraints = false
		self.characterCountLabel.font = .preferredFont(forTextStyle: .footnote)
		self.characterCountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
		self.characterCountLabel.setContentHuggingPriority(.required, for: .horizontal)
	}

	func configureCommentTextView() {
		self.commentTextView.translatesAutoresizingMaskIntoConstraints = false
		self.commentTextView.alwaysBounceVertical = true
		self.commentTextView.isScrollEnabled = false
		self.commentTextView.showsHorizontalScrollIndicator = false
		self.commentTextView.showsVerticalScrollIndicator = false
		self.commentTextView.bouncesZoom = false
		self.commentTextView.font = .preferredFont(forTextStyle: .body)
		self.commentTextView.autocapitalizationType = .sentences
		self.commentTextView.keyboardType = .twitter
	}

	func configureFooterView() {
		self.footerView.translatesAutoresizingMaskIntoConstraints = false
	}

	func configureFooterSeparatorView() {
		self.footerSeparatorView.translatesAutoresizingMaskIntoConstraints = false
	}

	func configureFooterStackView() {
		self.footerStackView.translatesAutoresizingMaskIntoConstraints = false
		self.footerStackView.axis = .horizontal
		self.footerStackView.alignment = .fill
		self.footerStackView.distribution = .fill
		self.footerStackView.spacing = 8
	}

	func configureLabelsButton() {
		self.labelsButton.translatesAutoresizingMaskIntoConstraints = false
		self.labelsButton.contentHorizontalAlignment = .leading
		self.labelsButton.titleLabel?.font = .preferredFont(forTextStyle: .subheadline)

		var configuration = UIButton.Configuration.plain()
		configuration.title = "Labels"
		configuration.image = UIImage(systemName: "shield")
		configuration.imagePlacement = .leading
		configuration.imagePadding = 6
		configuration.contentInsets = .zero
		self.labelsButton.configuration = configuration
	}

	func configureViewHierarchy() {
		self.addSubview(self.scrollView)
		self.addSubview(self.footerView)

		self.scrollView.addSubview(self.scrollContentView)
		self.scrollContentView.addSubview(self.opMessagePreviewContainer)
		self.scrollContentView.addSubview(self.separatorView)
		self.scrollContentView.addSubview(self.commentPreviewContainer)

		self.opMessagePreviewContainer.addSubview(self.opProfileImageView)
		self.opMessagePreviewContainer.addSubview(self.opUsernameLabel)
		self.opMessagePreviewContainer.addSubview(self.opDateTimeLabel)
		self.opMessagePreviewContainer.addSubview(self.opMessageTextView)

		self.commentPreviewContainer.addSubview(self.profileImageView)
		self.commentPreviewContainer.addSubview(self.currentUsernameLabel)
		self.commentPreviewContainer.addSubview(self.characterCountLabel)
		self.commentPreviewContainer.addSubview(self.commentTextView)

		self.footerView.addSubview(self.footerSeparatorView)
		self.footerView.addSubview(self.footerStackView)

		self.footerStackView.addArrangedSubview(self.labelsButton)
		self.footerStackView.addArrangedSubview(self.footerSpacerView)
	}

	func configureConstraints() {
		NSLayoutConstraint.activate([
			self.scrollView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
			self.scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.scrollView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),

			self.scrollContentView.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor),
			self.scrollContentView.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leadingAnchor),
			self.scrollContentView.trailingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.trailingAnchor),
			self.scrollContentView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor),
			self.scrollContentView.widthAnchor.constraint(equalTo: self.scrollView.frameLayoutGuide.widthAnchor),

			self.opMessagePreviewContainer.topAnchor.constraint(equalTo: self.scrollContentView.topAnchor, constant: 20),
			self.opMessagePreviewContainer.leadingAnchor.constraint(equalTo: self.scrollContentView.leadingAnchor, constant: 18),
			self.opMessagePreviewContainer.trailingAnchor.constraint(equalTo: self.scrollContentView.trailingAnchor, constant: -18),

			self.separatorView.topAnchor.constraint(equalTo: self.opMessagePreviewContainer.bottomAnchor),
			self.separatorView.leadingAnchor.constraint(equalTo: self.scrollContentView.leadingAnchor, constant: 8),
			self.separatorView.trailingAnchor.constraint(equalTo: self.scrollContentView.trailingAnchor, constant: -8),
			self.separatorView.heightAnchor.constraint(equalToConstant: 1),

			self.commentPreviewContainer.topAnchor.constraint(equalTo: self.separatorView.bottomAnchor, constant: 8),
			self.commentPreviewContainer.leadingAnchor.constraint(equalTo: self.scrollContentView.leadingAnchor, constant: 18),
			self.commentPreviewContainer.trailingAnchor.constraint(equalTo: self.scrollContentView.trailingAnchor, constant: -18),
			self.commentPreviewContainer.bottomAnchor.constraint(equalTo: self.scrollContentView.bottomAnchor, constant: -20),

			self.opProfileImageView.topAnchor.constraint(equalTo: self.opMessagePreviewContainer.layoutMarginsGuide.topAnchor),
			self.opProfileImageView.leadingAnchor.constraint(equalTo: self.opMessagePreviewContainer.layoutMarginsGuide.leadingAnchor),
			self.opProfileImageView.widthAnchor.constraint(equalToConstant: 44),
			self.opProfileImageView.heightAnchor.constraint(equalToConstant: 44),

			self.opUsernameLabel.topAnchor.constraint(equalTo: self.opMessagePreviewContainer.layoutMarginsGuide.topAnchor),
			self.opUsernameLabel.leadingAnchor.constraint(equalTo: self.opProfileImageView.trailingAnchor, constant: 8),

			self.opDateTimeLabel.topAnchor.constraint(equalTo: self.opUsernameLabel.topAnchor),
			self.opDateTimeLabel.centerYAnchor.constraint(equalTo: self.opUsernameLabel.centerYAnchor),
			self.opDateTimeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.opUsernameLabel.trailingAnchor, constant: 10),
			self.opDateTimeLabel.trailingAnchor.constraint(equalTo: self.opMessagePreviewContainer.layoutMarginsGuide.trailingAnchor),

			self.opMessageTextView.topAnchor.constraint(equalTo: self.opUsernameLabel.bottomAnchor),
			self.opMessageTextView.leadingAnchor.constraint(equalTo: self.opUsernameLabel.leadingAnchor),
			self.opMessageTextView.trailingAnchor.constraint(equalTo: self.opMessagePreviewContainer.layoutMarginsGuide.trailingAnchor),
			self.opMessageTextView.bottomAnchor.constraint(equalTo: self.opMessagePreviewContainer.bottomAnchor, constant: -20),

			self.opMessagePreviewContainer.bottomAnchor.constraint(greaterThanOrEqualTo: self.opProfileImageView.bottomAnchor, constant: 20),

			self.profileImageView.topAnchor.constraint(equalTo: self.commentPreviewContainer.layoutMarginsGuide.topAnchor),
			self.profileImageView.leadingAnchor.constraint(equalTo: self.commentPreviewContainer.layoutMarginsGuide.leadingAnchor),
			self.profileImageView.widthAnchor.constraint(equalToConstant: 44),
			self.profileImageView.heightAnchor.constraint(equalToConstant: 44),

			self.currentUsernameLabel.topAnchor.constraint(equalTo: self.commentPreviewContainer.layoutMarginsGuide.topAnchor),
			self.currentUsernameLabel.leadingAnchor.constraint(equalTo: self.profileImageView.trailingAnchor, constant: 8),

			self.characterCountLabel.topAnchor.constraint(equalTo: self.currentUsernameLabel.topAnchor),
			self.characterCountLabel.centerYAnchor.constraint(equalTo: self.currentUsernameLabel.centerYAnchor),
			self.characterCountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.currentUsernameLabel.trailingAnchor, constant: 10),
			self.characterCountLabel.trailingAnchor.constraint(equalTo: self.commentPreviewContainer.layoutMarginsGuide.trailingAnchor),

			self.commentTextView.topAnchor.constraint(equalTo: self.currentUsernameLabel.bottomAnchor),
			self.commentTextView.leadingAnchor.constraint(equalTo: self.currentUsernameLabel.leadingAnchor),
			self.commentTextView.trailingAnchor.constraint(equalTo: self.commentPreviewContainer.layoutMarginsGuide.trailingAnchor),
			self.commentTextView.bottomAnchor.constraint(equalTo: self.commentPreviewContainer.bottomAnchor, constant: -20),

			self.commentPreviewContainer.bottomAnchor.constraint(greaterThanOrEqualTo: self.profileImageView.bottomAnchor, constant: 20),

			self.footerView.leadingAnchor.constraint(equalTo: self.keyboardLayoutGuide.leadingAnchor),
			self.footerView.trailingAnchor.constraint(equalTo: self.keyboardLayoutGuide.trailingAnchor),
			self.footerView.bottomAnchor.constraint(equalTo: self.keyboardLayoutGuide.topAnchor),

			self.footerSeparatorView.topAnchor.constraint(equalTo: self.footerView.topAnchor),
			self.footerSeparatorView.leadingAnchor.constraint(equalTo: self.footerView.leadingAnchor),
			self.footerSeparatorView.trailingAnchor.constraint(equalTo: self.footerView.trailingAnchor),
			self.footerSeparatorView.heightAnchor.constraint(equalToConstant: 1),

			self.footerStackView.topAnchor.constraint(equalTo: self.footerView.topAnchor),
			self.footerStackView.leadingAnchor.constraint(equalTo: self.footerView.leadingAnchor, constant: 20),
			self.footerStackView.trailingAnchor.constraint(equalTo: self.footerView.trailingAnchor, constant: -20),
			self.footerStackView.bottomAnchor.constraint(equalTo: self.footerView.bottomAnchor),
			self.footerStackView.heightAnchor.constraint(equalToConstant: 49)
		])
	}
}
