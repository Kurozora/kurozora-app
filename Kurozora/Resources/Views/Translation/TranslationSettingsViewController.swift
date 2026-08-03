//
//  TranslationSettingsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// The sheet controlling how user-generated content is translated.
@available(iOS 26.4, macCatalyst 26.4, *)
class TranslationSettingsViewController: KViewController {
	// MARK: - Views
	private var containerView: UIView!
	private var contentStackView: UIStackView!
	private var titleLabel: KLabel!
	private var subtitleLabel: KLabel!
	private var targetLanguageLabel: KLabel!
	private var targetLanguageButton: KButton!
	private var automaticTranslationStackView: UIStackView!
	private var automaticTranslationLabel: KLabel!
	private var automaticTranslationSwitch: KSwitch!
	private var primaryButton: KTintedButton!

	// MARK: - Properties
	private let viewWidth: CGFloat = 400.0

	/// The language of the content the sheet was opened from.
	var sourceLanguage: Locale.Language?

	override var preferredContentSize: CGSize {
		get {
			let contentSize = self.contentStackView.systemLayoutSizeFitting(CGSize(width: self.viewWidth, height: UIView.layoutFittingCompressedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
			return CGSize(width: self.viewWidth, height: contentSize.height + 40)
		}
		set {
			super.preferredContentSize = newValue
		}
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.configureView()

		self.titleLabel.text = L10n.translationSettingsTitle
		self.subtitleLabel.text = L10n.translationSettingsSubtitle
		self.targetLanguageLabel.text = L10n.translationSettingsTranslateInto

		self.updateTargetLanguage()
		self.updateAutomaticTranslation()
	}

	// MARK: - Functions
	private func configureView() {
		self.configureSheetPresentation()
		self.configureViews()
		self.configureViewHierarchy()
		self.configureViewConstraints()
	}

	func configureSheetPresentation() {
		guard let sheet = self.popoverPresentationController?.adaptiveSheetPresentationController ?? self.sheetPresentationController else { return }

		sheet.detents = [
			.custom { [weak self] _ in
				guard let self = self else { return 300 }
				return self.preferredContentSize.height
			}
		]
		sheet.invalidateDetents()
	}

	private func configureViews() {
		self.configureContentView()
		self.configureContentStackView()
		self.configureTitleLabel()
		self.configureSubtitleLabel()
		self.configureTargetLanguageViews()
		self.configureAutomaticTranslationViews()
		self.configurePrimaryButton()
	}

	private func configureContentView() {
		self.containerView = UIView()
		self.containerView.translatesAutoresizingMaskIntoConstraints = false
	}

	private func configureContentStackView() {
		self.contentStackView = UIStackView()
		self.contentStackView.translatesAutoresizingMaskIntoConstraints = false
		self.contentStackView.axis = .vertical
		self.contentStackView.spacing = 16.0
	}

	private func configureTitleLabel() {
		self.titleLabel = KLabel()
		self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
		self.titleLabel.font = .preferredFont(forTextStyle: .headline)
		self.titleLabel.numberOfLines = 0
		self.titleLabel.setContentHuggingPriority(.required, for: .vertical)
	}

	private func configureSubtitleLabel() {
		self.subtitleLabel = KLabel()
		self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
		self.subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
		self.subtitleLabel.numberOfLines = 0
		self.subtitleLabel.setContentHuggingPriority(.required, for: .vertical)
	}

	private func configureTargetLanguageViews() {
		self.targetLanguageLabel = KLabel()
		self.targetLanguageLabel.translatesAutoresizingMaskIntoConstraints = false
		self.targetLanguageLabel.font = .preferredFont(forTextStyle: .body)
		self.targetLanguageLabel.numberOfLines = 0

		self.targetLanguageButton = KButton()
		self.targetLanguageButton.translatesAutoresizingMaskIntoConstraints = false
		self.targetLanguageButton.titleLabel?.font = .preferredFont(forTextStyle: .body)
		self.targetLanguageButton.setContentHuggingPriority(.required, for: .horizontal)
		self.targetLanguageButton.showsMenuAsPrimaryAction = true
	}

	private func configureAutomaticTranslationViews() {
		self.automaticTranslationLabel = KLabel()
		self.automaticTranslationLabel.translatesAutoresizingMaskIntoConstraints = false
		self.automaticTranslationLabel.font = .preferredFont(forTextStyle: .body)
		self.automaticTranslationLabel.numberOfLines = 0

		self.automaticTranslationSwitch = KSwitch()
		self.automaticTranslationSwitch.translatesAutoresizingMaskIntoConstraints = false
		self.automaticTranslationSwitch.setContentHuggingPriority(.required, for: .horizontal)
		self.automaticTranslationSwitch.addAction(UIAction { [weak self] _ in
			guard let self = self else { return }
			self.automaticTranslationSwitchChanged()
		}, for: .valueChanged)
	}

	private func configurePrimaryButton() {
		self.primaryButton = KTintedButton()
		self.primaryButton.translatesAutoresizingMaskIntoConstraints = false
		self.primaryButton.setTitle(L10n.done, for: .normal)
		self.primaryButton.titleLabel?.font = .preferredFont(forTextStyle: .body)
		self.primaryButton.highlightBackgroundColorEnabled = true
		self.primaryButton.addAction(UIAction { [weak self] _ in
			guard let self = self else { return }
			self.primaryButtonPressed()
		}, for: .touchUpInside)
	}

	private func configureViewHierarchy() {
		let targetLanguageStackView = UIStackView(arrangedSubviews: [
			self.targetLanguageLabel,
			self.targetLanguageButton
		])
		targetLanguageStackView.axis = .horizontal
		targetLanguageStackView.alignment = .firstBaseline
		targetLanguageStackView.spacing = 8
		targetLanguageStackView.translatesAutoresizingMaskIntoConstraints = false

		self.automaticTranslationStackView = UIStackView(arrangedSubviews: [
			self.automaticTranslationLabel,
			self.automaticTranslationSwitch
		])
		self.automaticTranslationStackView.axis = .horizontal
		self.automaticTranslationStackView.alignment = .center
		self.automaticTranslationStackView.spacing = 8
		self.automaticTranslationStackView.translatesAutoresizingMaskIntoConstraints = false

		let infoStackView = UIStackView(arrangedSubviews: [
			self.titleLabel,
			self.subtitleLabel,
			targetLanguageStackView,
			self.automaticTranslationStackView
		])
		infoStackView.axis = .vertical
		infoStackView.spacing = 8
		infoStackView.translatesAutoresizingMaskIntoConstraints = false
		infoStackView.setCustomSpacing(16, after: self.subtitleLabel)
		infoStackView.setCustomSpacing(16, after: targetLanguageStackView)

		self.contentStackView.addArrangedSubview(infoStackView)
		self.contentStackView.addArrangedSubview(self.primaryButton)

		self.containerView.addSubview(self.contentStackView)
		self.view.addSubview(self.containerView)
	}

	private func configureViewConstraints() {
		let viewWidthConstraint = self.containerView.widthAnchor.constraint(equalToConstant: self.viewWidth)
		viewWidthConstraint.priority = UILayoutPriority(999)

		// Set the bottom constraint with a slightly lower priority, since
		// the sheet is initially presented with a smaller height. This
		// prevents Auto Layout warnings about unsatisfiable constraints when
		// the sheet is first presented, while still allowing the content to
		// expand as needed when the sheet resizes.
		let bottomConstraint = self.contentStackView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -20)
		bottomConstraint.priority = UILayoutPriority(999)

		NSLayoutConstraint.activate([
			self.containerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
			self.containerView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
			self.containerView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
			self.containerView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
			viewWidthConstraint,

			self.contentStackView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 20),
			self.contentStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 20),
			self.contentStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -20),
			bottomConstraint,

			self.primaryButton.heightAnchor.constraint(equalToConstant: 40)
		])
	}

	/// Refreshes the target language button and the menu of languages behind it.
	private func updateTargetLanguage() {
		let translationService = TranslationService.shared
		let targetLanguage = translationService.targetLanguage

		self.targetLanguageButton.setTitle(translationService.localizedName(for: targetLanguage), for: .normal)
		self.targetLanguageButton.menu = UIMenu(children: translationService.availableTargetLanguages.map { language in
			UIAction(title: translationService.localizedName(for: language), state: language == targetLanguage ? .on : .off) { [weak self] _ in
				guard let self = self else { return }
				self.selectTargetLanguage(language)
			}
		})
	}

	/// Shows the automatic translation row for the message's language.
	private func updateAutomaticTranslation() {
		guard let sourceLanguage = self.sourceLanguage else {
			self.automaticTranslationStackView.isHidden = true
			return
		}

		let translationService = TranslationService.shared

		self.automaticTranslationStackView.isHidden = false
		self.automaticTranslationLabel.text = L10n.translationSettingsAutomaticallyTranslate(translationService.localizedLanguageName(for: sourceLanguage))
		self.automaticTranslationSwitch.isOn = translationService.isAutoTranslated(sourceLanguage)
	}

	/// Stores the chosen target language and re-evaluates every message.
	///
	/// - Parameter language: The language messages should be translated into.
	private func selectTargetLanguage(_ language: Locale.Language) {
		UserSettings.set(language.maximalIdentifier, forKey: .translationLanguage)
		TranslationService.shared.invalidate()

		self.updateTargetLanguage()
	}

	/// Opts the message's language in or out of automatic translation.
	private func automaticTranslationSwitchChanged() {
		guard let sourceLanguage = self.sourceLanguage else { return }

		var excludedLanguages = UserSettings.autoTranslateExcludedLanguages.filter { identifier in
			Locale.Language(identifier: identifier).languageCode != sourceLanguage.languageCode
		}

		if !self.automaticTranslationSwitch.isOn {
			excludedLanguages.append(sourceLanguage.maximalIdentifier)
		}

		UserSettings.set(excludedLanguages, forKey: .autoTranslateExcludedLanguages)
		TranslationService.shared.invalidate()
	}

	private func primaryButtonPressed() {
		self.dismiss(animated: true, completion: nil)
	}
}

// MARK: - Presentation
@available(iOS 26.4, macCatalyst 26.4, *)
extension TranslationSettingsViewController {
	/// Presents the translation settings for the given content.
	///
	/// - Parameters:
	///   - content: The content the settings were opened from.
	///   - button: The button to anchor the sheet to.
	///   - viewController: The view controller to present from.
	static func present(for content: TranslatableContent, from button: UIButton, in viewController: UIViewController) {
		let translationSettingsViewController = TranslationSettingsViewController()
		translationSettingsViewController.sourceLanguage = TranslationService.shared.state(for: content).sourceLanguage
		translationSettingsViewController.popoverPresentationController?.sourceView = button
		translationSettingsViewController.popoverPresentationController?.sourceRect = button.bounds

		viewController.present(translationSettingsViewController, animated: true, completion: nil)
	}
}
