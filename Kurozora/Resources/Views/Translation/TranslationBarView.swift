//
//  TranslationBarView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

protocol TranslationBarViewDelegate: AnyObject {
	/// Tells the delegate the reader asked to switch between the original and the translation.
	///
	/// - Parameter translationBarView: The bar that was tapped.
	func translationBarViewDidTapAction(_ translationBarView: TranslationBarView)

	/// Tells the delegate the reader asked to open the translation settings.
	///
	/// - Parameters:
	///   - translationBarView: The bar that was tapped.
	///   - button: The button to anchor the settings sheet to.
	func translationBarView(_ translationBarView: TranslationBarView, didTapSettings button: UIButton)
}

/// The row above a piece of user-generated content offering to translate it.
class TranslationBarView: UIView {
	// MARK: - Views
	private var contentStackView: UIStackView!
	private var glyphImageView: UIImageView!
	private var statusLabel: KSecondaryLabel!
	private var actionButton: KButton!
	private var settingsButton: KButton!

	// MARK: - Properties
	weak var delegate: TranslationBarViewDelegate?

	/// Pins the row to the height of the single line of text it shows.
	private var rowHeightConstraint: NSLayoutConstraint!

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
	/// Lays the row out for the given translation state.
	///
	/// - Parameter state: The content's current translation state.
	@available(iOS 26.4, macCatalyst 26.4, *)
	func configure(using state: TranslationService.State) {
		switch state {
		case .unavailable:
			self.isHidden = true
			return
		case .original:
			self.statusLabel.isHidden = true
			self.actionButton.isHidden = false
			self.settingsButton.isHidden = false
			self.actionButton.setTitle(L10n.translationShowTranslation, for: .normal)
		case .translating:
			self.statusLabel.isHidden = false
			self.actionButton.isHidden = true
			self.settingsButton.isHidden = true
			self.statusLabel.text = L10n.translationInProgress
		case .translated(let sourceLanguage, _):
			self.statusLabel.isHidden = false
			self.actionButton.isHidden = false
			self.settingsButton.isHidden = false
			self.statusLabel.text = L10n.translationTranslatedFrom(TranslationService.shared.localizedLanguageName(for: sourceLanguage))
			self.actionButton.setTitle(L10n.translationShowOriginal, for: .normal)
		case .failed:
			self.statusLabel.isHidden = false
			self.actionButton.isHidden = false
			self.settingsButton.isHidden = false
			self.statusLabel.text = L10n.translationFailed
			self.actionButton.setTitle(L10n.translationShowTranslation, for: .normal)
		}

		self.isHidden = false
	}

	private func sharedInit() {
		self.configureViews()
		self.configureViewHierarchy()
		self.configureViewConstraints()
	}

	private func configureViews() {
		self.configureGlyphImageView()
		self.configureStatusLabel()
		self.configureActionButton()
		self.configureSettingsButton()
		self.configureContentStackView()
	}

	private func configureGlyphImageView() {
		self.glyphImageView = UIImageView(image: .Symbols.translate)
		self.glyphImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .footnote)
		self.glyphImageView.translatesAutoresizingMaskIntoConstraints = false
		self.glyphImageView.contentMode = .scaleAspectFit
		self.glyphImageView.setContentHuggingPriority(.required, for: .horizontal)
		self.glyphImageView.theme_tintColor = KThemePicker.subTextColor.rawValue
	}

	private func configureStatusLabel() {
		self.statusLabel = KSecondaryLabel()
		self.statusLabel.translatesAutoresizingMaskIntoConstraints = false
		self.statusLabel.font = .preferredFont(forTextStyle: .footnote)
		self.statusLabel.numberOfLines = 1
		self.statusLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
	}

	private func configureActionButton() {
		self.actionButton = KButton()
		self.actionButton.translatesAutoresizingMaskIntoConstraints = false
		self.actionButton.titleLabel?.font = .preferredFont(forTextStyle: .footnote)
		self.actionButton.setContentHuggingPriority(.required, for: .horizontal)
		self.actionButton.setContentCompressionResistancePriority(.required, for: .horizontal)
		self.actionButton.addAction(UIAction { [weak self] _ in
			guard let self = self else { return }
			self.delegate?.translationBarViewDidTapAction(self)
		}, for: .touchUpInside)
	}

	private func configureSettingsButton() {
		let configuration = UIImage.SymbolConfiguration(textStyle: .footnote)

		self.settingsButton = KButton()
		self.settingsButton.translatesAutoresizingMaskIntoConstraints = false
		self.settingsButton.setImage(UIImage(systemName: "gearshape.fill", withConfiguration: configuration), for: .normal)
		self.settingsButton.setContentHuggingPriority(.required, for: .horizontal)
		self.settingsButton.theme_tintColor = KThemePicker.subTextColor.rawValue
		self.settingsButton.accessibilityLabel = L10n.translationSettingsTitle
		self.settingsButton.addAction(UIAction { [weak self] _ in
			guard let self = self else { return }
			self.delegate?.translationBarView(self, didTapSettings: self.settingsButton)
		}, for: .touchUpInside)
	}

	private func configureContentStackView() {
		self.contentStackView = UIStackView()
		self.contentStackView.translatesAutoresizingMaskIntoConstraints = false
		self.contentStackView.axis = .horizontal
		self.contentStackView.alignment = .center
		self.contentStackView.spacing = 6.0
	}

	private func configureViewHierarchy() {
		// Keeps the row left-aligned while the stack reclaims any hidden control's space.
		let spacerView = UIView()
		spacerView.translatesAutoresizingMaskIntoConstraints = false
		spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)

		self.contentStackView.addArrangedSubview(self.glyphImageView)
		self.contentStackView.addArrangedSubview(self.statusLabel)
		self.contentStackView.addArrangedSubview(self.actionButton)
		self.contentStackView.addArrangedSubview(self.settingsButton)
		self.contentStackView.addArrangedSubview(spacerView)

		self.addSubview(self.contentStackView)
	}

	private func configureViewConstraints() {
		// Pinned to the text's line height so the buttons' own padding can't inflate the row.
		self.rowHeightConstraint = self.contentStackView.heightAnchor.constraint(equalToConstant: Self.rowHeight)

		NSLayoutConstraint.activate([
			self.contentStackView.topAnchor.constraint(equalTo: self.topAnchor),
			self.contentStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.contentStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.contentStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			self.rowHeightConstraint
		])
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		guard self.traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory else { return }

		self.rowHeightConstraint.constant = Self.rowHeight
	}

	/// The height of a single line of the row's text at the current type size.
	private static var rowHeight: CGFloat {
		return UIFont.preferredFont(forTextStyle: .footnote).lineHeight
	}
}

// MARK: - Installation
extension TranslationBarView {
	/// Inserts a translation row into the given stack view, above the content it belongs to.
	///
	/// - Parameters:
	///   - stackView: The vertical stack holding the content's body.
	///   - index: The position to insert the row at.
	///   - delegate: The object handling the row's taps.
	///
	/// - Returns: The installed row, hidden until it's configured with a state.
	@discardableResult
	static func install(in stackView: UIStackView, at index: Int, delegate: TranslationBarViewDelegate) -> TranslationBarView {
		let translationBarView = TranslationBarView()
		translationBarView.translatesAutoresizingMaskIntoConstraints = false
		translationBarView.delegate = delegate
		translationBarView.isHidden = true

		stackView.insertArrangedSubview(translationBarView, at: index)
		stackView.setCustomSpacing(self.contentSpacing, after: translationBarView)

		return translationBarView
	}

	/// The gap between the row and the content beneath it.
	private static var contentSpacing: CGFloat {
		return 2.0
	}
}
