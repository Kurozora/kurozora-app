//
//  KFMReplyTextEditorViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class KFMReplyTextEditorViewController: KViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var isSpoilerSwitch: KSwitch!
	@IBOutlet weak var isNSFWSwitch: KSwitch!
	@IBOutlet weak var profileImageView: ProfileImageView!
	@IBOutlet weak var currentUsernameLabel: KLabel!
	@IBOutlet weak var characterCountLabel: UILabel!
	@IBOutlet weak var commentTextView: KTextView!
	@IBOutlet weak var commentPreviewContainer: UIView! {
		didSet {
			commentPreviewContainer.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}
	}

	@IBOutlet weak var opProfileImageView: ProfileImageView!
	@IBOutlet weak var opUsernameLabel: KLabel!
	@IBOutlet weak var opMessageTextView: KTextView!
	@IBOutlet weak var opDateTimeLabel: KSecondaryLabel!
	@IBOutlet weak var opMessagePreviewContainer: UIView! {
		didSet {
			commentPreviewContainer.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}
	}

	// MARK: - Properties
	let characterLimit = 240
	let placeholderText = "What's on your mind..."

	var opFeedMessage: FeedMessage!
	var segueToOPFeedDetails: Bool = false
	weak var delegate: KFeedMessageTextEditorViewDelegate?

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.profileImageView.image = User.current?.attributes.profileImage
		self.currentUsernameLabel.text = User.current?.attributes.username
		self.characterCountLabel.text = "\(characterLimit)"
		self.commentTextView.text = placeholderText
		self.commentTextView.theme_textColor = KThemePicker.textFieldPlaceholderTextColor.rawValue
		self.commentTextView.becomeFirstResponder()
		self.commentTextView.selectedTextRange = self.commentTextView.textRange(from: self.commentTextView.beginningOfDocument, to: self.commentTextView.beginningOfDocument)

		if let user = self.opFeedMessage.relationships.users.data.first {
			self.opProfileImageView.image = user.attributes.profileImage
			self.opUsernameLabel.text = user.attributes.username
		}
		self.opMessageTextView.text = self.opFeedMessage.attributes.body
		self.opDateTimeLabel.text = self.opFeedMessage.attributes.createdAt.timeAgo
	}

	// MARK: - IBActions
	@IBAction func dismissButtonPressed(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}

	@IBAction func sendButtonPressed(_ sender: UIBarButtonItem) {
		if let characterCount = characterCountLabel.text?.int, characterCount >= 0 {
			let feedMessage = commentTextView.text.trimmed
			if feedMessage.isEmpty || feedMessage == placeholderText && commentTextView.textColor == KThemePicker.textFieldPlaceholderTextColor.colorValue {
				return
			}

			self.view.endEditing(true)
			KService.postFeedMessage(withBody: feedMessage, relatedToParent: opFeedMessage.id, isReply: true, isReShare: false, isNSFW: isNSFWSwitch.isOn, isSpoiler: isSpoilerSwitch.isOn) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let feedMessages):
					if self.segueToOPFeedDetails {
						self.delegate?.segueToOPFeedDetails(self.opFeedMessage)
					} else {
						self.delegate?.updateMessages(with: feedMessages)
					}
					self.dismiss(animated: true, completion: nil)
				case .failure: break
				}
			}
		} else {
			self.presentAlertController(title: "Limit Reached", message: "You have exceeded the character limit for a message.")
		}
	}
}

// MARK: - UITextViewDelegate
extension KFMReplyTextEditorViewController: UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		characterCountLabel.text = "\(characterLimit - textView.text.count)"
	}

	func textViewDidBeginEditing(_ textView: UITextView) {
		if textView.text == placeholderText, textView.textColor == KThemePicker.textFieldPlaceholderTextColor.colorValue {
			textView.text = ""
			textView.theme_textColor = KThemePicker.textColor.rawValue
		}
	}

	func textViewDidEndEditing(_ textView: UITextView) {
		if textView.text.isEmpty {
			textView.text = placeholderText
			textView.theme_textColor = KThemePicker.textFieldPlaceholderTextColor.rawValue
		}
	}
}
