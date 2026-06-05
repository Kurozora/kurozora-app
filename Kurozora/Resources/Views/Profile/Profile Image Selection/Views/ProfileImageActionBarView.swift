//
//  ProfileImageActionBarView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Photos
import UIKit

protocol ProfileImageActionBarViewDelegate: AnyObject {
	func profileImageActionBarViewDidRequestEditInitials(_ view: ProfileImageActionBarView)
	func profileImageActionBarViewDidRequestEmojiSelector(_ view: ProfileImageActionBarView)
	func profileImageActionBarViewDidRequestKaomojiSelector(_ view: ProfileImageActionBarView)
	func profileImageActionBarViewDidRequestCharacterSearch(_ view: ProfileImageActionBarView)
	func profileImageActionBarViewDidRequestCrop(_ view: ProfileImageActionBarView)
	func profileImageActionBarView(_ view: ProfileImageActionBarView, didSelectColor color: UIColor, forSource source: ProfileImageSource)
	func profileImageActionBarView(_ view: ProfileImageActionBarView, didSelectFontStyle fontStyle: MonogramFontStyle, weightValue: CGFloat)
	func profileImageActionBarViewDidDismissPresentation(_ view: ProfileImageActionBarView)
}

class ProfileImageActionBarView: UIView {
	// MARK: - Properties
	weak var delegate: ProfileImageActionBarViewDelegate?
	weak var parentViewController: UIViewController?

	private(set) var selectedSource: ProfileImageSource = .monogram

	/// State injected by the orchestrator for picker presentation.
	var currentColorForPicker: UIColor = .kurozora
	var monogramState: (initials: String, backgroundColor: UIColor, fontStyle: MonogramFontStyle, weightValue: CGFloat)?

	// MARK: - Views
	private lazy var monogramEditInitialsButton: UIButton = .makePillButton(
		systemName: "character.cursor.ibeam",
		accessibilityLabel: L10n.editInitials,
		target: self,
		action: #selector(self.monogramEditInitialsButtonTapped)
	)

	private lazy var monogramFontWidthButton: UIButton = .makePillButton(
		systemName: "textformat.size",
		accessibilityLabel: L10n.fontAndWidth,
		target: self,
		action: #selector(self.monogramFontWidthButtonTapped)
	)

	private lazy var colorButton: UIButton = .makePillButton(
		systemName: "paintpalette",
		accessibilityLabel: L10n.color,
		target: self,
		action: #selector(self.colorButtonTapped)
	)

	private(set) lazy var characterSearchButton: UIButton = .makePillButton(
		systemName: "person.2.fill",
		accessibilityLabel: L10n.characterSearch,
		target: self,
		action: #selector(self.characterSearchButtonTapped)
	)

	private(set) lazy var cropButton: UIButton = .makePillButton(
		systemName: "crop",
		accessibilityLabel: L10n.crop,
		target: self,
		action: #selector(self.cropButtonTapped)
	)

	private lazy var emojiSelectorButton: UIButton = .makePillButton(
		systemName: "face.smiling",
		accessibilityLabel: L10n.changeEmoji,
		target: self,
		action: #selector(self.emojiSelectorButtonTapped)
	)

	private lazy var kaomojiSelectorButton: UIButton = .makePillButton(
		title: "^_^",
		accessibilityLabel: L10n.changeKaomoji,
		target: self,
		action: #selector(self.kaomojiSelectorButtonTapped)
	)

	private lazy var monogramButtonStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .horizontal
		stackView.distribution = .fill
		stackView.spacing = 12
		stackView.isHidden = true
		return stackView
	}()

	private lazy var emojiButtonStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .horizontal
		stackView.distribution = .fill
		stackView.spacing = 12
		stackView.isHidden = true
		return stackView
	}()

	private lazy var kaomojiButtonStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .horizontal
		stackView.distribution = .fill
		stackView.spacing = 12
		stackView.isHidden = true
		return stackView
	}()

	private lazy var photosButtonStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .horizontal
		stackView.distribution = .fill
		stackView.spacing = 12
		stackView.isHidden = true
		return stackView
	}()

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.configureViews()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Setup
	private func configureViews() {
		self.addSubview(self.monogramButtonStackView)
		self.addSubview(self.emojiButtonStackView)
		self.addSubview(self.kaomojiButtonStackView)
		self.addSubview(self.photosButtonStackView)

		self.monogramButtonStackView.addArrangedSubview(self.monogramEditInitialsButton)
		self.monogramButtonStackView.addArrangedSubview(self.monogramFontWidthButton)
		self.monogramButtonStackView.addArrangedSubview(self.colorButton)

		self.emojiButtonStackView.addArrangedSubview(self.emojiSelectorButton)

		self.kaomojiButtonStackView.addArrangedSubview(self.kaomojiSelectorButton)

		self.photosButtonStackView.addArrangedSubview(self.characterSearchButton)
		self.photosButtonStackView.addArrangedSubview(self.cropButton)

		NSLayoutConstraint.activate([
			self.photosButtonStackView.topAnchor.constraint(equalTo: self.topAnchor),
			self.photosButtonStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			self.photosButtonStackView.heightAnchor.constraint(equalToConstant: 44),

			self.monogramButtonStackView.topAnchor.constraint(equalTo: self.topAnchor),
			self.monogramButtonStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			self.monogramButtonStackView.heightAnchor.constraint(equalToConstant: 44),

			self.emojiButtonStackView.topAnchor.constraint(equalTo: self.topAnchor),
			self.emojiButtonStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			self.emojiButtonStackView.heightAnchor.constraint(equalToConstant: 44),

			self.kaomojiButtonStackView.topAnchor.constraint(equalTo: self.topAnchor),
			self.kaomojiButtonStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			self.kaomojiButtonStackView.heightAnchor.constraint(equalToConstant: 44),

			self.characterSearchButton.widthAnchor.constraint(equalToConstant: 72),
			self.characterSearchButton.heightAnchor.constraint(equalToConstant: 44),
			self.cropButton.widthAnchor.constraint(equalToConstant: 72),
			self.cropButton.heightAnchor.constraint(equalToConstant: 44),
			self.monogramEditInitialsButton.widthAnchor.constraint(equalToConstant: 72),
			self.monogramEditInitialsButton.heightAnchor.constraint(equalToConstant: 44),
			self.monogramFontWidthButton.widthAnchor.constraint(equalToConstant: 72),
			self.monogramFontWidthButton.heightAnchor.constraint(equalToConstant: 44),
			self.colorButton.widthAnchor.constraint(equalToConstant: 72),
			self.colorButton.heightAnchor.constraint(equalToConstant: 44),
			self.emojiSelectorButton.widthAnchor.constraint(equalToConstant: 72),
			self.emojiSelectorButton.heightAnchor.constraint(equalToConstant: 44),
			self.kaomojiSelectorButton.widthAnchor.constraint(equalToConstant: 72),
			self.kaomojiSelectorButton.heightAnchor.constraint(equalToConstant: 44)
		])
	}

	// MARK: - Public API
	func updateVisibleButtons(for source: ProfileImageSource) {
		self.selectedSource = source

		self.photosButtonStackView.isHidden = true
		self.monogramButtonStackView.isHidden = true
		self.emojiButtonStackView.isHidden = true
		self.kaomojiButtonStackView.isHidden = true

		switch source {
		case .photos:
			self.photosButtonStackView.isHidden = false
			self.cropButton.isHidden = false
			self.characterSearchButton.isHidden = true
		case .emoji:
			self.emojiButtonStackView.isHidden = false
			self.emojiButtonStackView.addArrangedSubview(self.colorButton)
		case .kaomoji:
			self.kaomojiButtonStackView.isHidden = false
			self.kaomojiButtonStackView.addArrangedSubview(self.colorButton)
		case .characters:
			self.photosButtonStackView.isHidden = false
			self.cropButton.isHidden = false
			self.characterSearchButton.isHidden = false
		case .monogram:
			self.monogramButtonStackView.isHidden = false
			self.monogramButtonStackView.addArrangedSubview(self.colorButton)
		}
	}

	func setCropButtonHidden(_ hidden: Bool) {
		self.cropButton.isHidden = hidden
	}

	func setPhotosButtonStackHidden(_ hidden: Bool) {
		self.photosButtonStackView.isHidden = hidden
	}

	// MARK: - Actions
	@objc private func monogramEditInitialsButtonTapped() {
		self.delegate?.profileImageActionBarViewDidRequestEditInitials(self)
	}

	@objc private func emojiSelectorButtonTapped() {
		self.delegate?.profileImageActionBarViewDidRequestEmojiSelector(self)
	}

	@objc private func kaomojiSelectorButtonTapped() {
		self.delegate?.profileImageActionBarViewDidRequestKaomojiSelector(self)
	}

	@objc private func characterSearchButtonTapped() {
		self.delegate?.profileImageActionBarViewDidRequestCharacterSearch(self)
	}

	@objc private func cropButtonTapped() {
		self.delegate?.profileImageActionBarViewDidRequestCrop(self)
	}

	@objc private func colorButtonTapped() {
		guard let parentViewController = self.parentViewController else { return }

		let colorPicker = UIColorPickerViewController()
		colorPicker.selectedColor = self.currentColorForPicker
		colorPicker.supportsAlpha = false
		colorPicker.delegate = self
		colorPicker.modalPresentationStyle = .popover
		colorPicker.presentationController?.delegate = self
		colorPicker.popoverPresentationController?.sourceView = self.colorButton

		parentViewController.present(colorPicker, animated: true)
	}

	@objc private func monogramFontWidthButtonTapped() {
		guard let parentViewController = self.parentViewController,
			  let state = self.monogramState else { return }

		let fontWidthVC = MonogramFontWidthViewController()
		fontWidthVC.initials = state.initials
		fontWidthVC.monogramBackgroundColor = state.backgroundColor
		fontWidthVC.selectedFontStyle = state.fontStyle
		fontWidthVC.selectedWeightValue = state.weightValue
		fontWidthVC.delegate = self

		if let popover = fontWidthVC.popoverPresentationController {
			popover.sourceView = self.monogramFontWidthButton
			popover.sourceRect = self.monogramFontWidthButton.bounds
		}

		fontWidthVC.presentationController?.delegate = self
		parentViewController.present(fontWidthVC, animated: true)
	}
}

// MARK: - UIColorPickerViewControllerDelegate
extension ProfileImageActionBarView: UIColorPickerViewControllerDelegate {
	func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
		self.delegate?.profileImageActionBarView(self, didSelectColor: viewController.selectedColor, forSource: self.selectedSource)
	}

	func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
		self.delegate?.profileImageActionBarView(self, didSelectColor: color, forSource: self.selectedSource)
	}
}

// MARK: - MonogramFontWidthViewControllerDelegate
extension ProfileImageActionBarView: MonogramFontWidthViewControllerDelegate {
	func monogramFontWidthViewController(_ viewController: MonogramFontWidthViewController, didSelectFontStyle fontStyle: MonogramFontStyle, weightValue: CGFloat) {
		self.delegate?.profileImageActionBarView(self, didSelectFontStyle: fontStyle, weightValue: weightValue)
	}
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension ProfileImageActionBarView: UIAdaptivePresentationControllerDelegate {
	func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
		self.delegate?.profileImageActionBarViewDidDismissPresentation(self)
	}
}
