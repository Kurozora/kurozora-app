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
	var hasChanges: Bool {
		return self.originalText != self.editedText
	}
	weak var delegate: KFeedMessageTextEditorViewDelegate?

	// MARK: - View
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()

		// If there are unsaved changes, enable the Save button and disable the ability to
		// dismiss using the pull-down gesture.
		self.navigationItem.rightBarButtonItem?.isEnabled = self.hasChanges
		self.isModalInPresentation = self.hasChanges
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		if let user = User.current {
			self.currentUsernameLabel.text = user.attributes.username
			self.profileImageView.setImage(with: user.attributes.profile?.url ?? "", placeholder: user.attributes.placeholderImage)
		}
		self.characterCountLabel.text = "\(self.characterLimit)"
		self.commentTextView.text = self.placeholderText
		self.commentTextView.theme_textColor = KThemePicker.textFieldPlaceholderTextColor.rawValue
		self.commentTextView.becomeFirstResponder()
		self.commentTextView.selectedTextRange = self.commentTextView.textRange(from: self.commentTextView.beginningOfDocument, to: self.commentTextView.beginningOfDocument)
	}

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
			// Trim any spaces and make sure the text isn't a placeholder
			let feedMessage = self.commentTextView.text.trimmed

			// Disable editing to hide the keyboard.
			self.view.endEditing(true)

			// Perform feed message request.
			self.performFeedMessageRequest(feedMessage: feedMessage)
		} else {
			// Character limit reached. Present an alert to the user.
			self.presentAlertController(title: "Limit Reached", message: "You have exceeded the character limit for a message.")
		}
	}

	/**
		Performs the request to post the feed message.
	 
		- Parameter feedMessage: The feed message to post.
	*/
	func performFeedMessageRequest(feedMessage: String) {
		KService.postFeedMessage(withBody: feedMessage, relatedToParent: nil, isReply: nil, isReShare: nil, isNSFW: self.isNSFWSwitch.isOn, isSpoiler: self.isSpoilerSwitch.isOn) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let feedMessages):
				self.delegate?.kFeedMessageTextEditorView(updateMessagesWith: feedMessages)
				self.dismiss(animated: true, completion: nil)
			case .failure: break
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
