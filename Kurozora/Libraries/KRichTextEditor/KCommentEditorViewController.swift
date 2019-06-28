//
//  KCommentEditorViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SwiftyJSON
import IQKeyboardManagerSwift

protocol KCommentEditorViewDelegate: class {
	func updateReplies(with threadRepliesElement: ThreadRepliesElement)
}

class KCommentEditorViewController: UIViewController {
	@IBOutlet weak var replyToTextLabel: UILabel! {
		didSet {
			replyToTextLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var replyToUsernameLabel: UILabel! {
		didSet {
			replyToUsernameLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}

	@IBOutlet weak var userAvatarImageView: UIImageView! {
		didSet {
			userAvatarImageView.theme_borderColor = KThemePicker.subTextColor.rawValue
		}
	}
	@IBOutlet weak var currentUsernameLabel: UILabel! {
		didSet {
			currentUsernameLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}

	@IBOutlet weak var characterCountLabel: UILabel! {
		didSet {
			characterCountLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}
	@IBOutlet weak var commentTextView: UITextView! {
		didSet {
			commentTextView.theme_textColor = KThemePicker.textColor.rawValue
		}
	}


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

	let charLimit = 240

	var forumThread: ForumThreadElement?
	weak var delegate: KCommentEditorViewDelegate?

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		IQKeyboardManager.shared.keyboardDistanceFromTextField = 0
		IQKeyboardManager.shared.shouldResignOnTouchOutside = false

		if let replyToText = forumThread?.title {
			replyToTextLabel.text = replyToText
		}

		if let replyToUsername = forumThread?.user?.username {
			replyToUsernameLabel.text = replyToUsername
		}

		let image = User.currentUserAvatar
		userAvatarImageView.image = image

		if let currentUsername = User.username {
			currentUsernameLabel.text = currentUsername
		}

		characterCountLabel.text = "240"

		commentTextView.delegate = self
		commentTextView.text = "Reply..."
		commentTextView.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.64)
		commentTextView.becomeFirstResponder()
		commentTextView.selectedTextRange = commentTextView.textRange(from: commentTextView.beginningOfDocument, to: commentTextView.beginningOfDocument)
	}

	// MARK: - IBActions
	@IBAction func dismissButtonPressed(_ sender: UIBarButtonItem) {
		IQKeyboardManager.shared.keyboardDistanceFromTextField = 100.0
		IQKeyboardManager.shared.shouldResignOnTouchOutside = true

		self.dismiss(animated: true, completion: nil)
	}

	@IBAction func replyButtonPressed(_ sender: UIBarButtonItem) {
		if let characterCount = characterCountLabel.text?.int, characterCount >= 0 {
			guard let comment = commentTextView.text, comment != "" else { return }
			guard let threadID = forumThread?.id else { return }
			Service.shared.postReply(withComment: comment, forThread: threadID) { (replyID) in
				DispatchQueue.main.async {
					let postedAt = Date().string(withFormat: "yyyy-MM-dd HH:mm:ss")
					let replyJSON: JSON = [
						"id": replyID,
						"posted_at": postedAt,
						"user": [
							"id": User.currentID!,
							"username": User.username!,
							"avatar": User.currentUserAvatar!
						],
						"score": 0,
						"content": comment
						]
					if let threadRepliesElement = try? ThreadRepliesElement(json: replyJSON) {
						self.delegate?.updateReplies(with: threadRepliesElement)
					}
				}
				self.dismiss(animated: true, completion: nil)
			}
		}
	}
}

extension KCommentEditorViewController: UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		characterCountLabel.text = "\(charLimit - commentTextView.text.count)"
	}

	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		// Combine the textView text and the replacement text to create the updated text string
 		let currentText: String = commentTextView.text
		let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)

		if updatedText.isEmpty { // If updated text view will be empty, add the placeholder and set the cursor to the beginning of the text view
			commentTextView.text = "Reply..."
			commentTextView.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.64)
			commentTextView.selectedTextRange = commentTextView.textRange(from: commentTextView.beginningOfDocument, to: commentTextView.beginningOfDocument)
			characterCountLabel.text = "\(charLimit)"
		} else if commentTextView.textColor == #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.64) && !text.isEmpty { // Else if the text view's placeholder is showing and the length of the replacement string is greater than 0, set the text color to white then set its text to the replacement string
			commentTextView.textColor = .white
			commentTextView.text = ""

			return true
		} else { // For every other case, the text should change with the usual behavior...
			if commentTextView.text.count + (text.count - range.length) >= charLimit { // If character count passed then change text to red
				characterCountLabel.textColor = #colorLiteral(red: 1, green: 0.3019607843, blue: 0.262745098, alpha: 1)
			} else if commentTextView.text.count + (text.count - range.length) <= charLimit { // Else reset color to 56% white
				characterCountLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.56)
			}
			
			return true
		}

		// ...otherwise return false since the updates have already been made
		return false
	}

	func textViewDidChangeSelection(_ textView: UITextView) {
		if self.view.window != nil {
			if commentTextView.textColor == #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.64) {
				commentTextView.selectedTextRange = commentTextView.textRange(from: commentTextView.beginningOfDocument, to: commentTextView.beginningOfDocument)
			}
		}
	}
}
