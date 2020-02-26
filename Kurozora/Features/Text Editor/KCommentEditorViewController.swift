//
//  KCommentEditorViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SCLAlertView
import SwiftyJSON

protocol KCommentEditorViewDelegate: class {
	func updateReplies(with threadRepliesElement: ThreadRepliesElement)
}

class KCommentEditorViewController: KViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var threadTitleLabel: UILabel! {
		didSet {
			threadTitleLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var posterUsernameLabel: UILabel! {
		didSet {
			posterUsernameLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}

	@IBOutlet weak var profileImageView: UIImageView! {
		didSet {
			profileImageView.theme_borderColor = KThemePicker.borderColor.rawValue
		}
	}
	@IBOutlet weak var currentUsernameLabel: UILabel! {
		didSet {
			currentUsernameLabel.theme_textColor = KThemePicker.textColor.rawValue
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
			commentTextView.textContainerInset = .zero
			commentTextView.textContainer.lineFragmentPadding = 0
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

	// MARK: - Properties
	let characterLimit = 240
	let placeholderText = "Reply..."

	var forumsThreadElement: ForumsThreadElement?
	weak var delegate: KCommentEditorViewDelegate?

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		if let threadTitle = forumsThreadElement?.title {
			threadTitleLabel.text = threadTitle
		}

		if let posterUsername = forumsThreadElement?.posterUsername {
			posterUsernameLabel.text = posterUsername
		}

		if let profileImage = Kurozora.shared.KDefaults["profile_image"] {
			if let usernameInitials = Kurozora.shared.KDefaults["username"]?.initials {
				let placeholderImage = usernameInitials.toImage(placeholder: R.image.placeholders.profile_image()!)
				profileImageView.setImage(with: profileImage, placeholder: placeholderImage)
			}
		}
		currentUsernameLabel.text = User.username

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
			guard let threadID = forumsThreadElement?.id else { return }
			let comment = commentTextView.text.trimmed
			if comment.isEmpty || comment == placeholderText && commentTextView.textColor == KThemePicker.textFieldPlaceholderTextColor.colorValue {
				return
			}

			KService.shared.postReply(inThread: threadID, withComment: comment) { (replyID) in
				DispatchQueue.main.async {
					let postedAt = Date().string(withFormat: "yyyy-MM-dd HH:mm:ss")
					let replyJSON: JSON = [
						"id": replyID,
						"posted_at": postedAt,
						"poster": [
							"id": User.currentID,
							"username": User.username,
							"avatar_url": User.profileImage
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
		} else {
			SCLAlertView().showWarning("Character limit reached!", subTitle: "You have exceeded the character limit for a reply.")
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
