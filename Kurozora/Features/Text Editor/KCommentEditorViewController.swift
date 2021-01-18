//
//  KCommentEditorViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class KCommentEditorViewController: KViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var threadTitleLabel: KLabel!
	@IBOutlet weak var posterUsernameLabel: UILabel! {
		didSet {
			posterUsernameLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}

	@IBOutlet weak var profileImageView: ProfileImageView!
	@IBOutlet weak var currentUsernameLabel: KLabel!

	@IBOutlet weak var characterCountLabel: UILabel! {
		didSet {
			characterCountLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}
	@IBOutlet weak var commentTextView: KTextView!

	@IBOutlet weak var replyToUserContainer: UIView! {
		didSet {
			replyToUserContainer.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}
	}
	@IBOutlet weak var commentPreviewContainer: UIView! {
		didSet {
			commentPreviewContainer.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}
	}

	// MARK: - Properties
	let characterLimit = 240
	let placeholderText = "Reply..."

	var forumsThread: ForumsThread!
	weak var delegate: KCommentEditorViewDelegate?

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		threadTitleLabel.text = forumsThread.attributes.title

		if let user = forumsThread.relationships.users.data.first {
			posterUsernameLabel.text = user.attributes.username
		}

		profileImageView.image = User.current?.attributes.profileImage
		currentUsernameLabel.text = User.current?.attributes.username
		characterCountLabel.text = "\(characterLimit)"
		commentTextView.text = placeholderText
		commentTextView.theme_textColor = KThemePicker.textFieldPlaceholderTextColor.rawValue
		commentTextView.becomeFirstResponder()
		commentTextView.selectedTextRange = commentTextView.textRange(from: commentTextView.beginningOfDocument, to: commentTextView.beginningOfDocument)
	}

	// MARK: - IBActions
	@IBAction func dismissButtonPressed(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}

	@IBAction func replyButtonPressed(_ sender: UIBarButtonItem) {
		if let characterCount = characterCountLabel.text?.int, characterCount >= 0 {
			let comment = commentTextView.text.trimmed
			if comment.isEmpty || comment == placeholderText && commentTextView.textColor == KThemePicker.textFieldPlaceholderTextColor.colorValue {
				return
			}

			self.view.endEditing(true)
			KService.postReply(inThread: forumsThread.id, withComment: comment) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let threadReplies):
					self.delegate?.kCommentEditorView(updateRepliesWith: threadReplies)
					self.dismiss(animated: true, completion: nil)
				case .failure: break
				}
			}
		} else {
			self.presentAlertController(title: "Limit Reached", message: "You have exceeded the character limit for a reply.")
		}
	}
}

// MARK: - UITextViewDelegate
extension KCommentEditorViewController: UITextViewDelegate {
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
