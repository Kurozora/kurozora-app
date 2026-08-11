//
//  KotodamaResultView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

protocol KotodamaResultViewDelegate: AnyObject {
	/// Tells the delegate that the share button was pressed.
	func kotodamaResultViewDidPressShare(_ resultView: KotodamaResultView)

	/// Tells the delegate that the revealed subject was pressed.
	func kotodamaResultViewDidPressSubject(_ resultView: KotodamaResultView)

	/// Tells the delegate that the new word button was pressed.
	func kotodamaResultViewDidPressNewWord(_ resultView: KotodamaResultView)

	/// Tells the delegate that the play unlimited button was pressed.
	func kotodamaResultViewDidPressPlayUnlimited(_ resultView: KotodamaResultView)

	/// Tells the delegate to show the given view controller.
	func kotodamaResultView(_ resultView: KotodamaResultView, wantsToShow viewController: UIViewController)

	/// Asks the delegate for the subject model's own context menu, when its details have been fetched.
	func kotodamaResultViewContextMenuConfiguration(_ resultView: KotodamaResultView) -> UIContextMenuConfiguration?
}

class KotodamaResultView: UIView {
	// MARK: - Views
	private let contentStackView = UIStackView()
	private let outcomeLabel = UILabel()
	private let hintLabel = UILabel()
	private let subjectLockupView = KotodamaSubjectLockupView()
	private let shareGridContainerView = UIView()
	private let shareGridLabel = UILabel()
	private let actionsStackView = UIStackView()
	private let shareButton = KTintedButton()
	private let newWordButton = KButton()
	private let playUnlimitedButton = KButton()

	// MARK: - Properties
	/// The object that acts as the delegate of the result view.
	weak var delegate: KotodamaResultViewDelegate?

	/// The context-menu interaction used to peek and pop the subject's details.
	private lazy var subjectContextMenuInteraction = UIContextMenuInteraction(delegate: self)

	/// The kind of the revealed subject, used to build its context menu.
	private var subjectKind: KotodamaSubjectKind?

	/// The id of the revealed subject, used to build its context menu.
	private var subjectID: KurozoraItemID?

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)

		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)

		self.sharedInit()
	}

	// MARK: - Functions
	/// The shared init of the view.
	private func sharedInit() {
		self.translatesAutoresizingMaskIntoConstraints = false

		self.contentStackView.translatesAutoresizingMaskIntoConstraints = false
		self.contentStackView.axis = .vertical
		self.contentStackView.alignment = .center
		self.contentStackView.spacing = 12
		self.addSubview(self.contentStackView)

		self.outcomeLabel.textAlignment = .center
		self.outcomeLabel.numberOfLines = 0
		self.outcomeLabel.font = .systemFont(ofSize: 22, weight: .bold)
		self.outcomeLabel.theme_textColor = KThemePicker.textColor.rawValue

		self.hintLabel.textAlignment = .center
		self.hintLabel.numberOfLines = 0
		self.hintLabel.font = .preferredFont(forTextStyle: .subheadline)
		self.hintLabel.adjustsFontForContentSizeCategory = true
		self.hintLabel.theme_textColor = KThemePicker.subTextColor.rawValue

		self.configureSubjectLockup()
		self.configureShareGridPreview()

		self.actionsStackView.axis = .horizontal
		self.actionsStackView.alignment = .fill
		self.actionsStackView.distribution = .fillEqually
		self.actionsStackView.spacing = 12

		self.shareButton.setTitle(L10n.kotodamaShareResult, for: .normal)
		self.shareButton.heightAnchor.constraint(equalToConstant: 46).isActive = true
		self.shareButton.addTarget(self, action: #selector(self.shareButtonPressed), for: .touchUpInside)

		self.newWordButton.setTitle(L10n.kotodamaNewWord, for: .normal)
		self.newWordButton.heightAnchor.constraint(equalToConstant: 46).isActive = true
		self.newWordButton.addTarget(self, action: #selector(self.newWordButtonPressed), for: .touchUpInside)

		self.playUnlimitedButton.setTitle(L10n.kotodamaPlayUnlimited, for: .normal)
		self.playUnlimitedButton.heightAnchor.constraint(equalToConstant: 46).isActive = true
		self.playUnlimitedButton.addTarget(self, action: #selector(self.playUnlimitedButtonPressed), for: .touchUpInside)

		self.actionsStackView.addArrangedSubview(self.shareButton)
		self.actionsStackView.addArrangedSubview(self.newWordButton)
		self.actionsStackView.addArrangedSubview(self.playUnlimitedButton)

		self.contentStackView.addArrangedSubview(self.outcomeLabel)
		self.contentStackView.addArrangedSubview(self.hintLabel)
		self.contentStackView.addArrangedSubview(self.subjectLockupView)
		self.contentStackView.addArrangedSubview(self.shareGridContainerView)
		self.contentStackView.addArrangedSubview(self.actionsStackView)

		NSLayoutConstraint.activate([
			self.contentStackView.topAnchor.constraint(equalTo: self.topAnchor),
			self.contentStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			self.contentStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.contentStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.hintLabel.widthAnchor.constraint(equalTo: self.contentStackView.widthAnchor),
			self.subjectLockupView.widthAnchor.constraint(equalTo: self.contentStackView.widthAnchor),
			self.shareGridContainerView.widthAnchor.constraint(equalTo: self.contentStackView.widthAnchor),
			self.actionsStackView.widthAnchor.constraint(equalTo: self.contentStackView.widthAnchor)
		])
	}

	/// Builds the lockup showing the answer's subject.
	private func configureSubjectLockup() {
		self.subjectLockupView.isHidden = true
		self.subjectLockupView.isUserInteractionEnabled = true
		self.subjectLockupView.addInteraction(self.subjectContextMenuInteraction)
		self.subjectLockupView.addGestureRecognizer(
			UITapGestureRecognizer(target: self, action: #selector(self.subjectButtonPressed))
		)
	}

	/// Builds the rounded box previewing the game's emoji share grid.
	private func configureShareGridPreview() {
		self.shareGridContainerView.translatesAutoresizingMaskIntoConstraints = false
		self.shareGridContainerView.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		self.shareGridContainerView.layer.cornerCurve = .continuous
		self.shareGridContainerView.layer.cornerRadius = 12
		self.shareGridContainerView.layer.borderWidth = 1
		self.shareGridContainerView.layer.theme_borderColor = KThemePicker.borderColor.cgColorPicker
		self.shareGridContainerView.clipsToBounds = true
		self.shareGridContainerView.isHidden = true

		self.shareGridLabel.translatesAutoresizingMaskIntoConstraints = false
		self.shareGridLabel.font = .monospacedSystemFont(ofSize: 15, weight: .regular)
		self.shareGridLabel.numberOfLines = 0
		self.shareGridLabel.textAlignment = .center
		self.shareGridLabel.theme_textColor = KThemePicker.textColor.rawValue
		self.shareGridContainerView.addSubview(self.shareGridLabel)

		NSLayoutConstraint.activate([
			self.shareGridLabel.topAnchor.constraint(equalTo: self.shareGridContainerView.topAnchor, constant: 12),
			self.shareGridLabel.bottomAnchor.constraint(equalTo: self.shareGridContainerView.bottomAnchor, constant: -12),
			self.shareGridLabel.leadingAnchor.constraint(equalTo: self.shareGridContainerView.leadingAnchor, constant: 12),
			self.shareGridLabel.trailingAnchor.constraint(equalTo: self.shareGridContainerView.trailingAnchor, constant: -12)
		])
	}

	/// Configures the view with the outcome of a game.
	///
	/// - Parameter game: The finished game to describe.
	func configure(using game: KotodamaGame) {
		let attributes = game.attributes
		let isWon = attributes.status == .won

		if isWon {
			self.outcomeLabel.text = String(format: L10n.kotodamaSolved, attributes.guessCount, attributes.maxGuesses)
		} else if let answer = game.word?.attributes.answer {
			self.outcomeLabel.text = String(format: L10n.kotodamaUnsolvedAnswer, answer.uppercased())
		} else {
			self.outcomeLabel.text = L10n.kotodamaUnsolved
		}

		if let hint = game.word?.attributes.hint, !hint.isEmpty {
			self.hintLabel.text = String(format: L10n.kotodamaHintLabel, hint)
			self.hintLabel.isHidden = false
		} else {
			self.hintLabel.text = nil
			self.hintLabel.isHidden = true
		}

		self.newWordButton.isHidden = attributes.mode != .unlimited
		self.playUnlimitedButton.isHidden = attributes.mode == .unlimited

		self.hideShareGridPreview()
		self.configureSubject(using: game.word)
	}

	/// Shows the fetched share grid inside a rounded preview box.
	///
	/// - Parameter text: The share grid's text.
	func showShareGridPreview(text: String) {
		self.shareGridLabel.text = text
		self.shareGridContainerView.isHidden = false
	}

	/// Hides the share grid preview box, leaving the rest of the layout unchanged.
	func hideShareGridPreview() {
		self.shareGridContainerView.isHidden = true
		self.shareGridLabel.text = nil
	}

	/// Records the identity of the answer's subject.
	///
	/// - Parameter word: The revealed word whose subject is shown.
	private func configureSubject(using word: KotodamaWord?) {
		self.subjectLockupView.isHidden = true
		self.subjectKind = word?.subject?.kind
		self.subjectID = word?.subject?.id
		self.subjectLockupView.accessibilityLabel = word?.attributes.answer
	}

	/// Shows the lockup of the answer's subject.
	///
	/// - Parameter subject: The catalog entry behind the answer.
	func showSubject(_ subject: KotodamaSubject?) {
		guard let subject = subject else {
			self.subjectLockupView.isHidden = true
			return
		}

		self.subjectLockupView.configure(using: subject)
		self.subjectLockupView.isHidden = false
	}

	/// Notifies the delegate that the share button was pressed.
	@objc private func shareButtonPressed() {
		self.delegate?.kotodamaResultViewDidPressShare(self)
	}

	/// Notifies the delegate that the subject was pressed.
	@objc private func subjectButtonPressed() {
		self.delegate?.kotodamaResultViewDidPressSubject(self)
	}

	/// Notifies the delegate that the new word button was pressed.
	@objc private func newWordButtonPressed() {
		self.delegate?.kotodamaResultViewDidPressNewWord(self)
	}

	/// Notifies the delegate that the play unlimited button was pressed.
	@objc private func playUnlimitedButtonPressed() {
		self.delegate?.kotodamaResultViewDidPressPlayUnlimited(self)
	}
}

// MARK: - UIContextMenuInteractionDelegate
extension KotodamaResultView: UIContextMenuInteractionDelegate {
	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
		guard let subjectKind = self.subjectKind, let subjectID = self.subjectID else { return nil }

		if let configuration = self.delegate?.kotodamaResultViewContextMenuConfiguration(self) {
			return configuration
		}

		return UIContextMenuConfiguration(identifier: nil, previewProvider: {
			subjectKind.detailsViewController(for: subjectID)
		})
	}

	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
		guard let previewViewController = animator.previewViewController else { return }

		animator.addCompletion { [weak self] in
			guard let self = self else { return }

			self.delegate?.kotodamaResultView(self, wantsToShow: previewViewController)
		}
	}
}
