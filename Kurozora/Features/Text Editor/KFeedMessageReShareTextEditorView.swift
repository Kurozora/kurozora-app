//
//  KFMReShareTextEditorViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class KFMReShareTextEditorViewController: KViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var profileImageView: ProfileImageView!
	@IBOutlet weak var currentUsernameLabel: KLabel!
	@IBOutlet weak var characterCountLabel: KSecondaryLabel!
	@IBOutlet weak var commentTextView: KTextView!
	@IBOutlet weak var commentPreviewContainer: UIView! {
		didSet {
			commentPreviewContainer.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}
	}

	@IBOutlet weak var dateLabel: KSecondaryLabel!
	@IBOutlet weak var opProfileImageView: ProfileImageView!
	@IBOutlet weak var opUsernameLabel: KLabel!
	@IBOutlet weak var opBodyTextView: KTextView!

	// MARK: - Properties
	let characterLimit = 240
	let placeholderText = "Write a comment..."

	var opFeedMessage: FeedMessage!
	var segueToOPFeedDetails: Bool = false
	weak var delegate: KFeedMessageTextEditorViewDelegate?

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		profileImageView.image = User.current?.attributes.profileImage
		currentUsernameLabel.text = User.current?.attributes.username
		characterCountLabel.text = "\(characterLimit)"
		commentTextView.text = placeholderText
		commentTextView.theme_textColor = KThemePicker.textFieldPlaceholderTextColor.rawValue
		commentTextView.becomeFirstResponder()
		commentTextView.selectedTextRange = commentTextView.textRange(from: commentTextView.beginningOfDocument, to: commentTextView.beginningOfDocument)

		if let user = self.opFeedMessage.relationships.users.data.first {
			opUsernameLabel.text = user.attributes.username
			opProfileImageView.image = user.attributes.profileImage
		}
		opBodyTextView.text = self.opFeedMessage.attributes.body
		dateLabel.text = self.opFeedMessage.attributes.createdAt.timeAgo
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
			KService.postFeedMessage(withBody: feedMessage, relatedToParent: opFeedMessage.id, isReply: false, isReShare: true, isNSFW: opFeedMessage.attributes.isNSFW, isSpoiler: opFeedMessage.attributes.isSpoiler) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let feedMessages):
					if self.segueToOPFeedDetails, let feedMessage = feedMessages.first {
						self.delegate?.segueToOPFeedDetails(feedMessage)
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
extension KFMReShareTextEditorViewController: UITextViewDelegate {
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
