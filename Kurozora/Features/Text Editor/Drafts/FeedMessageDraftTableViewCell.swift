//
//  FeedMessageDraftTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// View model for configuring a `FeedMessageDraftTableViewCell`.
struct DraftCellViewModel {
	/// The truncated content preview.
	let content: String

	/// A layout badge label, e.g. "Reply" or "ReShare". Nil for standard.
	let layoutBadge: String?

	/// The relative date string, e.g. "2 hours ago".
	let relativeDate: String

	/// Whether the draft is flagged as NSFW.
	let isNSFW: Bool

	/// Whether the draft is flagged as a spoiler.
	let isSpoiler: Bool

	init(draft: FeedMessageDraft) {
		self.content = draft.content
		self.isNSFW = draft.isNSFW
		self.isSpoiler = draft.isSpoiler
		self.relativeDate = draft.updatedAt.relativeToNow

		switch draft.editorLayout {
		case .reply:
			if let username = draft.parentSnapshot?.authorUsername, !username.isEmpty {
				self.layoutBadge = "\(Trans.reply) · @\(username)"
			} else {
				self.layoutBadge = Trans.reply
			}
		case .reShare:
			if let username = draft.parentSnapshot?.authorUsername, !username.isEmpty {
				self.layoutBadge = "\(Trans.reshare) · @\(username)"
			} else {
				self.layoutBadge = Trans.reshare
			}
		default:
			self.layoutBadge = nil
		}
	}
}

/// A table view cell displaying a feed message draft preview.
final class FeedMessageDraftTableViewCell: KTableViewCell {
	// MARK: - Properties
	override var isSkeletonEnabled: Bool {
		return false
	}

	// MARK: - Views
	private let contentPreviewLabel: KLabel = {
		let label = KLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .body)
		label.numberOfLines = 2
		label.lineBreakMode = .byTruncatingTail
		return label
	}()

	private let dateLabel: KSecondaryLabel = {
		let label = KSecondaryLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .footnote)
		return label
	}()

	private let layoutBadgeLabel: KSecondaryLabel = {
		let label = KSecondaryLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .caption1).bold
		label.textAlignment = .center
		return label
	}()

	private let badgeSeparator: KSecondaryLabel = {
		let label = KSecondaryLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .footnote)
		label.text = "·"
		return label
	}()

	private let metadataStackView: UIStackView = {
		let stack = UIStackView()
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.axis = .horizontal
		stack.spacing = 4
		stack.alignment = .center
		return stack
	}()

	// MARK: - Initializers
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.configureViewHierarchy()
		self.configureConstraints()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.configureViewHierarchy()
		self.configureConstraints()
	}

	// MARK: - Functions
	/// Configures the cell with a draft view model.
	///
	/// - Parameter viewModel: The view model containing display data.
	func configure(using viewModel: DraftCellViewModel) {
		self.contentPreviewLabel.text = viewModel.content.isEmpty ? Trans.emptyDraft : viewModel.content
		self.contentPreviewLabel.alpha = viewModel.content.isEmpty ? 0.5 : 1.0
		self.dateLabel.text = viewModel.relativeDate

		if let badge = viewModel.layoutBadge {
			self.layoutBadgeLabel.text = badge
			self.layoutBadgeLabel.isHidden = false
			self.badgeSeparator.isHidden = false
		} else {
			self.layoutBadgeLabel.isHidden = true
			self.badgeSeparator.isHidden = true
		}
	}

	private func configureViewHierarchy() {
		self.metadataStackView.addArrangedSubview(self.layoutBadgeLabel)
		self.metadataStackView.addArrangedSubview(self.badgeSeparator)
		self.metadataStackView.addArrangedSubview(self.dateLabel)

		self.contentView.addSubview(self.contentPreviewLabel)
		self.contentView.addSubview(self.metadataStackView)
	}

	private func configureConstraints() {
		NSLayoutConstraint.activate([
			self.contentPreviewLabel.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor),
			self.contentPreviewLabel.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor),
			self.contentPreviewLabel.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor),

			self.metadataStackView.topAnchor.constraint(equalTo: self.contentPreviewLabel.bottomAnchor, constant: 4),
			self.metadataStackView.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor),
			self.metadataStackView.trailingAnchor.constraint(lessThanOrEqualTo: self.contentView.layoutMarginsGuide.trailingAnchor),
			self.metadataStackView.bottomAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.bottomAnchor)
		])
	}
}
