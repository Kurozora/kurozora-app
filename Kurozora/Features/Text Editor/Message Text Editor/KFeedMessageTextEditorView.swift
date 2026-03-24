//
//  KFeedMessageTextEditorView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

final class KFeedMessageTextEditorView: KView {
	// MARK: - Views
	let profileImageView = ProfileImageView(frame: .zero)
	let currentUsernameLabel = KLabel()
	let characterCountLabel = KSecondaryLabel()
	let commentTextView = KTextView()
	let commentPreviewContainer = UIView()
	let labelsButton = KButton()
	let footerStackView = UIStackView()

	private(set) var opProfileImageView: ProfileImageView?
	private(set) var opUsernameLabel: KLabel?
	private(set) var opDateLabel: KSecondaryLabel?
	private(set) var opMessageTextView: KSelectableTextView?
	private(set) var opPreviewContainer: UIView?

	private let scrollView = UIScrollView()
	private let scrollContentView = UIView()
	private let footerView = KView()
	private let footerSeparatorView = SecondarySeparatorView()
	private let footerSpacerView = UIView()
	private var separatorView: SecondarySeparatorView?

	// MARK: - Properties
	let layout: FeedMessageEditorLayout

	// MARK: - Initializers
	init(layout: FeedMessageEditorLayout = .standard) {
		self.layout = layout
		super.init(frame: .zero)
		self.configure()
	}

	required init?(coder: NSCoder) {
		self.layout = .standard
		super.init(coder: coder)
		self.configure()
	}
}

// MARK: - Configuration
private extension KFeedMessageTextEditorView {
	func configure() {
		self.configureView()
		self.configureScrollView()

		if self.layout == .reply {
			self.configureOPPreviewContainer()
			self.configureOPProfileImageView()
			self.configureOPUsernameLabel()
			self.configureOPDateLabel()
			self.configureOPMessageTextView()
			self.configureSeparatorView()
		}

		self.configureCommentPreviewContainer()
		self.configureProfileImageView()
		self.configureCurrentUsernameLabel()
		self.configureCharacterCountLabel()
		self.configureCommentTextView()

		if self.layout == .reShare {
			self.configureOPPreviewContainer()
			self.configureOPProfileImageView()
			self.configureOPUsernameLabel()
			self.configureOPDateLabel()
			self.configureOPMessageTextView()
		}

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

	func configureCommentPreviewContainer() {
		self.commentPreviewContainer.translatesAutoresizingMaskIntoConstraints = false

		switch self.layout {
		case .standard:
			self.commentPreviewContainer.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8)
		case .reply:
			self.commentPreviewContainer.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8)
			self.commentPreviewContainer.layerCornerRadius = 10
		case .reShare:
			self.commentPreviewContainer.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
			self.commentPreviewContainer.layerCornerRadius = 10
		}
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

	// MARK: - OP Views Configuration
	func configureOPPreviewContainer() {
		let container = UIView()
		container.translatesAutoresizingMaskIntoConstraints = false
		container.layerCornerRadius = 10

		switch self.layout {
		case .reply:
			container.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8)
		case .reShare:
			container.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
			container.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		case .standard:
			break
		}

		self.opPreviewContainer = container
	}

	func configureOPProfileImageView() {
		let imageView = ProfileImageView(frame: .zero)
		imageView.translatesAutoresizingMaskIntoConstraints = false

		switch self.layout {
		case .reply:
			imageView.contentMode = .scaleAspectFill
		case .reShare:
			imageView.contentMode = .scaleAspectFit
		case .standard:
			break
		}

		self.opProfileImageView = imageView
	}

	func configureOPUsernameLabel() {
		let label = KLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .headline)
		label.lineBreakMode = .byTruncatingTail
		label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		self.opUsernameLabel = label
	}

	func configureOPDateLabel() {
		let label = KSecondaryLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .footnote)
		label.setContentCompressionResistancePriority(.required, for: .horizontal)
		label.setContentHuggingPriority(.required, for: .horizontal)
		self.opDateLabel = label
	}

	func configureOPMessageTextView() {
		let textView = KSelectableTextView()
		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.isScrollEnabled = false
		textView.showsHorizontalScrollIndicator = false
		textView.showsVerticalScrollIndicator = false
		textView.bounces = false
		textView.bouncesZoom = false
		textView.font = .preferredFont(forTextStyle: .body)
		self.opMessageTextView = textView
	}

	func configureSeparatorView() {
		let separator = SecondarySeparatorView()
		separator.translatesAutoresizingMaskIntoConstraints = false
		self.separatorView = separator
	}

	// MARK: - Footer Configuration
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

	// MARK: - View Hierarchy
	func configureViewHierarchy() {
		self.addSubview(self.scrollView)
		self.addSubview(self.footerView)

		self.scrollView.addSubview(self.scrollContentView)

		switch self.layout {
		case .standard:
			self.scrollContentView.addSubview(self.commentPreviewContainer)

			self.commentPreviewContainer.addSubview(self.profileImageView)
			self.commentPreviewContainer.addSubview(self.currentUsernameLabel)
			self.commentPreviewContainer.addSubview(self.characterCountLabel)
			self.commentPreviewContainer.addSubview(self.commentTextView)
		case .reply:
			guard let opPreviewContainer = self.opPreviewContainer,
			      let opProfileImageView = self.opProfileImageView,
			      let opUsernameLabel = self.opUsernameLabel,
			      let opDateLabel = self.opDateLabel,
			      let opMessageTextView = self.opMessageTextView,
			      let separatorView = self.separatorView else { return }

			self.scrollContentView.addSubview(opPreviewContainer)
			self.scrollContentView.addSubview(separatorView)
			self.scrollContentView.addSubview(self.commentPreviewContainer)

			opPreviewContainer.addSubview(opProfileImageView)
			opPreviewContainer.addSubview(opUsernameLabel)
			opPreviewContainer.addSubview(opDateLabel)
			opPreviewContainer.addSubview(opMessageTextView)

			self.commentPreviewContainer.addSubview(self.profileImageView)
			self.commentPreviewContainer.addSubview(self.currentUsernameLabel)
			self.commentPreviewContainer.addSubview(self.characterCountLabel)
			self.commentPreviewContainer.addSubview(self.commentTextView)
		case .reShare:
			guard let opPreviewContainer = self.opPreviewContainer,
			      let opProfileImageView = self.opProfileImageView,
			      let opUsernameLabel = self.opUsernameLabel,
			      let opDateLabel = self.opDateLabel,
			      let opMessageTextView = self.opMessageTextView else { return }

			self.scrollContentView.addSubview(self.commentPreviewContainer)

			self.commentPreviewContainer.addSubview(self.profileImageView)
			self.commentPreviewContainer.addSubview(self.currentUsernameLabel)
			self.commentPreviewContainer.addSubview(self.characterCountLabel)
			self.commentPreviewContainer.addSubview(self.commentTextView)
			self.commentPreviewContainer.addSubview(opPreviewContainer)

			opPreviewContainer.addSubview(opProfileImageView)
			opPreviewContainer.addSubview(opUsernameLabel)
			opPreviewContainer.addSubview(opDateLabel)
			opPreviewContainer.addSubview(opMessageTextView)
		}

		self.footerView.addSubview(self.footerSeparatorView)
		self.footerView.addSubview(self.footerStackView)

		self.footerStackView.addArrangedSubview(self.labelsButton)
		self.footerStackView.addArrangedSubview(self.footerSpacerView)
	}

	// MARK: - Constraints
	func configureConstraints() {
		// Shared scroll view + footer constraints
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

		switch self.layout {
		case .standard:
			self.configureStandardConstraints()
		case .reply:
			self.configureReplyConstraints()
		case .reShare:
			self.configureReShareConstraints()
		}
	}

	func configureStandardConstraints() {
		NSLayoutConstraint.activate([
			self.commentPreviewContainer.topAnchor.constraint(equalTo: self.scrollContentView.topAnchor, constant: 20),
			self.commentPreviewContainer.leadingAnchor.constraint(equalTo: self.scrollContentView.leadingAnchor, constant: 20),
			self.commentPreviewContainer.trailingAnchor.constraint(equalTo: self.scrollContentView.trailingAnchor, constant: -20),
			self.commentPreviewContainer.bottomAnchor.constraint(equalTo: self.scrollContentView.bottomAnchor, constant: -20),

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

			self.commentPreviewContainer.bottomAnchor.constraint(greaterThanOrEqualTo: self.profileImageView.bottomAnchor, constant: 20)
		])
	}

	func configureReplyConstraints() {
		guard let opPreviewContainer = self.opPreviewContainer,
		      let opProfileImageView = self.opProfileImageView,
		      let opUsernameLabel = self.opUsernameLabel,
		      let opDateLabel = self.opDateLabel,
		      let opMessageTextView = self.opMessageTextView,
		      let separatorView = self.separatorView else { return }

		NSLayoutConstraint.activate([
			// OP preview container (above)
			opPreviewContainer.topAnchor.constraint(equalTo: self.scrollContentView.topAnchor, constant: 20),
			opPreviewContainer.leadingAnchor.constraint(equalTo: self.scrollContentView.leadingAnchor, constant: 18),
			opPreviewContainer.trailingAnchor.constraint(equalTo: self.scrollContentView.trailingAnchor, constant: -18),

			// Separator
			separatorView.topAnchor.constraint(equalTo: opPreviewContainer.bottomAnchor),
			separatorView.leadingAnchor.constraint(equalTo: self.scrollContentView.leadingAnchor, constant: 8),
			separatorView.trailingAnchor.constraint(equalTo: self.scrollContentView.trailingAnchor, constant: -8),
			separatorView.heightAnchor.constraint(equalToConstant: 1),

			// Comment preview container (below separator)
			self.commentPreviewContainer.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 8),
			self.commentPreviewContainer.leadingAnchor.constraint(equalTo: self.scrollContentView.leadingAnchor, constant: 18),
			self.commentPreviewContainer.trailingAnchor.constraint(equalTo: self.scrollContentView.trailingAnchor, constant: -18),
			self.commentPreviewContainer.bottomAnchor.constraint(equalTo: self.scrollContentView.bottomAnchor, constant: -20),

			// OP profile image (44x44)
			opProfileImageView.topAnchor.constraint(equalTo: opPreviewContainer.layoutMarginsGuide.topAnchor),
			opProfileImageView.leadingAnchor.constraint(equalTo: opPreviewContainer.layoutMarginsGuide.leadingAnchor),
			opProfileImageView.widthAnchor.constraint(equalToConstant: 44),
			opProfileImageView.heightAnchor.constraint(equalToConstant: 44),

			opUsernameLabel.topAnchor.constraint(equalTo: opPreviewContainer.layoutMarginsGuide.topAnchor),
			opUsernameLabel.leadingAnchor.constraint(equalTo: opProfileImageView.trailingAnchor, constant: 8),

			opDateLabel.topAnchor.constraint(equalTo: opUsernameLabel.topAnchor),
			opDateLabel.centerYAnchor.constraint(equalTo: opUsernameLabel.centerYAnchor),
			opDateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: opUsernameLabel.trailingAnchor, constant: 10),
			opDateLabel.trailingAnchor.constraint(equalTo: opPreviewContainer.layoutMarginsGuide.trailingAnchor),

			opMessageTextView.topAnchor.constraint(equalTo: opUsernameLabel.bottomAnchor),
			opMessageTextView.leadingAnchor.constraint(equalTo: opUsernameLabel.leadingAnchor),
			opMessageTextView.trailingAnchor.constraint(equalTo: opPreviewContainer.layoutMarginsGuide.trailingAnchor),
			opMessageTextView.bottomAnchor.constraint(equalTo: opPreviewContainer.bottomAnchor, constant: -20),

			opPreviewContainer.bottomAnchor.constraint(greaterThanOrEqualTo: opProfileImageView.bottomAnchor, constant: 20),

			// Current user section
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

			self.commentPreviewContainer.bottomAnchor.constraint(greaterThanOrEqualTo: self.profileImageView.bottomAnchor, constant: 20)
		])
	}

	func configureReShareConstraints() {
		guard let opPreviewContainer = self.opPreviewContainer,
		      let opProfileImageView = self.opProfileImageView,
		      let opUsernameLabel = self.opUsernameLabel,
		      let opDateLabel = self.opDateLabel,
		      let opMessageTextView = self.opMessageTextView else { return }

		NSLayoutConstraint.activate([
			self.commentPreviewContainer.topAnchor.constraint(equalTo: self.scrollContentView.topAnchor, constant: 20),
			self.commentPreviewContainer.leadingAnchor.constraint(equalTo: self.scrollContentView.leadingAnchor, constant: 18),
			self.commentPreviewContainer.trailingAnchor.constraint(equalTo: self.scrollContentView.trailingAnchor, constant: -18),
			self.commentPreviewContainer.bottomAnchor.constraint(equalTo: self.scrollContentView.bottomAnchor),

			// Current user section
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

			// OP preview container (embedded below text view)
			opPreviewContainer.topAnchor.constraint(equalTo: self.commentTextView.bottomAnchor, constant: 8),
			opPreviewContainer.leadingAnchor.constraint(equalTo: self.commentTextView.leadingAnchor),
			opPreviewContainer.trailingAnchor.constraint(equalTo: self.commentTextView.trailingAnchor),
			opPreviewContainer.bottomAnchor.constraint(equalTo: self.commentPreviewContainer.bottomAnchor, constant: -8),

			self.commentPreviewContainer.bottomAnchor.constraint(greaterThanOrEqualTo: self.profileImageView.bottomAnchor, constant: 20),

			// OP profile image (32x32)
			opProfileImageView.topAnchor.constraint(equalTo: opPreviewContainer.layoutMarginsGuide.topAnchor),
			opProfileImageView.leadingAnchor.constraint(equalTo: opPreviewContainer.layoutMarginsGuide.leadingAnchor),
			opProfileImageView.widthAnchor.constraint(equalToConstant: 32),
			opProfileImageView.heightAnchor.constraint(equalToConstant: 32),

			opUsernameLabel.topAnchor.constraint(equalTo: opPreviewContainer.layoutMarginsGuide.topAnchor),
			opUsernameLabel.leadingAnchor.constraint(equalTo: opProfileImageView.trailingAnchor, constant: 8),

			opDateLabel.topAnchor.constraint(equalTo: opUsernameLabel.topAnchor),
			opDateLabel.centerYAnchor.constraint(equalTo: opUsernameLabel.centerYAnchor),
			opDateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: opUsernameLabel.trailingAnchor, constant: 10),
			opDateLabel.trailingAnchor.constraint(equalTo: opPreviewContainer.layoutMarginsGuide.trailingAnchor),

			opMessageTextView.topAnchor.constraint(equalTo: opUsernameLabel.bottomAnchor, constant: 8),
			opMessageTextView.leadingAnchor.constraint(equalTo: opUsernameLabel.leadingAnchor),
			opMessageTextView.trailingAnchor.constraint(equalTo: opDateLabel.trailingAnchor),
			opMessageTextView.bottomAnchor.constraint(equalTo: opPreviewContainer.bottomAnchor, constant: -8),

			opPreviewContainer.bottomAnchor.constraint(greaterThanOrEqualTo: opProfileImageView.bottomAnchor, constant: 20)
		])
	}
}
