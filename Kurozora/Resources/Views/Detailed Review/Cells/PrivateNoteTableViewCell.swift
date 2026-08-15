//
//  PrivateNoteTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

protocol PrivateNoteTableViewCellDelegate: AnyObject {
	func privateNoteTableViewCell(_ cell: PrivateNoteTableViewCell, didChangeNote note: String)
}

class PrivateNoteTableViewCell: KTableViewCell {
	// MARK: - Views
	private let separatorView = SeparatorView()
	private let titleLabel = KLabel()
	private let noteInputView = TitledTextView(title: nil, placeholder: L10n.whatsOnYourMind)

	// MARK: - Properties
	override var isSkeletonEnabled: Bool {
		return false
	}

	weak var delegate: PrivateNoteTableViewCellDelegate?

	// MARK: - Initializers
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.configureSubviews()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.configureSubviews()
	}

	// MARK: - Functions
	/// Configure the cell with the given note.
	func configure(using note: String?) {
		self.noteInputView.textView.text = note
	}

	private func configureSubviews() {
		self.selectionStyle = .none
		self.backgroundColor = .clear
		self.contentView.theme_backgroundColor = nil
		self.contentView.backgroundColor = .clear
		self.contentView.directionalLayoutMargins.top = 12
		self.contentView.directionalLayoutMargins.bottom = 12

		self.titleLabel.text = L10n.privateNotes
		self.titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
		self.titleLabel.adjustsFontForContentSizeCategory = true

		self.noteInputView.textView.delegate = self

		let stackView = UIStackView(arrangedSubviews: [self.separatorView, self.titleLabel, self.noteInputView])
		stackView.axis = .vertical
		stackView.spacing = 8
		stackView.setCustomSpacing(20, after: self.separatorView)
		stackView.translatesAutoresizingMaskIntoConstraints = false

		self.contentView.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor),
			stackView.bottomAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.bottomAnchor),
			stackView.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor),

			self.separatorView.heightAnchor.constraint(equalToConstant: 1.0)
		])
	}
}

// MARK: - UITextViewDelegate
extension PrivateNoteTableViewCell: UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		self.delegate?.privateNoteTableViewCell(self, didChangeNote: textView.text ?? "")
	}
}
