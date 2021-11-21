//
//  KFeedMessageTextEditorViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class KFeedMessageTextEditorViewController: KViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var isSpoilerSwitch: KSwitch!
	@IBOutlet weak var isNSFWSwitch: KSwitch!
	@IBOutlet weak var profileImageView: ProfileImageView!
	@IBOutlet weak var currentUsernameLabel: KLabel!
	@IBOutlet weak var characterCountLabel: UILabel! {
		didSet {
			self.characterCountLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}
	@IBOutlet weak var commentTextView: KTextView!
	@IBOutlet weak var commentPreviewContainer: UIView! {
		didSet {
			self.commentPreviewContainer.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}
	}

	// MARK: - Properties
	let characterLimit = 240
	var placeholderText: String {
		return "What's on your mind..."
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
	var userInfo: [AnyHashable: Any]?
	weak var delegate: KFeedMessageTextEditorViewDelegate?

	// MARK: - View
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()

		// If there are unsaved changes, enable the Save button and disable the ability to
		// dismiss using the pull-down gesture.
		self.navigationItem.rightBarButtonItem?.isEnabled = self.hasChanges
		self.isModalInPresentation = self.hasChanges
	}

//	@objc func keyboardWillShow(sender: NSNotification) {
//		self.view.frame.origin.y = -150 // Move view 150 points upward
//	}
//
//	@objc func keyboardWillHide(sender: NSNotification) {
//		self.view.frame.origin.y = 0 // Move view to original position
//	}
//
//	override func viewWillAppear(_ animated: Bool) {
//		super.viewWillAppear(animated)
//		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
//		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
//
//	}

	override func viewDidLoad() {
		super.viewDidLoad()

		if let user = User.current {
			self.currentUsernameLabel.text = user.attributes.username
			self.profileImageView.image = user.attributes.profileImage
		}

		self.characterCountLabel.text = "\(self.characterLimit)"

		if let feedMessage = self.editingFeedMessage {
			self.commentTextView.text = nil
			self.commentTextView.insertText(feedMessage.attributes.body)
			self.originalText = feedMessage.attributes.body
			self.isNSFWSwitch?.isOn = feedMessage.attributes.isNSFW
			self.originalNSFW = feedMessage.attributes.isNSFW
			self.isSpoilerSwitch?.isOn = feedMessage.attributes.isSpoiler
			self.originalSpoiler = feedMessage.attributes.isSpoiler
		} else {
			self.commentTextView.text = self.placeholderText
			self.commentTextView.theme_textColor = KThemePicker.textFieldPlaceholderTextColor.rawValue
			self.commentTextView.selectedTextRange = self.commentTextView.textRange(from: self.commentTextView.beginningOfDocument, to: self.commentTextView.beginningOfDocument)
		}
		self.commentTextView.becomeFirstResponder()
	}

//	override func viewWillDisappear(_ animated: Bool) {
//		super.viewWillDisappear(animated)
//		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
//		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
//	}

	// MARK: - Functions
	/**
		Confirm whether to cancel the message.

		- Parameter showingSend: Indicates whether to show the send message option.
	*/
	func confirmCancel(showingSend: Bool) {
		// Present a UIAlertController as an action sheet to have the user confirm losing any recent changes.
		let actionSheetAlertController = UIAlertController.actionSheet(title: nil, message: nil) { [weak self] actionSheetAlertController in
			// Only ask if the user wants to send if they attempt to pull to dismiss, not if they tap Cancel.
			if showingSend {
				// Send action.
				actionSheetAlertController.addAction(UIAlertAction(title: "Send", style: .default) { _ in
					self?.sendMessage()
				})
			}

			// Discard action.
			actionSheetAlertController.addAction(UIAlertAction(title: "Discard", style: .destructive) { _ in
				self?.dismiss(animated: true, completion: nil)
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
	func sendMessage() {
		// Post is within the allowed character limit.
		if let characterCount = self.characterCountLabel.text?.int, characterCount >= 0 {
			// Disable editing to hide the keyboard.
			self.view.endEditing(true)

			// Perform feed message request.
			self.performFeedMessageRequest()
		} else {
			// Character limit reached. Present an alert to the user.
			self.presentAlertController(title: "Limit Reached", message: "You have exceeded the character limit for a message.")
		}
	}

	/// Performs the request to post the feed message.
	func performFeedMessageRequest() {
		if let feedMessage = self.editingFeedMessage {
			KService.updateMessage(feedMessage.id, withBody: self.editedText, isNSFW: self.isNSFWSwitch.isOn, isSpoiler: self.isSpoilerSwitch.isOn) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let feedMessageUpdate):
					self.editingFeedMessage?.attributes.update(using: feedMessageUpdate)
					NotificationCenter.default.post(name: .KFMDidUpdate, object: nil, userInfo: self.userInfo)
					self.dismiss(animated: true, completion: nil)
				case .failure: break
				}
			}
		} else {
			KService.postFeedMessage(withBody: self.editedText, relatedToParent: nil, isReply: nil, isReShare: nil, isNSFW: self.isNSFWSwitch.isOn, isSpoiler: self.isSpoilerSwitch.isOn) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let feedMessages):
					self.delegate?.kFeedMessageTextEditorView(updateMessagesWith: feedMessages)
					self.dismiss(animated: true, completion: nil)
				case .failure: break
				}
			}
		}
	}

	// MARK: - IBActions
	@IBAction func dismissButtonPressed(_ sender: UIBarButtonItem) {
		if self.hasChanges {
			// The user tapped Cancel with unsaved changes. Confirm that it's OK to lose the changes.
			self.confirmCancel(showingSend: false)
		} else {
			// There are no unsaved changes. Dismiss immediately.
			self.dismiss(animated: true, completion: nil)
		}
	}

	@IBAction func sendButtonPressed(_ sender: UIBarButtonItem) {
		// Post the feed message and dismiss the controller.
		self.sendMessage()
	}

	@IBAction func nsfwSwitchChanged(_ sender: UISwitch) {
		self.editedNSFW = sender.isOn
	}

	@IBAction func spoilertSwitchChanged(_ sender: UISwitch) {
		self.editedSpoiler = sender.isOn
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
		self.characterCountLabel.text = "\(self.characterLimit - textView.text.count)"
		self.editedText = textView.text
	}

	func textViewDidBeginEditing(_ textView: UITextView) {
		if textView.text == self.placeholderText, textView.textColor == KThemePicker.textFieldPlaceholderTextColor.colorValue {
			textView.text = ""
			textView.theme_textColor = KThemePicker.textColor.rawValue
		}
	}

	func textViewDidEndEditing(_ textView: UITextView) {
		if textView.text.isEmpty {
			textView.text = self.placeholderText
			textView.theme_textColor = KThemePicker.textFieldPlaceholderTextColor.rawValue
		}
	}
}
