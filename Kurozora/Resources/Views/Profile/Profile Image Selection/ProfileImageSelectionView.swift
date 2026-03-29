//
//  ProfileImageSelectionView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import Photos
import UIKit

protocol ProfileImageSelectionViewDelegate: AnyObject {
	func profileImageSelectionView(_ view: ProfileImageSelectionView, didSelectImage image: UIImage)
	func profileImageSelectionViewDidCancel(_ view: ProfileImageSelectionView)
	func profileImageSelectionViewDidRequestCamera(_ view: ProfileImageSelectionView)
	func profileImageSelectionViewDidRequestPhotos(_ view: ProfileImageSelectionView)
	func profileImageSelectionView(_ view: ProfileImageSelectionView, shouldShowManageAccessToolbar show: Bool)
	func profileImageSelectionViewDidRequestCharacterSearch(_ view: ProfileImageSelectionView)
	func profileImageSelectionViewDidRequestCrop(_ view: ProfileImageSelectionView)
	@available(iOS 18.1, macOS 15.1, visionOS 2.4, *)
	func profileImageSelectionViewDidRequestImagePlayground(_ view: ProfileImageSelectionView)
}

private struct SourceButtonEntry {
	let button: UIButton
	let containerView: UIView
	let iconImageView: UIImageView
	let iconLabel: UILabel?
}

class ProfileImageSelectionView: UIView {
	// MARK: - Properties
	private let imageKind: ImageKind

	weak var delegate: ProfileImageSelectionViewDelegate?
	weak var parentViewController: UIViewController? {
		didSet {
			self.photosProfileImageSourceView.parentViewController = self.parentViewController
			self.actionBarView.parentViewController = self.parentViewController
		}
	}

	var originalSelectedImage: UIImage?
	var placeholderImage: UIImage?
	var selectedSource: ProfileImageSource = .monogram
	private var isConfigured = false
	private var isProcessingActionBarUpdate = false

	// MARK: - Views
	private lazy var previewView: ProfileImagePreviewView = {
		let view = ProfileImagePreviewView(imageKind: self.imageKind)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.delegate = self
		view.generateMonogramImage = { [weak self] in
			self?.monogramProfileImageSourceView.generateMonogramImage() ?? UIImage()
		}
		return view
	}()

	private lazy var actionBarView: ProfileImageActionBarView = {
		let view = ProfileImageActionBarView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.delegate = self
		return view
	}()

	private lazy var sourceButtonScrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.showsHorizontalScrollIndicator = false
		scrollView.showsVerticalScrollIndicator = false
		return scrollView
	}()

	private let sourceButtonContainerView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private lazy var sourceButtonStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .horizontal
		stackView.distribution = .fill
		stackView.alignment = .center
		stackView.spacing = 12
		return stackView
	}()

	private var sourceButtonEntries: [SourceButtonEntry] = []

	private lazy var sectionContentView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .clear
		view.clipsToBounds = true
		return view
	}()

	/// Detached image view used by the photos source to stage loaded images
	/// without directly mutating the main preview during transitions.
	private let photosStagingImageView = UIImageView()

	private lazy var photosProfileImageSourceView: PhotosProfileImageSourceView = {
		let view = PhotosProfileImageSourceView(imageKind: self.imageKind)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.delegate = self
		view.previewImageView = self.photosStagingImageView
		return view
	}()

	lazy var monogramProfileImageSourceView: MonogramProfileImageSourceView = {
		let view = MonogramProfileImageSourceView(imageKind: self.imageKind)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.delegate = self
		view.isHidden = true
		return view
	}()

	lazy var emojiProfileImageSourceView: EmojiProfileImageSourceView = {
		let view = EmojiProfileImageSourceView(imageKind: self.imageKind)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.delegate = self
		view.imageBackgroundColor = self.previewView.emojiBackgroundColor
		view.isHidden = true
		return view
	}()

	lazy var kaomojiProfileImageSourceView: KaomojiProfileImageSourceView = {
		let view = KaomojiProfileImageSourceView(imageKind: self.imageKind)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.delegate = self
		view.imageBackgroundColor = self.previewView.kaomojiBackgroundColor
		view.isHidden = true
		return view
	}()

	/// Detached image view used by the character source to stage loaded images
	/// without directly mutating the main preview during transitions.
	private let characterStagingImageView = UIImageView()

	private lazy var characterProfileImageSourceView: CharacterProfileImageSourceView = {
		let view = CharacterProfileImageSourceView(imageKind: self.imageKind)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.delegate = self
		view.previewImageView = self.characterStagingImageView
		view.isHidden = true
		return view
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

	// MARK: - Configuration
	func configure(with image: UIImage?, placeholderImage: UIImage? = nil) {
		if let placeholderImage = placeholderImage {
			self.placeholderImage = placeholderImage
			self.previewView.placeholderImage = placeholderImage
		}
		self.previewView.previewImageView.image = image
		if image != nil {
			self.previewView.monogramInitialsLabel.isHidden = true
			self.previewView.previewImageView.backgroundColor = .clear
		}
		self.previewView.updateDeleteButtonVisibility(animated: false)
	}

	func reloadPhotos() {
		self.photosProfileImageSourceView.reloadPhotos()
	}

	func setOriginalSelectedImage(_ image: UIImage) {
		self.originalSelectedImage = image
		self.previewView.activePreviewSource = .photos
		if self.selectedSource == .photos {
			self.photosProfileImageSourceView.setOriginalSelectedImage(image)
		}
	}

	// MARK: - Setup
	private func configureViews() {
		self.addSubview(self.previewView)
		self.addSubview(self.actionBarView)
		self.addSubview(self.sourceButtonScrollView)
		self.sourceButtonScrollView.addSubview(self.sourceButtonContainerView)
		self.sourceButtonContainerView.addSubview(self.sourceButtonStackView)
		self.addSubview(self.sectionContentView)

		self.sectionContentView.addSubview(self.photosProfileImageSourceView)
		self.sectionContentView.addSubview(self.emojiProfileImageSourceView)
		self.sectionContentView.addSubview(self.kaomojiProfileImageSourceView)
		self.sectionContentView.addSubview(self.characterProfileImageSourceView)
		self.sectionContentView.addSubview(self.monogramProfileImageSourceView)

		NSLayoutConstraint.activate([
			// 1. Preview at top
			self.previewView.topAnchor.constraint(equalTo: self.topAnchor, constant: 32),
			self.previewView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			self.previewView.widthAnchor.constraint(equalToConstant: self.imageKind == .banner ? 250 : 125),

			// 2. Action bar below preview
			self.actionBarView.topAnchor.constraint(equalTo: self.previewView.bottomAnchor, constant: 16),
			self.actionBarView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.actionBarView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.actionBarView.heightAnchor.constraint(equalToConstant: 44),

			// 3. Source tab icons below action bar
			self.sourceButtonScrollView.topAnchor.constraint(equalTo: self.actionBarView.bottomAnchor, constant: 16),
			self.sourceButtonScrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.sourceButtonScrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.sourceButtonScrollView.heightAnchor.constraint(equalToConstant: 54),

			self.sourceButtonContainerView.topAnchor.constraint(equalTo: self.sourceButtonScrollView.topAnchor),
			self.sourceButtonContainerView.leadingAnchor.constraint(equalTo: self.sourceButtonScrollView.leadingAnchor),
			self.sourceButtonContainerView.trailingAnchor.constraint(equalTo: self.sourceButtonScrollView.trailingAnchor),
			self.sourceButtonContainerView.bottomAnchor.constraint(equalTo: self.sourceButtonScrollView.bottomAnchor),
			self.sourceButtonContainerView.heightAnchor.constraint(equalTo: self.sourceButtonScrollView.heightAnchor),

			self.sourceButtonContainerView.widthAnchor.constraint(greaterThanOrEqualTo: self.sourceButtonStackView.widthAnchor, constant: 32),

			self.sourceButtonStackView.topAnchor.constraint(equalTo: self.sourceButtonContainerView.topAnchor),
			self.sourceButtonStackView.bottomAnchor.constraint(equalTo: self.sourceButtonContainerView.bottomAnchor),
			self.sourceButtonStackView.centerXAnchor.constraint(equalTo: self.sourceButtonContainerView.centerXAnchor),
			self.sourceButtonStackView.leadingAnchor.constraint(greaterThanOrEqualTo: self.sourceButtonContainerView.leadingAnchor, constant: 16),
			self.sourceButtonStackView.trailingAnchor.constraint(lessThanOrEqualTo: self.sourceButtonContainerView.trailingAnchor, constant: -16),

			// 4. Grid fills remaining space
			self.sectionContentView.topAnchor.constraint(equalTo: self.sourceButtonScrollView.bottomAnchor),
			self.sectionContentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.sectionContentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.sectionContentView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

			self.photosProfileImageSourceView.topAnchor.constraint(equalTo: self.sectionContentView.topAnchor),
			self.photosProfileImageSourceView.leadingAnchor.constraint(equalTo: self.sectionContentView.leadingAnchor),
			self.photosProfileImageSourceView.trailingAnchor.constraint(equalTo: self.sectionContentView.trailingAnchor),
			self.photosProfileImageSourceView.bottomAnchor.constraint(equalTo: self.sectionContentView.bottomAnchor),

			self.emojiProfileImageSourceView.topAnchor.constraint(equalTo: self.sectionContentView.topAnchor),
			self.emojiProfileImageSourceView.leadingAnchor.constraint(equalTo: self.sectionContentView.leadingAnchor),
			self.emojiProfileImageSourceView.trailingAnchor.constraint(equalTo: self.sectionContentView.trailingAnchor),
			self.emojiProfileImageSourceView.bottomAnchor.constraint(equalTo: self.sectionContentView.bottomAnchor),

			self.kaomojiProfileImageSourceView.topAnchor.constraint(equalTo: self.sectionContentView.topAnchor),
			self.kaomojiProfileImageSourceView.leadingAnchor.constraint(equalTo: self.sectionContentView.leadingAnchor),
			self.kaomojiProfileImageSourceView.trailingAnchor.constraint(equalTo: self.sectionContentView.trailingAnchor),
			self.kaomojiProfileImageSourceView.bottomAnchor.constraint(equalTo: self.sectionContentView.bottomAnchor),

			self.monogramProfileImageSourceView.topAnchor.constraint(equalTo: self.sectionContentView.topAnchor),
			self.monogramProfileImageSourceView.leadingAnchor.constraint(equalTo: self.sectionContentView.leadingAnchor),
			self.monogramProfileImageSourceView.trailingAnchor.constraint(equalTo: self.sectionContentView.trailingAnchor),
			self.monogramProfileImageSourceView.bottomAnchor.constraint(equalTo: self.sectionContentView.bottomAnchor),

			self.characterProfileImageSourceView.topAnchor.constraint(equalTo: self.sectionContentView.topAnchor),
			self.characterProfileImageSourceView.leadingAnchor.constraint(equalTo: self.sectionContentView.leadingAnchor),
			self.characterProfileImageSourceView.trailingAnchor.constraint(equalTo: self.sectionContentView.trailingAnchor),
			self.characterProfileImageSourceView.bottomAnchor.constraint(equalTo: self.sectionContentView.bottomAnchor)
		])

		let containerWidthConstraint = self.sourceButtonContainerView.widthAnchor.constraint(equalTo: self.sourceButtonScrollView.frameLayoutGuide.widthAnchor)
		containerWidthConstraint.priority = .defaultLow
		containerWidthConstraint.isActive = true

		self.configureMonogram()
		self.setupSourceButtons()

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
			guard let self = self else { return }
			self.selectedSource = .photos
			self.selectSourceButton(at: 0)
			self.updateSectionContent(for: .photos)
			self.isConfigured = true
		}
	}

	// MARK: - Source Buttons
	private func setupSourceButtons() {
		self.sourceButtonEntries.forEach { $0.button.removeFromSuperview() }
		self.sourceButtonEntries.removeAll()

		for (index, source) in ProfileImageSource.allCases.enumerated() {
			let entry = self.createSourceButton(for: source, tag: index)
			self.sourceButtonStackView.addArrangedSubview(entry.button)
			self.sourceButtonEntries.append(entry)

			NSLayoutConstraint.activate([
				entry.button.widthAnchor.constraint(equalToConstant: 72),
				entry.button.heightAnchor.constraint(equalToConstant: 44)
			])
		}
	}

	private func createSourceButton(for source: ProfileImageSource, tag: Int) -> SourceButtonEntry {
		let button = UIButton(type: .custom)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.tag = tag

		let containerView = UIView()
		containerView.translatesAutoresizingMaskIntoConstraints = false
		containerView.layerCornerRadius = 22
		containerView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		containerView.isUserInteractionEnabled = false

		let iconImageView = UIImageView(image: source.icon)
		iconImageView.translatesAutoresizingMaskIntoConstraints = false
		iconImageView.contentMode = .scaleAspectFit
		iconImageView.theme_tintColor = KThemePicker.textColor.rawValue

		button.addSubview(containerView)
		containerView.addSubview(iconImageView)

		var iconLabel: UILabel?

		if source == .kaomoji {
			iconImageView.isHidden = true

			let label = UILabel()
			label.translatesAutoresizingMaskIntoConstraints = false
			label.text = "^_^"
			label.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: .systemFont(ofSize: 13, weight: .semibold))
			label.adjustsFontForContentSizeCategory = true
			label.theme_textColor = KThemePicker.textColor.rawValue
			label.textAlignment = .center
			containerView.addSubview(label)

			NSLayoutConstraint.activate([
				label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
				label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
			])

			iconLabel = label
		}

		NSLayoutConstraint.activate([
			containerView.topAnchor.constraint(equalTo: button.topAnchor),
			containerView.leadingAnchor.constraint(equalTo: button.leadingAnchor),
			containerView.trailingAnchor.constraint(equalTo: button.trailingAnchor),
			containerView.bottomAnchor.constraint(equalTo: button.bottomAnchor),

			iconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
			iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
			iconImageView.widthAnchor.constraint(equalToConstant: 28),
			iconImageView.heightAnchor.constraint(equalToConstant: 28)
		])

		button.accessibilityLabel = source.title
		button.addTarget(self, action: #selector(self.sourceButtonTapped(_:)), for: .touchUpInside)

		return SourceButtonEntry(button: button, containerView: containerView, iconImageView: iconImageView, iconLabel: iconLabel)
	}

	// MARK: - Source Selection
	@objc private func sourceButtonTapped(_ sender: UIButton) {
		self.selectSourceButton(at: sender.tag)
		let sources = ProfileImageSource.allCases
		guard sender.tag < sources.count else { return }
		let source = sources[sender.tag]
		self.selectedSource = source
		self.updateSectionContent(for: source)
	}

	private func selectSourceButton(at index: Int) {
		for (i, entry) in self.sourceButtonEntries.enumerated() {
			if i == index {
				entry.containerView.layer.borderWidth = 2
				entry.containerView.layer.borderColor = UIColor.kurozora.cgColor
				entry.containerView.backgroundColor = UIColor.kurozora.withAlphaComponent(0.1)
				entry.iconImageView.tintColor = .kurozora
				entry.iconLabel?.textColor = .kurozora
			} else {
				entry.containerView.layer.borderWidth = 0
				entry.containerView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
				entry.iconImageView.theme_tintColor = KThemePicker.textColor.rawValue
				entry.iconLabel?.theme_textColor = KThemePicker.textColor.rawValue
			}
		}
	}

	private func updateSectionContent(for source: ProfileImageSource) {
		self.photosProfileImageSourceView.isHidden = true
		self.emojiProfileImageSourceView.isHidden = true
		self.kaomojiProfileImageSourceView.isHidden = true
		self.monogramProfileImageSourceView.isHidden = true
		self.characterProfileImageSourceView.isHidden = true

		self.previewView.hideMonogramTextField()
		self.previewView.hideEmojiTextField()
		self.previewView.monogramInitialsLabel.isHidden = self.previewView.activePreviewSource != .monogram

		self.actionBarView.updateVisibleButtons(for: source)

		switch source {
		case .photos:
			self.photosProfileImageSourceView.isHidden = false
			let isLimited = PHPhotoLibrary.authorizationStatus(for: .readWrite) == .limited
			self.delegate?.profileImageSelectionView(self, shouldShowManageAccessToolbar: isLimited)
		case .emoji:
			self.emojiProfileImageSourceView.isHidden = false
			self.delegate?.profileImageSelectionView(self, shouldShowManageAccessToolbar: false)
		case .kaomoji:
			self.kaomojiProfileImageSourceView.isHidden = false
			self.delegate?.profileImageSelectionView(self, shouldShowManageAccessToolbar: false)
		case .characters:
			self.characterProfileImageSourceView.isHidden = false
			self.delegate?.profileImageSelectionView(self, shouldShowManageAccessToolbar: false)
		case .monogram:
			self.monogramProfileImageSourceView.isHidden = false
			self.delegate?.profileImageSelectionView(self, shouldShowManageAccessToolbar: false)
		}
	}

	// MARK: - Monogram Configuration
	private func configureMonogram() {
		var initials = "AB"
		if let user = User.current {
			let usernameInitials = user.attributes.username.initials
			initials = String(usernameInitials.prefix(2)).uppercased()
		}
		self.previewView.monogramInitials = initials
		self.monogramProfileImageSourceView.configure(with: initials)
	}

	// MARK: - Helpers
	private func syncMonogramState() {
		self.actionBarView.monogramState = (
			initials: self.previewView.monogramInitials,
			backgroundColor: self.previewView.monogramBackgroundColor,
			fontStyle: self.previewView.monogramFontStyle,
			weightValue: self.previewView.monogramFontWeightValue
		)
	}

	private func syncColorForPicker() {
		switch self.selectedSource {
		case .emoji:
			self.actionBarView.currentColorForPicker = self.previewView.emojiBackgroundColor
		case .kaomoji:
			self.actionBarView.currentColorForPicker = self.previewView.kaomojiBackgroundColor
		default:
			self.actionBarView.currentColorForPicker = self.previewView.monogramBackgroundColor
		}
	}
}

// MARK: - ProfileImagePreviewViewDelegate
extension ProfileImageSelectionView: ProfileImagePreviewViewDelegate {
	func profileImagePreviewView(_ view: ProfileImagePreviewView, didUpdateMonogramInitials initials: String, generatedImage: UIImage) {
		self.isProcessingActionBarUpdate = true
		self.monogramProfileImageSourceView.initials = initials
		self.isProcessingActionBarUpdate = false
		let image = self.monogramProfileImageSourceView.generateMonogramImage()
		self.delegate?.profileImageSelectionView(self, didSelectImage: image)
	}

	func profileImagePreviewView(_ view: ProfileImagePreviewView, didSelectEmoji emoji: String, generatedImage: UIImage) {
		self.previewView.selectedEmoji = emoji
		self.emojiProfileImageSourceView.selectedEmoji = emoji
		self.emojiProfileImageSourceView.imageBackgroundColor = self.previewView.emojiBackgroundColor
		let image = self.emojiProfileImageSourceView.generateEmojiImage(emoji)
		let previewImage = self.emojiProfileImageSourceView.generateEmojiImage(emoji, backgroundColor: nil)
		self.previewView.performReplaceTransition {
			self.previewView.previewImageView.image = previewImage
			self.previewView.previewImageView.backgroundColor = self.previewView.emojiBackgroundColor
		}
		self.previewView.updateDeleteButtonVisibility()
		self.delegate?.profileImageSelectionView(self, didSelectImage: image)
	}

	func profileImagePreviewView(_ view: ProfileImagePreviewView, didSelectKaomoji kaomoji: String, generatedImage: UIImage) {
		self.previewView.selectedKaomoji = kaomoji
		self.kaomojiProfileImageSourceView.selectedKaomoji = kaomoji
		self.kaomojiProfileImageSourceView.imageBackgroundColor = self.previewView.kaomojiBackgroundColor
		let image = self.kaomojiProfileImageSourceView.generateKaomojiImage(kaomoji)
		let previewImage = self.kaomojiProfileImageSourceView.kaomojiPreviewImage(kaomoji)
		self.previewView.performReplaceTransition {
			self.previewView.previewImageView.image = previewImage
			self.previewView.previewImageView.backgroundColor = self.previewView.kaomojiBackgroundColor
		}
		self.previewView.updateDeleteButtonVisibility()
		self.delegate?.profileImageSelectionView(self, didSelectImage: image)
	}

	func profileImagePreviewView(_ view: ProfileImagePreviewView, didUpdatePreview image: UIImage) {
		self.delegate?.profileImageSelectionView(self, didSelectImage: image)
	}

	func profileImagePreviewViewDidRequestEditMonogram(_ view: ProfileImagePreviewView) {
		guard self.selectedSource == .monogram else { return }
		self.previewView.showMonogramTextField()
	}

	func profileImagePreviewViewDidRequestEditEmoji(_ view: ProfileImagePreviewView) {
		guard self.selectedSource == .emoji else { return }
		self.previewView.showEmojiTextField()
	}

	func profileImagePreviewViewDidRequestEditKaomoji(_ view: ProfileImagePreviewView) {
		guard self.selectedSource == .kaomoji else { return }
		self.presentKaomojiPicker(sourceView: self.previewView.previewImageView)
	}

	func profileImagePreviewViewDidRequestDelete(_ view: ProfileImagePreviewView) {
		self.previewView.resetToPlaceholder()
		self.originalSelectedImage = nil
		if let placeholderImage = self.placeholderImage {
			self.delegate?.profileImageSelectionView(self, didSelectImage: placeholderImage)
		}
	}
}

// MARK: - ProfileImageActionBarViewDelegate
extension ProfileImageSelectionView: ProfileImageActionBarViewDelegate {
	func profileImageActionBarViewDidRequestEditInitials(_ view: ProfileImageActionBarView) {
		self.previewView.showMonogramTextField()
	}

	func profileImageActionBarViewDidRequestEmojiSelector(_ view: ProfileImageActionBarView) {
		self.previewView.showEmojiTextField()
	}

	func profileImageActionBarViewDidRequestKaomojiSelector(_ view: ProfileImageActionBarView) {
		self.presentKaomojiPicker(sourceView: view)
	}

	func profileImageActionBarViewDidRequestCharacterSearch(_ view: ProfileImageActionBarView) {
		self.delegate?.profileImageSelectionViewDidRequestCharacterSearch(self)
	}

	func profileImageActionBarViewDidRequestCrop(_ view: ProfileImageActionBarView) {
		self.delegate?.profileImageSelectionViewDidRequestCrop(self)
	}

	func profileImageActionBarView(_ view: ProfileImageActionBarView, didSelectColor color: UIColor, forSource source: ProfileImageSource) {
		switch source {
		case .emoji:
			self.previewView.emojiBackgroundColor = color
			self.previewView.previewImageView.backgroundColor = color
			self.emojiProfileImageSourceView.imageBackgroundColor = color
			let emoji = self.previewView.selectedEmoji ?? self.emojiProfileImageSourceView.firstEmoji
			if let emoji = emoji {
				self.previewView.selectedEmoji = emoji
				self.previewView.activePreviewSource = .emoji
				self.previewView.monogramInitialsLabel.isHidden = true
				self.emojiProfileImageSourceView.selectedEmoji = emoji
				let generatedImage = self.emojiProfileImageSourceView.generateEmojiImage(emoji)
				let previewImage = self.emojiProfileImageSourceView.generateEmojiImage(emoji, backgroundColor: nil)
				self.previewView.previewImageView.image = previewImage
				self.previewView.updateDeleteButtonVisibility()
				self.delegate?.profileImageSelectionView(self, didSelectImage: generatedImage)
			}
		case .kaomoji:
			self.previewView.kaomojiBackgroundColor = color
			self.kaomojiProfileImageSourceView.imageBackgroundColor = color
			let kaomoji = self.previewView.selectedKaomoji ?? KaomojiProfileImageSourceView.allKaomojis.first
			if let kaomoji = kaomoji {
				self.previewView.selectedKaomoji = kaomoji
				self.previewView.activePreviewSource = .kaomoji
				self.previewView.monogramInitialsLabel.isHidden = true
				self.kaomojiProfileImageSourceView.selectedKaomoji = kaomoji
				let generatedImage = self.kaomojiProfileImageSourceView.generateKaomojiImage(kaomoji)
				let previewImage = self.kaomojiProfileImageSourceView.kaomojiPreviewImage(kaomoji)
				self.previewView.previewImageView.image = previewImage
				self.previewView.previewImageView.backgroundColor = color
				self.previewView.updateDeleteButtonVisibility()
				self.delegate?.profileImageSelectionView(self, didSelectImage: generatedImage)
			}
		case .monogram:
			self.previewView.monogramBackgroundColor = color
			self.isProcessingActionBarUpdate = true
			self.monogramProfileImageSourceView.selectedBackgroundColor = color
			self.isProcessingActionBarUpdate = false
			self.previewView.updateMonogramPreview()
			self.syncMonogramState()
		default:
			break
		}
	}

	func profileImageActionBarView(_ view: ProfileImageActionBarView, didSelectFontStyle fontStyle: MonogramFontStyle, weightValue: CGFloat) {
		self.previewView.monogramFontStyle = fontStyle
		self.previewView.monogramFontWeightValue = weightValue
		self.isProcessingActionBarUpdate = true
		self.monogramProfileImageSourceView.selectedFontStyle = fontStyle
		self.monogramProfileImageSourceView.fontWeightValue = weightValue
		self.isProcessingActionBarUpdate = false
		let font = UIFont.monogramFont(style: fontStyle, size: 50, weight: UIFont.Weight(rawValue: weightValue))
		self.previewView.monogramInitialsLabel.font = font
		self.previewView.updateMonogramPreview()
		self.syncMonogramState()
	}

	func profileImageActionBarViewDidDismissPresentation(_ view: ProfileImageActionBarView) {
		if self.selectedSource == .monogram {
			self.isProcessingActionBarUpdate = true
			self.monogramProfileImageSourceView.selectedFontStyle = self.previewView.monogramFontStyle
			self.monogramProfileImageSourceView.fontWeightValue = self.previewView.monogramFontWeightValue
			self.isProcessingActionBarUpdate = false
			self.previewView.updateMonogramPreview()
			self.syncMonogramState()
		}
	}
}

// MARK: - PhotosProfileImageSourceViewDelegate
extension ProfileImageSelectionView: PhotosProfileImageSourceViewDelegate {
	func photosProfileImageSourceView(_ view: PhotosProfileImageSourceView, didSelectImage image: UIImage) {
		self.previewView.performReplaceTransition {
			self.previewView.activePreviewSource = .photos
			self.previewView.monogramInitialsLabel.isHidden = true
			self.previewView.previewImageView.backgroundColor = .clear
			self.previewView.previewImageView.image = image
		}
		self.originalSelectedImage = image
		self.previewView.updateDeleteButtonVisibility()
		self.delegate?.profileImageSelectionView(self, didSelectImage: image)
	}

	func photosProfileImageSourceViewDidRequestCamera(_ view: PhotosProfileImageSourceView) {
		self.delegate?.profileImageSelectionViewDidRequestCamera(self)
	}

	func photosProfileImageSourceViewDidRequestPhotos(_ view: PhotosProfileImageSourceView) {
		self.delegate?.profileImageSelectionViewDidRequestPhotos(self)
	}

	func photosProfileImageSourceViewDidChangeAuthorizationStatus(_ view: PhotosProfileImageSourceView) {
		self.updateSectionContent(for: .photos)
	}
}

// MARK: - MonogramProfileImageSourceViewDelegate
extension ProfileImageSelectionView: MonogramProfileImageSourceViewDelegate {
	func monogramProfileImageSourceView(_ view: MonogramProfileImageSourceView, didSelectImage image: UIImage) {
		guard self.isConfigured else { return }

		if !self.previewView.isUpdatingMonogramPreview {
			self.previewView.monogramBackgroundColor = view.selectedBackgroundColor
			self.previewView.monogramFontStyle = view.selectedFontStyle
			self.previewView.monogramFontWeightValue = view.fontWeightValue
		}

		let displayInitials = String(view.initials.prefix(3)).uppercased()
		let textColor: UIColor = view.selectedBackgroundColor.isLight ? .black : .white

		let applyChanges = {
			self.previewView.activePreviewSource = .monogram
			self.previewView.monogramInitialsLabel.isHidden = false
			self.previewView.monogramInitialsLabel.text = displayInitials
			self.previewView.monogramInitialsLabel.font = UIFont.monogramFont(style: view.selectedFontStyle, size: 50, weight: UIFont.Weight(rawValue: view.fontWeightValue))
			self.previewView.monogramInitialsLabel.textColor = textColor
			self.previewView.previewImageView.backgroundColor = view.selectedBackgroundColor
			self.previewView.previewImageView.image = nil
		}

		if self.previewView.activePreviewSource == .monogram && self.isProcessingActionBarUpdate {
			applyChanges()
		} else {
			self.previewView.performReplaceTransition(changes: applyChanges)
		}
		self.previewView.updateDeleteButtonVisibility()
		self.delegate?.profileImageSelectionView(self, didSelectImage: image)
		self.actionBarView.setCropButtonHidden(true)
		self.syncMonogramState()
		self.syncColorForPicker()
	}
}

// MARK: - EmojiProfileImageSourceViewDelegate
extension ProfileImageSelectionView: EmojiProfileImageSourceViewDelegate {
	func emojiProfileImageSourceView(_ view: EmojiProfileImageSourceView, didSelectImage image: UIImage, previewImage: UIImage?) {
		self.previewView.selectedEmoji = view.selectedEmoji
		self.previewView.emojiBackgroundColor = view.imageBackgroundColor ?? self.previewView.emojiBackgroundColor
		self.previewView.performReplaceTransition {
			self.previewView.activePreviewSource = .emoji
			self.previewView.monogramInitialsLabel.isHidden = true
			self.previewView.previewImageView.image = previewImage
			self.previewView.previewImageView.backgroundColor = self.previewView.emojiBackgroundColor
		}
		self.previewView.updateDeleteButtonVisibility()
		self.delegate?.profileImageSelectionView(self, didSelectImage: image)
		self.actionBarView.setCropButtonHidden(true)
		self.syncColorForPicker()
	}
}

// MARK: - KaomojiProfileImageSourceViewDelegate
extension ProfileImageSelectionView: KaomojiProfileImageSourceViewDelegate {
	func kaomojiProfileImageSourceView(_ view: KaomojiProfileImageSourceView, didSelectImage image: UIImage, previewImage: UIImage?) {
		self.previewView.selectedKaomoji = view.selectedKaomoji
		self.previewView.kaomojiBackgroundColor = view.imageBackgroundColor ?? self.previewView.kaomojiBackgroundColor
		self.previewView.performReplaceTransition {
			self.previewView.activePreviewSource = .kaomoji
			self.previewView.monogramInitialsLabel.isHidden = true
			self.previewView.previewImageView.image = previewImage
			self.previewView.previewImageView.backgroundColor = self.previewView.kaomojiBackgroundColor
		}
		self.previewView.updateDeleteButtonVisibility()
		self.delegate?.profileImageSelectionView(self, didSelectImage: image)
		self.actionBarView.setCropButtonHidden(true)
		self.syncColorForPicker()
	}
}

// MARK: - CharacterProfileImageSourceViewDelegate
extension ProfileImageSelectionView: CharacterProfileImageSourceViewDelegate {
	func characterProfileImageSourceView(_ view: CharacterProfileImageSourceView, didSelectImage image: UIImage) {
		self.previewView.performReplaceTransition {
			self.previewView.activePreviewSource = .characters
			self.previewView.monogramInitialsLabel.isHidden = true
			self.previewView.previewImageView.backgroundColor = .clear
			self.previewView.previewImageView.image = image
		}
		self.originalSelectedImage = image
		self.previewView.updateDeleteButtonVisibility()
		self.actionBarView.setPhotosButtonStackHidden(false)
		self.actionBarView.setCropButtonHidden(false)
		self.delegate?.profileImageSelectionView(self, didSelectImage: image)
	}
}

// MARK: - KaomojiPickerViewControllerDelegate
extension ProfileImageSelectionView: KaomojiPickerViewControllerDelegate {
	func kaomojiPickerViewController(_ viewController: KaomojiPickerViewController, didSelectKaomoji kaomoji: String) {
		self.previewView.selectedKaomoji = kaomoji
		self.kaomojiProfileImageSourceView.selectedKaomoji = kaomoji
		self.kaomojiProfileImageSourceView.imageBackgroundColor = self.previewView.kaomojiBackgroundColor
		let image = self.kaomojiProfileImageSourceView.generateKaomojiImage(kaomoji)
		let previewImage = self.kaomojiProfileImageSourceView.kaomojiPreviewImage(kaomoji)
		self.previewView.performReplaceTransition {
			self.previewView.activePreviewSource = .kaomoji
			self.previewView.monogramInitialsLabel.isHidden = true
			self.previewView.previewImageView.image = previewImage
			self.previewView.previewImageView.backgroundColor = self.previewView.kaomojiBackgroundColor
		}
		self.previewView.updateDeleteButtonVisibility()
		self.delegate?.profileImageSelectionView(self, didSelectImage: image)
	}

	private func presentKaomojiPicker(sourceView: UIView) {
		guard let parentViewController = self.parentViewController else { return }

		let pickerVC = KaomojiPickerViewController()
		pickerVC.delegate = self

		if let popover = pickerVC.popoverPresentationController {
			popover.sourceView = sourceView
			popover.sourceRect = sourceView.bounds
		}

		pickerVC.presentationController?.delegate = self.actionBarView
		parentViewController.present(pickerVC, animated: true)
	}
}
