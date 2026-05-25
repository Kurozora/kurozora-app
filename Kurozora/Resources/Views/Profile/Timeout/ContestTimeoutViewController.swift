//
//  ContestTimeoutViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

final class ContestTimeoutViewController: KViewController {
	// MARK: - Views
	private let promptLabel = KLabel()
	private let editorContainerView = UIView()
	private let messageTextView = KTextView()
	private let counterLabel = KSecondaryLabel()
	private let submitButton = KTintedButton()
	private let cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)

	// MARK: - Properties
	/// The existing appeal message to edit.
	var existingMessage: String?

	/// Called with the updated timeout once the appeal is submitted.
	var onAppealSubmitted: ((UserTimeout) -> Void)?

	/// The maximum number of characters an appeal may contain.
	private let characterLimit = 2000

	/// The minimum number of characters required to submit an appeal.
	private let minimumLength = 10

	private var isEditingExisting: Bool {
		return self.existingMessage != nil
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = self.isEditingExisting ? L10n.editAppealTitle : L10n.contestSuspensionTitle
		self.view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		self.configureNavigationItem()
		self.configureViewHierarchy()
		self.configureViewConstraints()
	}

	// MARK: - Configuration
	private func configureNavigationItem() {
		self.cancelBarButtonItem.target = self
		self.cancelBarButtonItem.action = #selector(self.cancelTapped)
		self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem
	}

	private func configureViewHierarchy() {
		self.promptLabel.text = L10n.contestSuspensionPrompt
		self.promptLabel.numberOfLines = 0
		self.promptLabel.translatesAutoresizingMaskIntoConstraints = false

		self.editorContainerView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		self.editorContainerView.layerCornerRadius = 10
		self.editorContainerView.translatesAutoresizingMaskIntoConstraints = false

		self.messageTextView.delegate = self
		self.messageTextView.font = .preferredFont(forTextStyle: .body)
		self.messageTextView.backgroundColor = .clear
		self.messageTextView.textContainerInset = .zero
		self.messageTextView.textContainer.lineFragmentPadding = 0
		self.messageTextView.placeholder = L10n.contestSuspensionPlaceholder
		self.messageTextView.text = self.existingMessage
		self.messageTextView.translatesAutoresizingMaskIntoConstraints = false

		self.counterLabel.font = .preferredFont(forTextStyle: .caption2)
		self.counterLabel.textAlignment = .right
		self.counterLabel.translatesAutoresizingMaskIntoConstraints = false

		self.submitButton.setTitle(self.isEditingExisting ? L10n.updateAppeal : L10n.submitAppeal, for: .normal)
		self.submitButton.translatesAutoresizingMaskIntoConstraints = false
		self.submitButton.addTarget(self, action: #selector(self.submitTapped), for: .touchUpInside)

		self.editorContainerView.addSubview(self.messageTextView)
		self.editorContainerView.addSubview(self.counterLabel)

		self.view.addSubview(self.promptLabel)
		self.view.addSubview(self.editorContainerView)
		self.view.addSubview(self.submitButton)

		self.updateCounter(for: self.existingMessage ?? "")
	}

	private func configureViewConstraints() {
		NSLayoutConstraint.activate([
			self.promptLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
			self.promptLabel.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
			self.promptLabel.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor),

			self.editorContainerView.topAnchor.constraint(equalTo: self.promptLabel.bottomAnchor, constant: 16),
			self.editorContainerView.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
			self.editorContainerView.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor),

			self.messageTextView.topAnchor.constraint(equalTo: self.editorContainerView.topAnchor, constant: 16),
			self.messageTextView.leadingAnchor.constraint(equalTo: self.editorContainerView.leadingAnchor, constant: 16),
			self.messageTextView.trailingAnchor.constraint(equalTo: self.editorContainerView.trailingAnchor, constant: -16),
			self.messageTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200),

			self.counterLabel.topAnchor.constraint(equalTo: self.messageTextView.bottomAnchor, constant: 8),
			self.counterLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.messageTextView.leadingAnchor),
			self.counterLabel.trailingAnchor.constraint(equalTo: self.editorContainerView.trailingAnchor, constant: -16),
			self.counterLabel.bottomAnchor.constraint(equalTo: self.editorContainerView.bottomAnchor, constant: -12),

			self.submitButton.topAnchor.constraint(equalTo: self.editorContainerView.bottomAnchor, constant: 16),
			self.submitButton.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
			self.submitButton.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor),
			self.submitButton.heightAnchor.constraint(equalToConstant: 44),
		])
	}

	private func updateCounter(for text: String) {
		self.counterLabel.text = "\(text.count) / \(self.characterLimit)"
	}

	// MARK: - Actions
	@objc private func cancelTapped() {
		self.dismiss(animated: true)
	}

	@objc private func submitTapped() {
		let message = self.messageTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

		guard message.count >= self.minimumLength else {
			self.presentAlertController(title: nil, message: L10n.appealTooShort)
			return
		}

		self.submitButton.isEnabled = false
		let editing = self.isEditingExisting

		Task {
			do {
				let response: UserTimeoutResponse
				if editing {
					response = try await KService.updateAppealTimeout(message: message).response()
				} else {
					response = try await KService.appealTimeout(message: message).response()
				}

				await MainActor.run {
					if let updatedTimeout = response.data.first {
						self.onAppealSubmitted?(updatedTimeout)
					}

					if let currentUserID = User.current?.id {
						NotificationCenter.default.post(name: .KUserTimeoutDidChange, object: currentUserID)
					}

					self.dismiss(animated: true)
				}
			} catch let error as APIError {
				await MainActor.run {
					self.presentAlertController(title: nil, message: error.message)
					self.submitButton.isEnabled = true
				}
			} catch {
				await MainActor.run {
					self.presentAlertController(title: nil, message: error.localizedDescription)
					self.submitButton.isEnabled = true
				}
			}
		}
	}
}

// MARK: - UITextViewDelegate
extension ContestTimeoutViewController: UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		let trimmed = String(textView.text.prefix(self.characterLimit))

		if textView.text != trimmed {
			textView.text = trimmed
		}

		self.updateCounter(for: trimmed)
	}
}
