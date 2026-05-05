//
//  ParentalGuideReasonCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

protocol ParentalGuideReasonCollectionViewCellDelegate: AnyObject {
	/// Tells the delegate the user voted on the entry rendered by `cell`.
	///
	/// - Parameters:
	///    - cell: The cell that received the vote.
	///    - vote: The vote cast, or `nil` to clear an existing vote.
	func parentalGuideReasonCollectionViewCell(_ cell: ParentalGuideReasonCollectionViewCell, didTapVote vote: ParentalGuideVote?)

	/// Asks the delegate for the context menu shown by the cell's more button.
	///
	/// - Parameters:
	///    - cell: The cell requesting the menu.
	///    - entry: The entry the menu acts on.
	///
	/// - Returns: The menu to present, or `nil` to suppress it.
	func parentalGuideReasonCollectionViewCell(_ cell: ParentalGuideReasonCollectionViewCell, contextMenuFor entry: ParentalGuideEntry) -> UIMenu?

	/// Tells the delegate the user tapped the cell's `Show more` glyph.
	///
	/// - Parameter cell: The cell whose reason was expanded.
	func parentalGuideReasonCollectionViewCellDidTapShowMore(_ cell: ParentalGuideReasonCollectionViewCell)
}

class ParentalGuideReasonCollectionViewCell: UICollectionViewCell {
	// MARK: - Views
	private let descriptorLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .footnote)
		label.theme_textColor = KThemePicker.subTextColor.rawValue
		return label
	}()

	private let reasonTextView: KSelectableTextView = {
		let textView = KSelectableTextView()
		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.isScrollEnabled = false
		textView.backgroundColor = .clear
		textView.textContainerInset = .zero
		textView.textContainer.lineFragmentPadding = 0
		textView.font = .preferredFont(forTextStyle: .body)
		textView.theme_textColor = KThemePicker.textColor.rawValue
		return textView
	}()

	private let helpfulButton: CellActionButton = {
		let button = CellActionButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
		return button
	}()

	private let unhelpfulButton: CellActionButton = {
		let button = CellActionButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
		return button
	}()

	private let moreButton: UIButton = {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
		button.theme_tintColor = KThemePicker.subTextColor.rawValue
		return button
	}()

	private lazy var spoilerOverlay: KVisualEffectView = {
		let view = KVisualEffectView(effect: nil)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = true
		view.isUserInteractionEnabled = true
		view.layerCornerRadius = 10

		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = Self.spoilerWarningText
		label.font = .preferredFont(forTextStyle: .footnote).bold
		label.theme_textColor = KThemePicker.textColor.rawValue
		label.textAlignment = .center
		label.numberOfLines = 0
		view.contentView.addSubview(label)

		NSLayoutConstraint.activate([
			label.leadingAnchor.constraint(greaterThanOrEqualTo: view.contentView.leadingAnchor, constant: 12),
			label.trailingAnchor.constraint(lessThanOrEqualTo: view.contentView.trailingAnchor, constant: -12),
			label.centerXAnchor.constraint(equalTo: view.contentView.centerXAnchor),
			label.centerYAnchor.constraint(equalTo: view.contentView.centerYAnchor)
		])

		view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.revealSpoiler)))
		return view
	}()

	// MARK: - Properties
	weak var delegate: ParentalGuideReasonCollectionViewCellDelegate?
	private var entry: ParentalGuideEntry?

	/// Whether the reason text is fully expanded.
	var isExpanded: Bool = false

	/// The maximum number of body lines shown before the cell collapses behind a `Show more` affordance.
	static let bodyLineLimit: Int = 8

	/// The action identifier dispatched when the reason's `Show more` glyph is tapped.
	static let expandReasonActionID: String = "kk-expand-pg-reason"

	/// Cached reason text view widths keyed by concrete cell class.
	private static var cachedReasonWidths: [ObjectIdentifier: CGFloat] = [:]

	/// The cached reason text view width for this cell's concrete class.
	private var cachedReasonWidth: CGFloat {
		return Self.cachedReasonWidths[ObjectIdentifier(type(of: self))] ?? 0
	}

	private static var spoilerWarningText: String {
		#if targetEnvironment(macCatalyst)
		return L10n.parentalGuideReasonSpoilerClick
		#else
		return L10n.parentalGuideReasonSpoilerTap
		#endif
	}

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.configureSubviews()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.configureSubviews()
	}

	// MARK: - View
	override func prepareForReuse() {
		super.prepareForReuse()
		self.isExpanded = false
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		let width = self.reasonTextView.bounds.width
		if width > 0, width != self.cachedReasonWidth {
			Self.cachedReasonWidths[ObjectIdentifier(type(of: self))] = width
		}
	}

	// MARK: - Functions
	/// Renders `entry` into the cell.
	///
	/// - Parameters:
	///    - entry: The entry to display.
	///    - isExpanded: Whether the entry's reason should display fully.
	func configure(using entry: ParentalGuideEntry, isExpanded: Bool = false) {
		self.entry = entry
		self.isExpanded = isExpanded

		let depictionDescriptor = entry.attributes.category.supportsDepiction ? entry.attributes.depiction?.stringValue : nil
		let descriptors: [String?] = [
			entry.attributes.frequency?.stringValue,
			depictionDescriptor,
			entry.attributes.rating.stringValue
		]
		self.descriptorLabel.text = descriptors.compactMap { $0 }.joined(separator: " · ")

		self.applyReasonText(entry.attributes.reason ?? "", isExpanded: isExpanded)

		self.updateHelpfulButton(for: entry)
		self.updateUnhelpfulButton(for: entry)

		self.spoilerOverlay.isHidden = !(entry.attributes.isSpoiler && !(entry.attributes.reason ?? "").isEmpty)

		self.moreButton.menu = UIMenu(title: "", children: [
			UIDeferredMenuElement.uncached { [weak self] completion in
				guard let self = self, let entry = self.entry else {
					completion([])
					return
				}

				let menu = self.delegate?.parentalGuideReasonCollectionViewCell(self, contextMenuFor: entry)
				completion(menu?.children ?? [])
			}
		])
	}

	private func applyReasonText(_ reason: String, isExpanded: Bool) {
		guard !reason.isEmpty else {
			self.reasonTextView.setAttributedText(nil)
			return
		}

		let font = self.reasonTextView.font ?? .preferredFont(forTextStyle: .body)
		let attributed = NSAttributedString(string: reason, attributes: [.font: font])

		let final: NSAttributedString
		if isExpanded {
			final = attributed
		} else {
			final = NSAttributedString.kkTruncatedBody(
				attributed,
				lineLimit: Self.bodyLineLimit,
				cachedWidth: self.cachedReasonWidth,
				fallbackHostBounds: self.bounds.width,
				actionID: Self.expandReasonActionID,
				font: font
			)
		}
		self.reasonTextView.setAttributedText(final)
	}

	private func updateHelpfulButton(for entry: ParentalGuideEntry) {
		var count: Int? = entry.attributes.helpfulCount
		count = count == 0 ? nil : count
		self.helpfulButton.setTitle(count?.kkFormatted(precision: 0), for: .normal)

		if entry.attributes.helpfulness == .helpful {
			self.helpfulButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
			self.helpfulButton.theme_setTitleColor(KThemePicker.tintColor.rawValue, forState: .normal)
			self.helpfulButton.theme_tintColor = KThemePicker.tintColor.rawValue
		} else {
			self.helpfulButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
			self.helpfulButton.theme_setTitleColor(KThemePicker.tableViewCellActionDefaultColor.rawValue, forState: .normal)
			self.helpfulButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		}
	}

	private func updateUnhelpfulButton(for entry: ParentalGuideEntry) {
		var count: Int? = entry.attributes.unhelpfulCount
		count = count == 0 ? nil : count
		self.unhelpfulButton.setTitle(count?.kkFormatted(precision: 0), for: .normal)

		if entry.attributes.helpfulness == .unhelpful {
			self.unhelpfulButton.setImage(UIImage(systemName: "hand.thumbsdown.fill"), for: .normal)
			self.unhelpfulButton.theme_setTitleColor(KThemePicker.tintColor.rawValue, forState: .normal)
			self.unhelpfulButton.theme_tintColor = KThemePicker.tintColor.rawValue
		} else {
			self.unhelpfulButton.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
			self.unhelpfulButton.theme_setTitleColor(KThemePicker.tableViewCellActionDefaultColor.rawValue, forState: .normal)
			self.unhelpfulButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		}
	}

	private func configureSubviews() {
		self.contentView.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
		self.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		self.contentView.layer.cornerRadius = 10

		let bottomRow = UIStackView(arrangedSubviews: [self.helpfulButton, self.unhelpfulButton, UIView(), self.moreButton])
		bottomRow.translatesAutoresizingMaskIntoConstraints = false
		bottomRow.axis = .horizontal
		bottomRow.spacing = 16
		bottomRow.alignment = .center

		let outerStack = UIStackView(arrangedSubviews: [self.descriptorLabel, self.reasonTextView, bottomRow])
		outerStack.translatesAutoresizingMaskIntoConstraints = false
		outerStack.axis = .vertical
		outerStack.spacing = 8

		self.contentView.addSubview(outerStack)
		self.contentView.addSubview(self.spoilerOverlay)

		NSLayoutConstraint.activate([
			outerStack.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor),
			outerStack.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor),
			outerStack.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor),
			outerStack.bottomAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.bottomAnchor),

			self.spoilerOverlay.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			self.spoilerOverlay.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
			self.spoilerOverlay.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.spoilerOverlay.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor)
		])

		self.helpfulButton.addTarget(self, action: #selector(self.helpfulPressed), for: .touchUpInside)
		self.unhelpfulButton.addTarget(self, action: #selector(self.unhelpfulPressed), for: .touchUpInside)
		self.moreButton.showsMenuAsPrimaryAction = true

		self.reasonTextView.kkActionHandler = { [weak self] action in
			guard let self = self else { return }

			if action == Self.expandReasonActionID {
				self.delegate?.parentalGuideReasonCollectionViewCellDidTapShowMore(self)
			}
		}
	}

	@objc private func helpfulPressed() {
		self.delegate?.parentalGuideReasonCollectionViewCell(self, didTapVote: .helpful)
	}

	@objc private func unhelpfulPressed() {
		self.delegate?.parentalGuideReasonCollectionViewCell(self, didTapVote: .unhelpful)
	}

	@objc private func revealSpoiler() {
		UIView.animate(withDuration: 0.2) {
			self.spoilerOverlay.alpha = 0
		} completion: { _ in
			self.spoilerOverlay.isHidden = true
			self.spoilerOverlay.alpha = 1
		}
	}
}
