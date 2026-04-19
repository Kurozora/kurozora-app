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

	var selectedSource: ProfileImageSource?
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

	private lazy var monogramTextField: MonogramTextField = {
		let textField = MonogramTextField()
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.clipsToBounds = true
		textField.font = UIFont.monogramFont(style: self.monogramFontStyle, size: 50, weight: UIFont.Weight(rawValue: self.monogramFontWeightValue))
		textField.textAlignment = .center
		textField.adjustsFontSizeToFitWidth = true
		textField.minimumFontSize = 25
		textField.delegate = self
		textField.backgroundColor = .clear
		textField.textColor = .clear
		textField.tintColor = .clear
		textField.keyboardType = .default
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

		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
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
		textField.clipsToBounds = true
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

			self.monogramTextField.widthAnchor.constraint(equalToConstant: 0),
			self.monogramTextField.heightAnchor.constraint(equalToConstant: 0),
			self.monogramTextField.centerXAnchor.constraint(equalTo: self.previewImageView.centerXAnchor),
			self.monogramTextField.centerYAnchor.constraint(equalTo: self.previewImageView.centerYAnchor),

			self.emojiTextField.widthAnchor.constraint(equalToConstant: 0),
			self.emojiTextField.heightAnchor.constraint(equalToConstant: 0),
			self.emojiTextField.centerXAnchor.constraint(equalTo: self.previewImageView.centerXAnchor),
			self.emojiTextField.centerYAnchor.constraint(equalTo: self.previewImageView.centerYAnchor),

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
		self.monogramTextField.text = self.monogramInitials
		self.monogramTextField.becomeFirstResponder()
	}

	func hideMonogramTextField() {
		self.monogramTextField.resignFirstResponder()
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

		self.emojiTextField.text = ""
		self.emojiTextField.becomeFirstResponder()
	}

	func hideEmojiTextField() {
		self.emojiTextField.resignFirstResponder()
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
		if visible == !self.deleteButton.isHidden, self.deleteButton.alpha == (visible ? 1 : 0) {
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

	func resetToPlaceholder() {
		self.performReplaceTransition {
			self.previewImageView.image = self.placeholderImage
			self.previewImageView.backgroundColor = .clear
			self.monogramInitialsLabel.isHidden = true
		}
		self.activePreviewSource = nil
		self.updateDeleteButtonVisibility(animated: true)
	}

	// MARK: - Animations
	/// Tracks in-flight snapshot views so rapid taps can interrupt a previous transition.
	private var activeTransitionSnapshots: [UIView] = []

	/// Performs a blur replace content transition on the preview area.
	///
	/// The outgoing content blurs out while the incoming content deblurs in,
	/// both layered with a subtle scale animation for depth. On earlier versions, the
	/// transition falls back to a simple scale + alpha fade.
	func performReplaceTransition(changes: @escaping () -> Void) {
		// Remove any in-flight snapshots from a previous interrupted transition
		self.activeTransitionSnapshots.forEach { $0.removeFromSuperview() }
		self.activeTransitionSnapshots.removeAll()

		// Reset any residual transform/alpha from a previous interrupted animation
		self.previewImageView.layer.removeAllAnimations()
		self.monogramInitialsLabel.layer.removeAllAnimations()
		self.previewImageView.transform = .identity
		self.previewImageView.alpha = 1
		self.monogramInitialsLabel.transform = .identity
		self.monogramInitialsLabel.alpha = 1

		// Snapshot the current image view
		let imageSnapshot = UIView(frame: self.previewImageView.frame)
		imageSnapshot.clipsToBounds = true
		imageSnapshot.layer.cornerRadius = self.previewImageView.layer.cornerRadius
		imageSnapshot.backgroundColor = self.previewImageView.backgroundColor

		if let image = self.previewImageView.image {
			let imageView = UIImageView(image: image)
			imageView.frame = imageSnapshot.bounds
			imageView.contentMode = .scaleAspectFill
			imageView.clipsToBounds = true
			imageSnapshot.addSubview(imageView)
		}

		self.insertSubview(imageSnapshot, belowSubview: self.deleteButton)
		self.activeTransitionSnapshots.append(imageSnapshot)

		// Snapshot the monogram label if visible
		var labelSnapshot: UIView?
		if !self.monogramInitialsLabel.isHidden {
			let snapshot = UILabel()
			snapshot.frame = self.monogramInitialsLabel.frame
			snapshot.text = self.monogramInitialsLabel.text
			snapshot.font = self.monogramInitialsLabel.font
			snapshot.textColor = self.monogramInitialsLabel.textColor
			snapshot.textAlignment = .center
			snapshot.adjustsFontSizeToFitWidth = true
			snapshot.minimumScaleFactor = 0.5
			self.insertSubview(snapshot, belowSubview: self.deleteButton)
			self.activeTransitionSnapshots.append(snapshot)
			labelSnapshot = snapshot
		}

		// Capture pixel-accurate outgoing image for blur generation before content swap
		let outgoingImage: UIImage = self.capturePreviewSnapshot()

		// Apply the content changes immediately (underneath the snapshots)
		changes()

		self.performBlurReplaceTransition(
			imageSnapshot: imageSnapshot,
			labelSnapshot: labelSnapshot,
			outgoingImage: outgoingImage
		)
	}

	/// Blur-based replace transition using pre-rendered `CIGaussianBlur`
	/// snapshots for a pure pixel blur with zero tint and smooth keyframe timing.
	private func performBlurReplaceTransition(imageSnapshot: UIView, labelSnapshot: UIView?, outgoingImage: UIImage) {
		let blurRadius: CGFloat = 20
		let duration: TimeInterval = 0.65
		let scaleDown = CGAffineTransform(scaleX: 0.90, y: 0.90)

		// Outgoing blur from pre-captured old content
		let outgoingBlurred = self.blurredImage(outgoingImage, radius: blurRadius)

		let outgoingBlurView = UIImageView(image: outgoingBlurred)
		outgoingBlurView.frame = self.previewImageView.frame
		outgoingBlurView.contentMode = .scaleAspectFill
		outgoingBlurView.clipsToBounds = true
		outgoingBlurView.layer.cornerRadius = self.previewImageView.layer.cornerRadius
		outgoingBlurView.alpha = 0

		// Capture incoming content snapshots
		let incomingSharpImage = self.capturePreviewSnapshot()
		let incomingBlurred = self.blurredImage(incomingSharpImage, radius: blurRadius)

		let incomingSharpView = UIImageView(image: incomingSharpImage)
		incomingSharpView.frame = self.previewImageView.frame
		incomingSharpView.contentMode = .scaleAspectFill
		incomingSharpView.clipsToBounds = true
		incomingSharpView.layer.cornerRadius = self.previewImageView.layer.cornerRadius
		incomingSharpView.alpha = 0
		incomingSharpView.transform = scaleDown

		let incomingBlurView = UIImageView(image: incomingBlurred)
		incomingBlurView.frame = self.previewImageView.frame
		incomingBlurView.contentMode = .scaleAspectFill
		incomingBlurView.clipsToBounds = true
		incomingBlurView.layer.cornerRadius = self.previewImageView.layer.cornerRadius
		incomingBlurView.alpha = 0
		incomingBlurView.transform = scaleDown

		// Hide real content
		self.previewImageView.alpha = 0
		self.monogramInitialsLabel.alpha = 0

		// Z-order (bottom to top): incoming sharp -> incoming blur -> outgoing sharp -> outgoing blur -> deleteButton
		self.insertSubview(incomingSharpView, belowSubview: self.deleteButton)
		self.insertSubview(incomingBlurView, aboveSubview: incomingSharpView)
		self.insertSubview(imageSnapshot, aboveSubview: incomingBlurView)
		self.insertSubview(outgoingBlurView, aboveSubview: imageSnapshot)

		self.activeTransitionSnapshots.append(contentsOf: [outgoingBlurView, incomingBlurView, incomingSharpView])

		UIView.animateKeyframes(withDuration: duration, delay: 0, options: [.calculationModeCubic]) {
			// Outgoing sharp snapshot: fade out in first 40%
			UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.40) {
				imageSnapshot.alpha = 0
				labelSnapshot?.alpha = 0
			}

			// Outgoing blur: fade in first 45%, then out remaining 55%
			UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.45) {
				outgoingBlurView.alpha = 1
			}
			UIView.addKeyframe(withRelativeStartTime: 0.45, relativeDuration: 0.55) {
				outgoingBlurView.alpha = 0
			}

			// Outgoing scale: shrink over full duration
			UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1.0) {
				imageSnapshot.transform = scaleDown
				labelSnapshot?.transform = scaleDown
				outgoingBlurView.transform = scaleDown
			}

			// Incoming blur: fade in during first half, then out
			UIView.addKeyframe(withRelativeStartTime: 0.30, relativeDuration: 0.25) {
				incomingBlurView.alpha = 1
			}
			UIView.addKeyframe(withRelativeStartTime: 0.55, relativeDuration: 0.45) {
				incomingBlurView.alpha = 0
			}

			// Incoming sharp: fade in during second half
			UIView.addKeyframe(withRelativeStartTime: 0.45, relativeDuration: 0.55) {
				incomingSharpView.alpha = 1
			}

			// Incoming scale: grow to identity over full duration
			UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1.0) {
				incomingBlurView.transform = .identity
				incomingSharpView.transform = .identity
			}
		} completion: { [weak self] _ in
			guard let self else { return }
			// Restore real content visibility
			self.previewImageView.alpha = 1
			self.monogramInitialsLabel.alpha = 1
			self.previewImageView.transform = .identity
			self.monogramInitialsLabel.transform = .identity

			imageSnapshot.removeFromSuperview()
			labelSnapshot?.removeFromSuperview()
			outgoingBlurView.removeFromSuperview()
			incomingBlurView.removeFromSuperview()
			incomingSharpView.removeFromSuperview()
			self.activeTransitionSnapshots.removeAll {
				$0 === imageSnapshot || $0 === labelSnapshot || $0 === outgoingBlurView || $0 === incomingBlurView || $0 === incomingSharpView
			}
		}
	}

	/// Renders the current preview content (image + monogram) to a UIImage.
	private func capturePreviewSnapshot() -> UIImage {
		let bounds = self.previewImageView.bounds
		let origin = self.previewImageView.frame.origin
		let renderer = UIGraphicsImageRenderer(bounds: bounds)
		return renderer.image { context in
			self.previewImageView.layer.render(in: context.cgContext)
			if !self.monogramInitialsLabel.isHidden {
				context.cgContext.saveGState()
				context.cgContext.translateBy(
					x: self.monogramInitialsLabel.frame.origin.x - origin.x,
					y: self.monogramInitialsLabel.frame.origin.y - origin.y
				)
				self.monogramInitialsLabel.layer.render(in: context.cgContext)
				context.cgContext.restoreGState()
			}
		}
	}

	/// Applies a Gaussian blur to the image. Returns the original if blurring fails.
	private func blurredImage(_ image: UIImage, radius: CGFloat) -> UIImage {
		guard let ciImage = CIImage(image: image),
		      let filter = CIFilter(name: "CIGaussianBlur") else { return image }
		filter.setValue(ciImage, forKey: kCIInputImageKey)
		filter.setValue(radius, forKey: kCIInputRadiusKey)
		guard let output = filter.outputImage else { return image }
		let cropped = output.cropped(to: ciImage.extent)
		let context = CIContext(options: [.useSoftwareRenderer: false])
		guard let cgImage = context.createCGImage(cropped, from: cropped.extent) else { return image }
		return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
	}

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
		switch self.selectedSource {
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
			self.monogramInitialsLabel.text = updatedText

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
