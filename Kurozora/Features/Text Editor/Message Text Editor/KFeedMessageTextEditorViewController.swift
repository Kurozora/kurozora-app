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
	func kFeedMessageTextEditorView(openDraftInNewComposer draft: FeedMessageDraft)
}

extension KFeedMessageTextEditorViewDelegate where Self: UIViewController {
	func kFeedMessageTextEditorView(openDraftInNewComposer draft: FeedMessageDraft) {
		let editor = KFeedMessageTextEditorViewController()
		editor.editorLayout = draft.editorLayout
		editor.pendingDraft = draft
		editor.delegate = self as (any KFeedMessageTextEditorViewDelegate)

		let kurozoraNavigationController = KNavigationController(rootViewController: editor)
		kurozoraNavigationController.presentationController?.delegate = editor
		kurozoraNavigationController.navigationBar.prefersLargeTitles = false
		kurozoraNavigationController.sheetPresentationController?.detents = [.medium(), .large()]
		kurozoraNavigationController.sheetPresentationController?.selectedDetentIdentifier = .large
		kurozoraNavigationController.sheetPresentationController?.prefersEdgeAttachedInCompactHeight = true
		kurozoraNavigationController.sheetPresentationController?.prefersGrabberVisible = true
		self.present(kurozoraNavigationController, animated: true)
	}
}

class KFeedMessageTextEditorViewController: KViewController {
	// MARK: - Views
	private lazy var textEditorView = KFeedMessageTextEditorView(layout: self.editorLayout)

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

	private(set) lazy var postButton: UIBarButtonItem = {
		return UIBarButtonItem(
			title: Trans.post,
			style: .done,
			target: self,
			action: #selector(self.postButtonPressed(_:))
		)
	}()

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
	private var isEndingEditing = false

	/// A draft to load automatically after the view loads.
	/// Set before presentation when reopening a composer for a layout-mismatched draft.
	var pendingDraft: FeedMessageDraft?

	/// The parent message ID from a draft's snapshot, used as a fallback
	/// when `opFeedMessage` is nil (i.e., draft loaded without a live FeedMessage).
	private var draftParentMessageID: String?

	/// The UUID of the draft currently loaded in the editor, if any.
	private var activeDraftUUID: UUID?

	/// Bar button item for accessing saved drafts.
	private lazy var draftsBarButtonItem: UIBarButtonItem = {
		return UIBarButtonItem(
			image: UIImage(systemName: "archivebox"),
			style: .plain,
			target: self,
			action: #selector(self.draftsButtonPressed(_:))
		)
	}()

	private(set) lazy var mentionAutocompleteController: MentionAutocompleteController = {
		let controller = MentionAutocompleteController(
			collectionView: self.textEditorView.mentionCollectionView,
			collapsedConstraint: self.textEditorView.mentionCollapsedConstraint,
			expandedConstraint: self.textEditorView.mentionExpandedConstraint
		)
		controller.delegate = self
		return controller
	}()

	/// The account selected for this composer session.
	///
	/// When `nil`, defaults to the globally signed-in user (`User.current`).
	private var composerAccount: StoredAccount?

	/// The active mention range when "Find" search is invoked, used to insert the result.
	private var pendingMentionRange: NSRange?

	// MARK: - View
	override func loadView() {
		self.view = self.textEditorView
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
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

		self.configureNavigationItemsIfNeeded()
		self.configureCommentTextView()

		if let user = User.current {
			self.currentUsernameLabel.text = user.attributes.username
			user.attributes.profileImage(imageView: self.profileImageView)
			self.isNSFW = user.attributes.preferredTVRating ?? 4 > 4
		}

		if AccountManager.shared.allAccounts().count > 1 {
			let profileImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleAccountSwitcherTapGesture))
			self.profileImageView.isUserInteractionEnabled = true
			self.profileImageView.accessibilityTraits.insert(.button)
			self.profileImageView.addGestureRecognizer(profileImageTapGesture)

			let usernameTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleAccountSwitcherTapGesture))
			self.currentUsernameLabel.isUserInteractionEnabled = true
			self.currentUsernameLabel.accessibilityTraits.insert(.button)
			self.currentUsernameLabel.addGestureRecognizer(usernameTapGesture)
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

		// Initialize mention autocomplete controller to trigger lazy init
		_ = self.mentionAutocompleteController

		// Load pending draft
		if let draft = self.pendingDraft {
			self.pendingDraft = nil
			self.loadDraft(draft)
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
			self.navigationItem.rightBarButtonItem = self.postButton
		}

		self.updateDraftsButtonVisibility()
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
				actionSheetAlertController.addAction(UIAlertAction(title: Trans.post, style: .default) { _ in
					Task {
						await self.sendMessage()
					}
				})
			}

			// Save Draft action.
			actionSheetAlertController.addAction(UIAlertAction(title: Trans.saveDraft, style: .default) { _ in
				self.saveDraft()
				self.isEndingEditing = true
				self.dismiss(animated: true, completion: nil)
			})

			// Discard action.
			actionSheetAlertController.addAction(UIAlertAction(title: Trans.discard, style: .destructive) { _ in
				self.isEndingEditing = true
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
		self.postButton.isEnabled = false

		// Post is within the allowed character limit.
		if let characterCountString = self.characterCountLabel.text, let characterCount = Int(characterCountString), characterCount >= 0 {
			// Disable editing to hide the keyboard.
			self.isEndingEditing = true
			self.view.endEditing(true)

			// Perform feed message request.
			await self.performFeedMessageRequest()
		} else {
			// Character limit reached. Present an alert to the user.
			self.presentAlertController(title: Trans.characterLimitReachedHeadline, message: Trans.characterLimitReachedSubheadline)
		}

		self.postButton.isEnabled = true
	}

	/// Performs the request to post the feed message.
	func performFeedMessageRequest() async {
		let originalAuthKey = KService.authenticationKey
		if let composerAccount = self.composerAccount {
			KService.authenticationKey = composerAccount.authenticationToken
		}
		defer {
			if self.composerAccount != nil {
				KService.authenticationKey = originalAuthKey
			}
		}

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
				self.deleteDraftIfActive()
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

				self.deleteDraftIfActive()
				self.dismiss(animated: true, completion: nil)

			case .reply:
				do {
					guard let parentID = self.opFeedMessage?.id ?? self.draftParentMessageID.map({ KurozoraItemID(rawValue: $0) }) else { return }
					let parentFeedMessageIdentity = FeedMessageIdentity(id: parentID)
					let feedMessageRequest = FeedMessageRequest(content: self.editedText, parentIdentity: parentFeedMessageIdentity, isReply: true, isReShare: false, isNSFW: self.isNSFW, isSpoiler: self.isSpoiler)
					let feedMessagesResponse = try await KService.postFeedMessage(feedMessageRequest).value
					let feedMessages = feedMessagesResponse.data

					if self.segueToOPFeedDetails, let opFeedMessage = self.opFeedMessage {
						self.delegate?.segueToOPFeedDetails(opFeedMessage)
					} else {
						self.delegate?.kFeedMessageTextEditorView(updateMessagesWith: feedMessages)
					}

					self.deleteDraftIfActive()
					self.dismiss(animated: true, completion: nil)
				} catch {
					print("-----", error.localizedDescription)
				}

			case .reShare:
				do {
					guard let parentID = self.opFeedMessage?.id ?? self.draftParentMessageID.map({ KurozoraItemID(rawValue: $0) }) else { return }
					let parentFeedMessageIdentity = FeedMessageIdentity(id: parentID)
					let feedMessageRequest = FeedMessageRequest(content: self.editedText, parentIdentity: parentFeedMessageIdentity, isReply: false, isReShare: true, isNSFW: self.opFeedMessage?.attributes.isNSFW ?? self.isNSFW, isSpoiler: self.opFeedMessage?.attributes.isSpoiler ?? self.isSpoiler)
					let feedMessagesResponse = try await KService.postFeedMessage(feedMessageRequest).value
					let feedMessages = feedMessagesResponse.data

					if self.segueToOPFeedDetails, let feedMessage = feedMessages.first {
						self.delegate?.segueToOPFeedDetails(feedMessage)
					} else {
						self.delegate?.kFeedMessageTextEditorView(updateMessagesWith: feedMessages)
					}

					self.deleteDraftIfActive()
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

	@objc private func handleKeyboardWillHide() {
		self.mentionAutocompleteController.update(for: nil)
	}

	// MARK: - Drafts
	/// Updates the visibility of the drafts bar button item.
	///
	/// The button is shown in the right bar button items when:
	/// - The composer text is empty
	/// - There are saved drafts for the current account
	private func updateDraftsButtonVisibility() {
		guard let slug = self.effectiveSlug else { return }
		let hasDrafts = DraftStore.shared.draftCount(forUserSlug: slug) > 0
		let shouldShow = self.editedText.isEmpty && hasDrafts
		let isShowing = self.navigationItem.rightBarButtonItems?.contains(self.draftsBarButtonItem) == true

		if shouldShow, !isShowing {
			self.navigationItem.rightBarButtonItems = [
				self.postButton,
				self.draftsBarButtonItem
			]
		} else if !shouldShow, isShowing {
			self.navigationItem.rightBarButtonItems = [self.postButton]
		}
	}

	/// Saves the current editor state as a draft.
	private func saveDraft() {
		guard let slug = self.effectiveSlug else { return }

		if let existingUUID = self.activeDraftUUID {
			DraftStore.shared.updateDraft(
				uuid: existingUUID,
				content: self.editedText,
				isNSFW: self.isNSFW,
				isSpoiler: self.isSpoiler
			)
		} else {
			let request = DraftRequest(
				userSlug: slug,
				content: self.editedText,
				layout: self.editorLayout,
				isNSFW: self.isNSFW,
				isSpoiler: self.isSpoiler,
				parentMessage: self.opFeedMessage,
				editingMessageID: self.editingFeedMessage.map { String(describing: $0.id) }
			)
			self.activeDraftUUID = DraftStore.shared.saveDraft(request)
		}
	}

	/// Deletes the active draft after a successful post.
	private func deleteDraftIfActive() {
		guard let uuid = self.activeDraftUUID else { return }
		DraftStore.shared.deleteDraft(uuid: uuid)
		self.activeDraftUUID = nil
	}

	/// Populates the composer with the contents of a draft.
	///
	/// - Parameter draft: The draft to load.
	private func loadDraft(_ draft: FeedMessageDraft) {
		self.activeDraftUUID = draft.uuid
		self.commentTextView.text = draft.content
		self.editedText = draft.content
		self.originalText = draft.content

		// Restore labels
		let nsfw = draft.isNSFW
		let spoiler = draft.isSpoiler
		self.isNSFW = nsfw
		self.isSpoiler = spoiler

		if nsfw && spoiler {
			self.selectedOptionChanged(.both)
		} else if nsfw {
			self.selectedOptionChanged(.nsfw)
		} else if spoiler {
			self.selectedOptionChanged(.spoiler)
		} else {
			self.selectedOptionChanged(nil)
		}

		// Restore parent context from snapshot if applicable
		if let snapshot = draft.parentSnapshot {
			self.draftParentMessageID = snapshot.messageID
			self.configureOPViews(with: snapshot)
		}

		self.applyMarkdownFormatting(to: self.commentTextView)
		self.textViewDidChange(self.commentTextView)
	}

	/// Configures the OP preview views using a persisted snapshot.
	///
	/// - Parameter snapshot: The parent message snapshot.
	private func configureOPViews(with snapshot: FeedMessageSnapshot) {
		self.textEditorView.opUsernameLabel?.text = snapshot.authorUsername
		self.textEditorView.opMessageTextView?.setAttributedText(snapshot.contentMarkdown.markdownAttributedString())
		self.textEditorView.opDateLabel?.text = snapshot.createdAt.relativeToNow

		if let urlString = snapshot.authorProfileImageURL, let opImageView = self.textEditorView.opProfileImageView {
			opImageView.setImage(with: urlString, placeholder: .Placeholders.userProfile)
		}
	}

	/// The slug of the account currently active in this composer session.
	private var effectiveSlug: String? {
		return self.composerAccount?.slug ?? User.current?.attributes.slug
	}

	@objc private func handleAccountSwitcherTapGesture() {
		let switchAccountsVC = SwitchAccountsTableViewController()
		switchAccountsVC.delegate = self
		switchAccountsVC.selectedSlug = self.composerAccount?.slug ?? User.current?.attributes.slug

		let nav = KNavigationController(rootViewController: switchAccountsVC)
		nav.navigationBar.prefersLargeTitles = false
		if let sheet = nav.sheetPresentationController {
			sheet.detents = [.medium(), .large()]
			sheet.prefersGrabberVisible = true
		}
		self.present(nav, animated: true)
	}

	private func updateHeaderForComposerAccount() {
		guard let account = self.composerAccount else { return }
		self.currentUsernameLabel.text = account.username ?? account.slug
		let placeholder = (account.username ?? account.slug).profilePlaceholderImage
		self.profileImageView.setImage(with: account.profileImageURL ?? "", placeholder: placeholder)
	}

	// MARK: - IBActions
	@objc func dismissButtonPressed(_ sender: UIBarButtonItem) {
		if self.hasChanges {
			// The user tapped Cancel with unsaved changes. Confirm that it's OK to lose the changes.
			self.confirmCancel(showingSend: false)
		} else {
			// There are no unsaved changes. Dismiss immediately.
			self.isEndingEditing = true
			self.dismiss(animated: true, completion: nil)
		}
	}

	@objc private func draftsButtonPressed(_ sender: UIBarButtonItem) {
		guard let slug = self.effectiveSlug else { return }

		let draftsVC = FeedMessageDraftsTableViewController()
		draftsVC.userSlug = slug
		draftsVC.delegate = self

		let navigationController = KNavigationController(rootViewController: draftsVC)
		navigationController.navigationBar.prefersLargeTitles = false
		if let sheet = navigationController.sheetPresentationController {
			sheet.detents = [.large()]
			sheet.prefersGrabberVisible = true
		}

		self.present(navigationController, animated: true)
	}

	@objc func postButtonPressed(_ sender: UIBarButtonItem) {
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

	private func configureLabelsButton(title: String, imageName: String) {
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
	func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
		return self.isEndingEditing ||
			self.presentedViewController != nil ||
			self.isBeingDismissed ||
			self.navigationController?.isBeingDismissed == true
	}

	func textViewDidChange(_ textView: UITextView) {
		self.characterCountLabel.text = "\(FeedMessage.maxCharacterLimit - textView.text.count)"
		self.editedText = textView.text
		self.applyMarkdownFormatting(to: textView)

		let mentionContext = MentionTracker.activeMention(in: textView)
		self.mentionAutocompleteController.update(for: mentionContext)

		self.updateDraftsButtonVisibility()
	}
}

// MARK: - UIToolbarDelegate
extension KFeedMessageTextEditorViewController: UIToolbarDelegate {
	func position(for bar: any UIBarPositioning) -> UIBarPosition {
		return .bottom
	}
}

// MARK: - MentionAutocompleteControllerDelegate
extension KFeedMessageTextEditorViewController: MentionAutocompleteControllerDelegate {
	func mentionAutocompleteController(_ controller: MentionAutocompleteController, didSelectUser user: User, forMentionIn range: NSRange) {
		self.insertMention(slug: user.attributes.slug, replacingRange: range)
	}

	func mentionAutocompleteControllerDidSelectSearch(_ controller: MentionAutocompleteController, query: String, userIdentities: [UserIdentity], cache: [IndexPath: KurozoraItem]) {
		self.pendingMentionRange = MentionTracker.activeMention(in: self.commentTextView)?.range

		let usersListVC = UsersListCollectionViewController()
		usersListVC.usersListFetchType = .search
		usersListVC.mentionSelectionDelegate = self

		if !query.isEmpty {
			usersListVC.searchQuery = query
			usersListVC.userIdentities = userIdentities
			usersListVC.cache = cache
		}

		let navigationController = KNavigationController(rootViewController: usersListVC)
		self.present(navigationController, animated: true)
	}

	func mentionAutocompleteController(_ controller: MentionAutocompleteController, didUpdateVisibility isVisible: Bool) {}

	private func insertMention(slug: String, replacingRange range: NSRange) {
		let replacement = "@\(slug) "
		guard
			let textView = self.commentTextView as UITextView?,
			let textRange = Range(range, in: textView.text)
		else { return }

		var newText = textView.text ?? ""
		newText.replaceSubrange(textRange, with: replacement)
		textView.text = newText

		// Move cursor after the inserted mention
		let newCursorPosition = range.location + (replacement as NSString).length
		textView.selectedRange = NSRange(location: newCursorPosition, length: 0)

		// Update character count
		self.textViewDidChange(textView)
	}
}

// MARK: - UsersListMentionSelectionDelegate
extension KFeedMessageTextEditorViewController: UsersListMentionSelectionDelegate {
	func usersListCollectionViewController(_ controller: UsersListCollectionViewController, didSelectUserForMention user: User) {
		let range = self.pendingMentionRange ?? NSRange(location: self.commentTextView.selectedRange.location, length: 0)
		self.insertMention(slug: user.attributes.slug, replacingRange: range)
		self.pendingMentionRange = nil
	}
}

// MARK: - FeedMessageDraftsTableViewControllerDelegate
extension KFeedMessageTextEditorViewController: FeedMessageDraftsTableViewControllerDelegate {
	func draftListViewController(_ controller: FeedMessageDraftsTableViewController, didSelectDraft draft: FeedMessageDraft) {
		if draft.editorLayout == self.editorLayout {
			// Load in current view since it's the same layout.
			controller.dismiss(animated: true) { [weak self] in
				guard let self = self else { return }
				self.loadDraft(draft)
			}
		} else {
			// Dismiss view and reopen with the correct layout.
			controller.dismiss(animated: true) { [weak self] in
				guard let self = self else { return }
				self.isEndingEditing = true
				self.dismiss(animated: true) {
					self.delegate?.kFeedMessageTextEditorView(openDraftInNewComposer: draft)
				}
			}
		}
	}
}

// MARK: - SwitchAccountsTableViewControllerDelegate
extension KFeedMessageTextEditorViewController: SwitchAccountsTableViewControllerDelegate {
	func switchAccountsTableViewController(
		_ controller: SwitchAccountsTableViewController,
		didSelect account: StoredAccount
	) {
		self.composerAccount = account
		self.activeDraftUUID = nil
		self.updateHeaderForComposerAccount()
		self.updateDraftsButtonVisibility()
		controller.dismiss(animated: true)
	}
}
