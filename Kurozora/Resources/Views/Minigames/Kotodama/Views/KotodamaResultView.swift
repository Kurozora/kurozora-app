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
	private let subjectButton = UIButton(type: .system)
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

	/// The subject's image view, rebuilt per game to match the answer kind's display shape.
	private var subjectImageView: UIImageView?

	/// The themed border drawn around the subject image, sized to match its shape.
	private var subjectBorderView: BorderView?

	/// The book-cover mask applied to a literature's poster.
	private var subjectMaskView: UIImageView?

	/// The constraints sizing and positioning the current subject image view and its border.
	private var subjectImageConstraints: [NSLayoutConstraint] = []

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

		self.configureSubjectButton()
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
		self.contentStackView.addArrangedSubview(self.subjectButton)
		self.contentStackView.addArrangedSubview(self.shareGridContainerView)
		self.contentStackView.addArrangedSubview(self.actionsStackView)

		NSLayoutConstraint.activate([
			self.contentStackView.topAnchor.constraint(equalTo: self.topAnchor),
			self.contentStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			self.contentStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.contentStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.hintLabel.widthAnchor.constraint(equalTo: self.contentStackView.widthAnchor),
			self.shareGridContainerView.widthAnchor.constraint(equalTo: self.contentStackView.widthAnchor),
			self.actionsStackView.widthAnchor.constraint(equalTo: self.contentStackView.widthAnchor)
		])
	}

	/// Builds the button showing the answer's subject.
	private func configureSubjectButton() {
		self.subjectButton.translatesAutoresizingMaskIntoConstraints = false
		self.subjectButton.addTarget(self, action: #selector(self.subjectButtonPressed), for: .touchUpInside)
		self.subjectButton.addInteraction(self.subjectContextMenuInteraction)
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

	/// Configures the subject shown alongside the answer.
	///
	/// - Parameter word: The revealed word whose subject is shown.
	private func configureSubject(using word: KotodamaWord?) {
		guard let posterURL = word?.attributes.poster?.url else {
			self.subjectButton.isHidden = true
			self.subjectKind = nil
			self.subjectID = nil
			return
		}

		let kind = word?.subjectKind
		self.subjectButton.isHidden = false
		self.subjectButton.accessibilityLabel = word?.attributes.answer
		self.subjectKind = kind
		self.subjectID = word?.subject?.id

		self.rebuildSubjectImageView(for: kind)
		self.subjectImageView?.setImage(with: posterURL, placeholder: kind?.placeholderImage ?? .Placeholders.showPoster)
	}

	/// Rebuilds the subject image view to match the given kind's display shape.
	///
	/// - Parameter kind: The kind of the revealed subject.
	private func rebuildSubjectImageView(for kind: KotodamaSubjectKind?) {
		NSLayoutConstraint.deactivate(self.subjectImageConstraints)
		self.subjectImageConstraints.removeAll()
		self.subjectImageView?.removeFromSuperview()
		self.subjectBorderView?.removeFromSuperview()
		self.subjectMaskView = nil
		self.subjectBorderView = nil

		let imageView: UIImageView
		var borderCornerRadius: CGFloat?
		let width: CGFloat
		let height: CGFloat

		switch kind {
		case .shows:
			imageView = PosterImageView()
			(width, height) = (107, 160)
			borderCornerRadius = 10
		case .literatures:
			let posterImageView = PosterImageView()
			posterImageView.applyCornerRadius(0)
			imageView = posterImageView
			(width, height) = (107, 160)
		case .games:
			let posterImageView = PosterImageView()
			posterImageView.applyCornerRadius(22)
			imageView = posterImageView
			(width, height) = (128, 128)
			borderCornerRadius = 22
		case .characters:
			imageView = CharacterImageView(frame: .zero)
			(width, height) = (128, 128)
			borderCornerRadius = 64
		case .people:
			imageView = PersonImageView(frame: .zero)
			(width, height) = (128, 128)
			borderCornerRadius = 64
		case .studios:
			imageView = StudioLogoImageView(frame: .zero)
			(width, height) = (128, 128)
			borderCornerRadius = 64
		case .songs:
			imageView = AlbumImageView()
			(width, height) = (128, 128)
			borderCornerRadius = 10
		case nil:
			imageView = UIImageView()
			imageView.clipsToBounds = true
			imageView.layer.cornerCurve = .continuous
			imageView.layer.cornerRadius = 8
			(width, height) = (92, 132)
			borderCornerRadius = 8
		}

		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFill
		imageView.isUserInteractionEnabled = false
		self.subjectButton.addSubview(imageView)
		self.subjectImageView = imageView

		self.subjectImageConstraints.append(contentsOf: [
			self.subjectButton.widthAnchor.constraint(equalToConstant: width),
			self.subjectButton.heightAnchor.constraint(equalToConstant: height),
			imageView.topAnchor.constraint(equalTo: self.subjectButton.topAnchor),
			imageView.bottomAnchor.constraint(equalTo: self.subjectButton.bottomAnchor),
			imageView.leadingAnchor.constraint(equalTo: self.subjectButton.leadingAnchor),
			imageView.trailingAnchor.constraint(equalTo: self.subjectButton.trailingAnchor)
		])

		if kind == .literatures {
			let maskView = UIImageView(image: .bookMask)
			maskView.frame = CGRect(x: 0, y: 0, width: width, height: height)
			imageView.mask = maskView
			self.subjectMaskView = maskView
		}

		if let borderCornerRadius = borderCornerRadius {
			let borderView = BorderView()
			borderView.translatesAutoresizingMaskIntoConstraints = false
			borderView.cornerRadius = borderCornerRadius
			borderView.isUserInteractionEnabled = false
			self.subjectButton.addSubview(borderView)
			self.subjectBorderView = borderView

			self.subjectImageConstraints.append(contentsOf: [
				borderView.topAnchor.constraint(equalTo: imageView.topAnchor),
				borderView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
				borderView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
				borderView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor)
			])
		}

		NSLayoutConstraint.activate(self.subjectImageConstraints)
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
