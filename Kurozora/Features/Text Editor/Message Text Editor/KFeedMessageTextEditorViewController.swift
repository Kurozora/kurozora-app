//
//  KFeedMessageTextEditorViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

protocol KFeedMessageTextEditorViewDelegate: AnyObject {
	func kFeedMessageTextEditorView(updateMessagesWith feedMessages: [FeedMessage])
	func segueToOPFeedDetails(_ feedMessage: FeedMessage)
}

class KFeedMessageTextEditorViewController: KViewController {
	// MARK: - Views
	private var textEditorView: KFeedMessageTextEditorView {
		guard let textEditorView = self.view as? KFeedMessageTextEditorView else {
			fatalError("Expected a KFeedMessageTextEditorView")
		}

		return textEditorView
	}

	var profileImageView: ProfileImageView {
		return self.textEditorView.profileImageView
	}

	var currentUsernameLabel: KLabel {
		return self.textEditorView.currentUsernameLabel
	}

	var characterCountLabel: KSecondaryLabel {
		return self.textEditorView.characterCountLabel
	}

	var commentTextView: KTextView {
		return self.textEditorView.commentTextView
	}

	var labelsButton: KButton {
		return self.textEditorView.labelsButton
	}

	var sendButton: UIBarButtonItem {
		guard let sendButton = self.navigationItem.rightBarButtonItem else {
			fatalError("Missing send button")
		}

		return sendButton
	}

	// MARK: - Properties
	var editorLayout: FeedMessageEditorLayout = .standard

	var placeholderText: String {
		switch self.editorLayout {
		case .standard, .reply:
			return Trans.whatsOnYourMind
		case .reShare:
			return Trans.writeAComment
		}
	}

	var originalText = "" {
		didSet {
			self.editedText = self.originalText
		}
	}

	var editedText = "" {
		didSet {
			self.viewIfLoaded?.setNeedsLayout()
		}
	}

	var originalNSFW = false {
		didSet {
			self.editedNSFW = self.originalNSFW
		}
	}

	var editedNSFW = false {
		didSet {
			self.viewIfLoaded?.setNeedsLayout()
		}
	}

	var originalSpoiler = false {
		didSet {
			self.editedSpoiler = self.originalSpoiler
		}
	}

	var editedSpoiler = false {
		didSet {
			self.viewIfLoaded?.setNeedsLayout()
		}
	}

	var hasChanges: Bool {
		if self.editingFeedMessage != nil {
			return self.originalText != self.editedText || self.originalNSFW != self.editedNSFW || self.originalSpoiler != self.editedSpoiler
		}

		return self.originalText != self.editedText
	}

	var editingFeedMessage: FeedMessage?
	var opFeedMessage: FeedMessage?
	var dmToUser: User?
	var userInfo: [AnyHashable: Any] = [:]
	var segueToOPFeedDetails: Bool = false

	weak var delegate: KFeedMessageTextEditorViewDelegate?

	var selectedSelfLabel: SelfLabel?
	var isSpoiler: Bool = false
	var isNSFW: Bool = false

	private let markdownFormatter = MarkdownTextFormatter()
	private var isUpdatingFormatting = false

	// MARK: - View
	override func loadView() {
		self.view = KFeedMessageTextEditorView(layout: self.editorLayout)
		self.commentTextView.delegate = self
		self.labelsButton.addTarget(self, action: #selector(self.labelsButtonPressed(_:)), for: .touchUpInside)
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()

		// If there are unsaved changes, enable the Save button and disable the ability to
		// dismiss using the pull-down gesture.
		self.navigationItem.rightBarButtonItem?.isEnabled = self.hasChanges
		self.isModalInPresentation = self.hasChanges
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		NotificationCenter.default.addObserver(self, selector: #selector(self.handleThemeChange), name: .ThemeUpdateNotification, object: nil)

		self.configureNavigationItemsIfNeeded()
		self.configureCommentTextView()

		if let user = User.current {
			self.currentUsernameLabel.text = user.attributes.username
			user.attributes.profileImage(imageView: self.profileImageView)
			self.isNSFW = user.attributes.preferredTVRating ?? 4 > 4
		}

		self.characterCountLabel.text = "\(FeedMessage.maxCharacterLimit)"

		if let feedMessage = self.editingFeedMessage {
			self.commentTextView.text = feedMessage.attributes.content
			self.originalText = feedMessage.attributes.content
			self.isNSFW = feedMessage.attributes.isNSFW
			self.originalNSFW = feedMessage.attributes.isNSFW
			self.isSpoiler = feedMessage.attributes.isSpoiler
			self.originalSpoiler = feedMessage.attributes.isSpoiler

			if self.isNSFW || self.isSpoiler {
				self.selectedOptionChanged(.both)
			} else if self.isNSFW {
				self.selectedOptionChanged(.nsfw)
			} else if self.isSpoiler {
				self.selectedOptionChanged(.spoiler)
			} else {
				self.selectedOptionChanged(nil)
			}

			self.applyMarkdownFormatting(to: self.commentTextView)
		} else if let dmToUser = self.dmToUser, dmToUser != User.current {
			self.commentTextView.text = "@\(dmToUser.attributes.slug) "
			self.originalText = "@\(dmToUser.attributes.slug) "
			self.applyMarkdownFormatting(to: self.commentTextView)
		}

		// Populate OP views if applicable
		if let opFeedMessage = self.opFeedMessage {
			self.configureOPViews(with: opFeedMessage)
		}

		self.commentTextView.becomeFirstResponder()
	}

	// MARK: - Functions
	func configureCommentTextView() {
		let textStorage = NSTextStorage()
		let layoutManager = RichTextLayoutManager()
		let textContainer = NSTextContainer(size: .zero)

		textStorage.addLayoutManager(layoutManager)
		layoutManager.addTextContainer(textContainer)

		self.commentTextView.text = nil
		self.commentTextView.placeholder = self.placeholderText
		self.commentTextView.managedFormattingMode = true
	}

	private func configureNavigationItemsIfNeeded() {
		if self.navigationItem.leftBarButtonItem == nil {
			self.navigationItem.leftBarButtonItem = UIBarButtonItem(
				barButtonSystemItem: .cancel,
				target: self,
				action: #selector(self.dismissButtonPressed(_:))
			)
		}

		if self.navigationItem.rightBarButtonItem == nil {
			self.navigationItem.rightBarButtonItem = UIBarButtonItem(
				title: Trans.send,
				style: .done,
				target: self,
				action: #selector(self.sendButtonPressed(_:))
			)
		}
	}

	private func configureOPViews(with opFeedMessage: FeedMessage) {
		if let opUser = opFeedMessage.relationships.users.data.first {
			self.textEditorView.opUsernameLabel?.text = opUser.attributes.username

			if let opImageView = self.textEditorView.opProfileImageView {
				opUser.attributes.profileImage(imageView: opImageView)
			}
		}

		self.textEditorView.opMessageTextView?.setAttributedText(opFeedMessage.attributes.contentMarkdown.markdownAttributedString())
		self.textEditorView.opDateLabel?.text = opFeedMessage.attributes.createdAt.relativeToNow
	}

	/// Confirm whether to cancel the message.
	///
	/// - Parameter showingSend: Indicates whether to show the send message option.
	func confirmCancel(showingSend: Bool) {
		// Present a UIAlertController as an action sheet to have the user confirm losing any recent changes.
		let actionSheetAlertController = UIAlertController.actionSheet(title: nil, message: nil) { [weak self] actionSheetAlertController in
			guard let self = self else { return }
			// Only ask if the user wants to send if they attempt to pull to dismiss, not if they tap Cancel.
			if showingSend {
				// Send action.
				actionSheetAlertController.addAction(UIAlertAction(title: Trans.send, style: .default) { _ in
					Task {
						await self.sendMessage()
					}
				})
			}

			// Discard action.
			actionSheetAlertController.addAction(UIAlertAction(title: Trans.discard, style: .destructive) { _ in
				self.dismiss(animated: true, completion: nil)
			})
		}

		// Present the controller
		if let popoverController = actionSheetAlertController.popoverPresentationController {
			popoverController.barButtonItem = self.navigationItem.leftBarButtonItem
		}

		if (navigationController?.visibleViewController as? UIAlertController) == nil {
			self.present(actionSheetAlertController, animated: true, completion: nil)
		}
	}

	/// Send the feed message and dismiss this controller.
	func sendMessage() async {
		self.sendButton.isEnabled = false

		// Post is within the allowed character limit.
		if let characterCountString = self.characterCountLabel.text, let characterCount = Int(characterCountString), characterCount >= 0 {
			// Disable editing to hide the keyboard.
			self.view.endEditing(true)

			// Perform feed message request.
			await self.performFeedMessageRequest()
		} else {
			// Character limit reached. Present an alert to the user.
			self.presentAlertController(title: Trans.characterLimitReachedHeadline, message: Trans.characterLimitReachedSubheadline)
		}

		self.sendButton.isEnabled = true
	}

	/// Performs the request to post the feed message.
	func performFeedMessageRequest() async {
		if let feedMessage = self.editingFeedMessage {
			do {
				let feedMessageIdentity = FeedMessageIdentity(id: feedMessage.id)
				let feedMessageUpdateRequest = FeedMessageUpdateRequest(
					feedMessageIdentity: feedMessageIdentity,
					content: self.editedText,
					isNSFW: self.isNSFW,
					isSpoiler: self.isSpoiler
				)
				let feedMessageUpdateResponse = try await KService.updateMessage(feedMessageUpdateRequest).value
				let feedMessageUpdate = feedMessageUpdateResponse.data

				self.editingFeedMessage?.attributes.update(using: feedMessageUpdate)
				NotificationCenter.default.post(name: .KFMDidUpdate, object: nil, userInfo: self.userInfo)
				self.dismiss(animated: true, completion: nil)
			} catch {
				print("-----", error.localizedDescription)
			}
		} else {
			switch self.editorLayout {
			case .standard:
				do {
					let feedMessageRequest = FeedMessageRequest(content: self.editedText, parentIdentity: nil, isReply: nil, isReShare: nil, isNSFW: self.isNSFW, isSpoiler: self.isSpoiler)
					let feedMessagesResponse = try await KService.postFeedMessage(feedMessageRequest).value
					let feedMessages = feedMessagesResponse.data

					self.delegate?.kFeedMessageTextEditorView(updateMessagesWith: feedMessages)
				} catch {
					print("-----", error.localizedDescription)
				}

				self.dismiss(animated: true, completion: nil)

			case .reply:
				do {
					let parentFeedMessageIdentity = FeedMessageIdentity(id: self.opFeedMessage!.id)
					let feedMessageRequest = FeedMessageRequest(content: self.editedText, parentIdentity: parentFeedMessageIdentity, isReply: true, isReShare: false, isNSFW: self.isNSFW, isSpoiler: self.isSpoiler)
					let feedMessagesResponse = try await KService.postFeedMessage(feedMessageRequest).value
					let feedMessages = feedMessagesResponse.data

					if self.segueToOPFeedDetails {
						self.delegate?.segueToOPFeedDetails(self.opFeedMessage!)
					} else {
						self.delegate?.kFeedMessageTextEditorView(updateMessagesWith: feedMessages)
					}

					self.dismiss(animated: true, completion: nil)
				} catch {
					print("-----", error.localizedDescription)
				}

			case .reShare:
				do {
					let parentFeedMessageIdentity = FeedMessageIdentity(id: self.opFeedMessage!.id)
					let feedMessageRequest = FeedMessageRequest(content: self.editedText, parentIdentity: parentFeedMessageIdentity, isReply: false, isReShare: true, isNSFW: self.opFeedMessage!.attributes.isNSFW, isSpoiler: self.opFeedMessage!.attributes.isSpoiler)
					let feedMessagesResponse = try await KService.postFeedMessage(feedMessageRequest).value
					let feedMessages = feedMessagesResponse.data

					if self.segueToOPFeedDetails, let feedMessage = feedMessages.first {
						self.delegate?.segueToOPFeedDetails(feedMessage)
					} else {
						self.delegate?.kFeedMessageTextEditorView(updateMessagesWith: feedMessages)
					}

					self.dismiss(animated: true, completion: nil)
				} catch {
					print("-----", error.localizedDescription)
				}
			}
		}
	}

	/// Applies live markdown formatting to the text view while preserving cursor position.
	///
	/// - Parameter textView: The text view to format.
	private func applyMarkdownFormatting(to textView: UITextView) {
		guard !self.isUpdatingFormatting else { return }
		self.isUpdatingFormatting = true
		defer { self.isUpdatingFormatting = false }

		let selectedRange = textView.selectedRange
		let font = textView.font ?? .preferredFont(forTextStyle: .body)
		let textColor = KThemePicker.textColor.colorValue
		let tintColor = KThemePicker.tintColor.colorValue

		let formatted = self.markdownFormatter.format(
			textView.text,
			font: font,
			textColor: textColor,
			tintColor: tintColor
		)

		textView.attributedText = formatted

		// Restore cursor position.
		if selectedRange.location + selectedRange.length <= (textView.text as NSString).length {
			textView.selectedRange = selectedRange
		}

		// Reset typing attributes so new characters don't inherit formatting.
		textView.typingAttributes = [
			.font: font,
			.foregroundColor: textColor
		]
	}

	@objc private func handleThemeChange() {
		self.applyMarkdownFormatting(to: self.commentTextView)
	}

	// MARK: - IBActions
	@objc func dismissButtonPressed(_ sender: UIBarButtonItem) {
		if self.hasChanges {
			// The user tapped Cancel with unsaved changes. Confirm that it's OK to lose the changes.
			self.confirmCancel(showingSend: false)
		} else {
			// There are no unsaved changes. Dismiss immediately.
			self.dismiss(animated: true, completion: nil)
		}
	}

	@objc func sendButtonPressed(_ sender: UIBarButtonItem) {
		Task { [weak self] in
			guard let self = self else { return }
			await self.sendMessage()
		}
	}

	@objc func labelsButtonPressed(_ sender: UIButton) {
		guard (self.navigationController?.visibleViewController as? UIAlertController) == nil else { return }

		let selfLabelViewController = SelfLabelViewController()
		selfLabelViewController.selectedOption = self.selectedSelfLabel
		selfLabelViewController.delegate = self
		selfLabelViewController.modalPresentationStyle = .popover

		// Present the controller
		if let popoverController = selfLabelViewController.popoverPresentationController {
			popoverController.sourceView = sender
			popoverController.sourceRect = sender.bounds
			popoverController.adaptiveSheetPresentationController.prefersGrabberVisible = true
			popoverController.adaptiveSheetPresentationController.widthFollowsPreferredContentSizeWhenEdgeAttached = true
		}

		self.present(selfLabelViewController, animated: true, completion: nil)
	}
}

// MARK: - SelfLabelViewDelegate
extension KFeedMessageTextEditorViewController: SelfLabelViewDelegate {
	func selectedOptionChanged(_ option: SelfLabel?) {
		self.selectedSelfLabel = option

		switch option {
		case .spoiler:
			self.isSpoiler = true
			self.isNSFW = false
		case .nsfw:
			self.isSpoiler = false
			self.isNSFW = true
		case .both:
			self.isSpoiler = true
			self.isNSFW = true
		case nil:
			self.isSpoiler = false
			self.isNSFW = false
		}

		let labelsAdded = self.isSpoiler || self.isNSFW
		self.configureLabelsButton(title: labelsAdded ? "Labels Added" : "Labels", imageName: labelsAdded ? "checkmark" : "shield")
	}
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension KFeedMessageTextEditorViewController: UIAdaptivePresentationControllerDelegate {
	func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
		// The system calls this delegate method whenever the user attempts to pull down to dismiss and `isModalInPresentation` is false.
		// Clarify the user's intent by asking whether they want to cancel or send.
		self.confirmCancel(showingSend: true)
	}
}

// MARK: - UITextViewDelegate
extension KFeedMessageTextEditorViewController: UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		self.characterCountLabel.text = "\(FeedMessage.maxCharacterLimit - textView.text.count)"
		self.editedText = textView.text
		self.applyMarkdownFormatting(to: textView)
	}
}

// MARK: - UIToolbarDelegate
extension KFeedMessageTextEditorViewController: UIToolbarDelegate {
	func position(for bar: any UIBarPositioning) -> UIBarPosition {
		return .bottom
	}
}

private extension KFeedMessageTextEditorViewController {
	func configureLabelsButton(title: String, imageName: String) {
		self.labelsButton.titleLabel?.font = .preferredFont(forTextStyle: .subheadline)

		if var configuration = self.labelsButton.configuration {
			configuration.title = title
			configuration.image = UIImage(systemName: imageName)
			configuration.imagePlacement = .leading
			configuration.imagePadding = 6
			self.labelsButton.configuration = configuration
		}

		self.labelsButton.setTitle(title, for: .normal)
		self.labelsButton.setImage(UIImage(systemName: imageName), for: .normal)
	}
}
