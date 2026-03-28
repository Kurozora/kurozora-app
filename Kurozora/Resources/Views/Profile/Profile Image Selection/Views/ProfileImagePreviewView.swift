//
//  ProfileImagePreviewView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

protocol ProfileImagePreviewViewDelegate: AnyObject {
	func profileImagePreviewView(_ view: ProfileImagePreviewView, didUpdateMonogramInitials initials: String, generatedImage: UIImage)
	func profileImagePreviewView(_ view: ProfileImagePreviewView, didSelectEmoji emoji: String, generatedImage: UIImage)
	func profileImagePreviewView(_ view: ProfileImagePreviewView, didSelectKaomoji kaomoji: String, generatedImage: UIImage)
	func profileImagePreviewView(_ view: ProfileImagePreviewView, didUpdatePreview image: UIImage)
	func profileImagePreviewViewDidRequestEditMonogram(_ view: ProfileImagePreviewView)
	func profileImagePreviewViewDidRequestEditEmoji(_ view: ProfileImagePreviewView)
	func profileImagePreviewViewDidRequestEditKaomoji(_ view: ProfileImagePreviewView)
	func profileImagePreviewViewDidRequestDelete(_ view: ProfileImagePreviewView)
}

class ProfileImagePreviewView: UIView {
	// MARK: - Properties
	private let imageKind: ImageKind

	weak var delegate: ProfileImagePreviewViewDelegate?

	var placeholderImage: UIImage?

	var monogramInitials: String = "AB"
	var monogramBackgroundColor: UIColor = .kurozora
	var monogramFontStyle: MonogramFontStyle = .defaultStyle
	var monogramFontWeightValue: CGFloat = UIFont.Weight.bold.rawValue

	var emojiBackgroundColor: UIColor = .kurozora
	var selectedEmoji: String?

	var kaomojiBackgroundColor: UIColor = .kurozora
	var selectedKaomoji: String?

	var activePreviewSource: ProfileImageSource?
	private(set) var isUpdatingMonogramPreview: Bool = false

	/// Closure injected by the orchestrator to generate monogram images
	/// without a direct dependency on `MonogramProfileImageSourceView`.
	var generateMonogramImage: (() -> UIImage)?

	// MARK: - Views
	private(set) lazy var previewImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.backgroundColor = .clear
		imageView.isUserInteractionEnabled = true
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.previewTapped))
		imageView.addGestureRecognizer(tapGesture)
		return imageView
	}()

	private(set) lazy var monogramInitialsLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		label.adjustsFontSizeToFitWidth = true
		label.minimumScaleFactor = 0.5
		label.numberOfLines = 1
		label.textColor = .white
		label.isHidden = true
		return label
	}()

	private lazy var monogramTextField: UITextField = {
		let textField = UITextField()
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.isHidden = true
		textField.alpha = 0
		textField.font = UIFont.monogramFont(style: self.monogramFontStyle, size: 50, weight: UIFont.Weight(rawValue: self.monogramFontWeightValue))
		textField.textAlignment = .center
		textField.adjustsFontSizeToFitWidth = true
		textField.minimumFontSize = 25
		textField.delegate = self
		textField.backgroundColor = .clear
		textField.textColor = .white
		textField.keyboardType = .asciiCapable
		textField.autocapitalizationType = .allCharacters
		textField.returnKeyType = .done
		return textField
	}()

	private(set) lazy var deleteButton: UIButton = {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.isHidden = true
		button.alpha = 0
		button.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
		button.accessibilityLabel = String(localized: "Remove image")

		if #available(iOS 26.0, *) {
			var config = UIButton.Configuration.glass()
			config.image = UIImage(systemName: "xmark")?.withConfiguration(UIImage.SymbolConfiguration(scale: .small))
			config.cornerStyle = .capsule
			button.configuration = config
		} else {
			button.backgroundColor = UIColor(white: 0.333, alpha: 1.0)
			button.tintColor = UIColor(white: 0.5, alpha: 1.0)
			button.configuration = {
				var config = UIButton.Configuration.plain()
				config.image = UIImage(systemName: "xmark")?.withConfiguration(UIImage.SymbolConfiguration(scale: .small))
				return config
			}()
			button.layerCornerRadius = 12
		}

		NSLayoutConstraint.activate([
			button.widthAnchor.constraint(equalToConstant: 24),
			button.heightAnchor.constraint(equalToConstant: 24)
		])

		button.addTarget(self, action: #selector(self.deleteButtonTapped), for: .touchUpInside)
		return button
	}()

	private(set) lazy var emojiTextField: UITextField = {
		let textField = EmojiTextField()
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.isHidden = true
		textField.alpha = 0
		textField.delegate = self
		textField.backgroundColor = .clear
		textField.textColor = .clear
		textField.tintColor = .clear
		return textField
	}()

	// MARK: - Initializers
	init(imageKind: ImageKind = .profile) {
		self.imageKind = imageKind
		super.init(frame: .zero)
		self.configureViews()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Setup
	private func configureViews() {
		let previewWidth: CGFloat
		let previewHeight: CGFloat
		let cornerRadius: CGFloat

		switch self.imageKind {
		case .profile:
			previewWidth = 125
			previewHeight = 125
			cornerRadius = 62.5
		case .banner:
			previewWidth = 250
			previewHeight = 83
			cornerRadius = 12
		}

		self.previewImageView.layerCornerRadius = cornerRadius

		self.addSubview(self.previewImageView)
		self.addSubview(self.monogramInitialsLabel)
		self.addSubview(self.monogramTextField)
		self.addSubview(self.emojiTextField)
		self.addSubview(self.deleteButton)

		NSLayoutConstraint.activate([
			self.previewImageView.topAnchor.constraint(equalTo: self.topAnchor),
			self.previewImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			self.previewImageView.widthAnchor.constraint(equalToConstant: previewWidth),
			self.previewImageView.heightAnchor.constraint(equalToConstant: previewHeight),
			self.previewImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

			self.monogramInitialsLabel.centerXAnchor.constraint(equalTo: self.previewImageView.centerXAnchor),
			self.monogramInitialsLabel.centerYAnchor.constraint(equalTo: self.previewImageView.centerYAnchor),
			self.monogramInitialsLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.previewImageView.leadingAnchor, constant: 4),
			self.monogramInitialsLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.previewImageView.trailingAnchor, constant: -4),
			self.monogramInitialsLabel.topAnchor.constraint(greaterThanOrEqualTo: self.previewImageView.topAnchor, constant: 4),
			self.monogramInitialsLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.previewImageView.bottomAnchor, constant: -4),

			self.monogramTextField.topAnchor.constraint(equalTo: self.previewImageView.topAnchor),
			self.monogramTextField.leadingAnchor.constraint(equalTo: self.previewImageView.leadingAnchor),
			self.monogramTextField.trailingAnchor.constraint(equalTo: self.previewImageView.trailingAnchor),
			self.monogramTextField.bottomAnchor.constraint(equalTo: self.previewImageView.bottomAnchor),

			self.emojiTextField.topAnchor.constraint(equalTo: self.previewImageView.topAnchor),
			self.emojiTextField.leadingAnchor.constraint(equalTo: self.previewImageView.leadingAnchor),
			self.emojiTextField.trailingAnchor.constraint(equalTo: self.previewImageView.trailingAnchor),
			self.emojiTextField.bottomAnchor.constraint(equalTo: self.previewImageView.bottomAnchor),

			self.deleteButton.topAnchor.constraint(equalTo: self.previewImageView.topAnchor, constant: -4),
			self.deleteButton.trailingAnchor.constraint(equalTo: self.previewImageView.trailingAnchor, constant: 4)
		])
	}

	// MARK: - Monogram Preview
	func showMonogramTextField() {
		let textColor: UIColor = self.monogramBackgroundColor.isLight ? .black : .white

		if self.activePreviewSource != .monogram {
			self.previewImageView.image = nil
			self.previewImageView.backgroundColor = self.monogramBackgroundColor

			let displayInitials = String(self.monogramInitials.prefix(3)).uppercased()
			self.monogramInitialsLabel.text = displayInitials
			self.monogramInitialsLabel.font = UIFont.monogramFont(style: self.monogramFontStyle, size: 50, weight: UIFont.Weight(rawValue: self.monogramFontWeightValue))
			self.monogramInitialsLabel.textColor = textColor
			self.monogramInitialsLabel.isHidden = false

			self.activePreviewSource = .monogram

			if let image = self.generateMonogramImage?() {
				self.delegate?.profileImagePreviewView(self, didUpdatePreview: image)
			}
		}

		self.monogramTextField.font = UIFont.monogramFont(style: self.monogramFontStyle, size: 50, weight: UIFont.Weight(rawValue: self.monogramFontWeightValue))
		self.monogramTextField.textColor = textColor
		self.monogramTextField.text = self.monogramInitials
		self.monogramTextField.isHidden = false
		self.monogramTextField.alpha = 1
		self.monogramInitialsLabel.isHidden = true
		self.monogramTextField.becomeFirstResponder()
	}

	func hideMonogramTextField() {
		self.monogramTextField.resignFirstResponder()
		self.monogramTextField.isHidden = true
		self.monogramTextField.alpha = 0
	}

	func updateMonogramPreview() {
		self.isUpdatingMonogramPreview = true
		defer { self.isUpdatingMonogramPreview = false }

		let textColor: UIColor = self.monogramBackgroundColor.isLight ? .black : .white

		self.activePreviewSource = .monogram
		self.monogramInitialsLabel.isHidden = false

		self.monogramTextField.font = UIFont.monogramFont(style: self.monogramFontStyle, size: 50, weight: UIFont.Weight(rawValue: self.monogramFontWeightValue))
		self.monogramTextField.textColor = textColor

		let displayInitials = String(self.monogramInitials.prefix(3)).uppercased()
		self.monogramInitialsLabel.text = displayInitials
		self.monogramInitialsLabel.textColor = textColor

		let font = UIFont.monogramFont(style: self.monogramFontStyle, size: 50, weight: UIFont.Weight(rawValue: self.monogramFontWeightValue))
		self.monogramInitialsLabel.font = font

		self.previewImageView.backgroundColor = self.monogramBackgroundColor
		self.previewImageView.image = nil

		if let image = self.generateMonogramImage?() {
			self.delegate?.profileImagePreviewView(self, didUpdatePreview: image)
		}
	}

	// MARK: - Emoji Preview
	func showEmojiTextField() {
		if self.activePreviewSource != .emoji {
			self.previewImageView.image = nil
			self.previewImageView.backgroundColor = self.emojiBackgroundColor
			self.monogramInitialsLabel.isHidden = true
			self.activePreviewSource = .emoji
		}

		self.emojiTextField.isHidden = false
		self.emojiTextField.alpha = 1
		self.emojiTextField.text = ""
		self.emojiTextField.becomeFirstResponder()
	}

	func hideEmojiTextField() {
		self.emojiTextField.resignFirstResponder()
		self.emojiTextField.isHidden = true
		self.emojiTextField.alpha = 0
	}

	// MARK: - Delete Button
	func updateDeleteButtonVisibility(animated: Bool = true) {
		let hasCustomImage: Bool
		if self.activePreviewSource != nil {
			hasCustomImage = true
		} else if let currentImage = self.previewImageView.image, let placeholder = self.placeholderImage {
			hasCustomImage = !currentImage.isEqual(to: placeholder)
		} else {
			hasCustomImage = self.previewImageView.image != nil && self.placeholderImage != nil
		}
		self.setDeleteButtonVisible(hasCustomImage, animated: animated)
	}

	private func setDeleteButtonVisible(_ visible: Bool, animated: Bool) {
		if visible == !self.deleteButton.isHidden && self.deleteButton.alpha == (visible ? 1 : 0) {
			return
		}

		if visible {
			self.deleteButton.isHidden = false
		}

		if animated {
			UIView.animate(
				withDuration: 0.45,
				delay: 0,
				usingSpringWithDamping: 0.6,
				initialSpringVelocity: 0.8,
				options: [.curveEaseInOut]
			) {
				self.deleteButton.alpha = visible ? 1 : 0
				self.deleteButton.transform = visible ? .identity : CGAffineTransform(scaleX: 0.01, y: 0.01)
			} completion: { _ in
				if !visible {
					self.deleteButton.isHidden = true
				}
			}
		} else {
			self.deleteButton.alpha = visible ? 1 : 0
			self.deleteButton.transform = visible ? .identity : CGAffineTransform(scaleX: 0.01, y: 0.01)
			self.deleteButton.isHidden = !visible
		}
	}

	// MARK: - Animations
	/// Plays a horizontal shake animation on the preview image to indicate rejected input.
	private func shakePreviewImage() {
		let animation = CAKeyframeAnimation(keyPath: "position.x")
		animation.values = [0, -10, 10, -10, 10, -5, 5, 0]
		animation.keyTimes = [0, 0.1, 0.25, 0.4, 0.55, 0.7, 0.85, 1]
		animation.duration = 0.4
		animation.isAdditive = true
		self.previewImageView.layer.add(animation, forKey: "shake")
	}

	// MARK: - Actions
	@objc private func deleteButtonTapped() {
		self.delegate?.profileImagePreviewViewDidRequestDelete(self)
	}

	@objc private func previewTapped() {
		switch self.activePreviewSource {
		case .monogram:
			self.delegate?.profileImagePreviewViewDidRequestEditMonogram(self)
		case .emoji:
			self.delegate?.profileImagePreviewViewDidRequestEditEmoji(self)
		case .kaomoji:
			self.delegate?.profileImagePreviewViewDidRequestEditKaomoji(self)
		default:
			break
		}
	}
}

// MARK: - UITextFieldDelegate
extension ProfileImagePreviewView: UITextFieldDelegate {
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		if textField === self.emojiTextField {
			guard !string.isEmpty else { return false }
			self.activePreviewSource = .emoji
			self.monogramInitialsLabel.isHidden = true
			let emoji = String(string.prefix(1))
			self.selectedEmoji = emoji
			self.hideEmojiTextField()

			// Delegate notifies orchestrator, which generates the image
			self.delegate?.profileImagePreviewView(self, didSelectEmoji: emoji, generatedImage: UIImage())
			return false
		}

		let currentText = textField.text ?? ""
		guard let stringRange = Range(range, in: currentText) else { return false }
		let updatedText = currentText.replacingCharacters(in: stringRange, with: string.uppercased())

		if updatedText.count <= 3 {
			if ProfanityFilter.shared.containsProfanity(updatedText) {
				self.shakePreviewImage()
				return false
			}

			textField.text = updatedText
			self.monogramInitials = updatedText

			// Delegate notifies orchestrator, which syncs to source view and generates image
			if let image = self.generateMonogramImage?() {
				self.delegate?.profileImagePreviewView(self, didUpdateMonogramInitials: updatedText, generatedImage: image)
			}
			return false
		}
		return false
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField === self.emojiTextField {
			self.hideEmojiTextField()
			return true
		}
		self.hideMonogramTextField()
		self.updateMonogramPreview()
		return true
	}

	func textFieldDidEndEditing(_ textField: UITextField) {
		if textField === self.emojiTextField {
			self.hideEmojiTextField()
			return
		}
		self.hideMonogramTextField()
		self.updateMonogramPreview()
	}
}
