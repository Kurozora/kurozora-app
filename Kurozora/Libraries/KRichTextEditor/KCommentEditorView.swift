//
//  KCommentEditorView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SwiftyJSON
import IQKeyboardManagerSwift

class KCommentEditorView: UIViewController {
	@IBOutlet weak var replyToTextLabel: UILabel!
	@IBOutlet weak var replyToUsernameLabel: UILabel!

	@IBOutlet weak var userAvatarImageView: UIImageView!
	@IBOutlet weak var currentUsernameLabel: UILabel!

	@IBOutlet weak var characterCountLabel: UILabel!
	@IBOutlet weak var commentTextView: UITextView!

	let charLimit = 240

	var forumThread: JSON?

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		IQKeyboardManager.shared.keyboardDistanceFromTextField = 0
		IQKeyboardManager.shared.shouldResignOnTouchOutside = false

		if let replyToText = forumThread?["title"].stringValue {
			replyToTextLabel.text = replyToText
		}

		if let replyToUsername = forumThread?["poster_username"].stringValue {
			replyToUsernameLabel.text = replyToUsername
		}

		let image = User.currentUserAvatar()
		userAvatarImageView.image = image

		if let currentUsername = User.username() {
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
			guard let threadID = forumThread?["id"].intValue else { return }
			Service.shared.postReply(withComment: comment, forThread: threadID) { (success) in
				if success {
					self.dismiss(animated: true, completion: nil)
				}
			}
		}
	}
}

extension KCommentEditorView: UITextViewDelegate {
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
