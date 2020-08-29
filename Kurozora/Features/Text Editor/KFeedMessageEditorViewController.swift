//
//  KFeedMessageEditorViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import SCLAlertView

protocol KFeedMessageEditorViewDelegate: class {
	func updateMessages(with feedMessages: [FeedMessage])
}

class KFeedMessageEditorViewController: KViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var isSpoilerSwitch: KSwitch!
	@IBOutlet weak var isNSFWSwitch: KSwitch!

	@IBOutlet weak var profileImageView: ProfileImageView!
	@IBOutlet weak var currentUsernameLabel: KLabel!

	@IBOutlet weak var characterCountLabel: UILabel! {
		didSet {
			characterCountLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}
	@IBOutlet weak var commentTextView: KTextView! {
		didSet {
			commentTextView.textContainerInset = .zero
			commentTextView.textContainer.lineFragmentPadding = 0
		}
	}

	@IBOutlet weak var commentPreviewContainer: UIView! {
		didSet {
			commentPreviewContainer.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}
	}

	// MARK: - Properties
	let characterLimit = 240
	let placeholderText = "What's on your mind..."

	weak var delegate: KFeedMessageEditorViewDelegate?

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
	}

	// MARK: - IBActions
	@IBAction func dismissButtonPressed(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}

	@IBAction func replyButtonPressed(_ sender: UIBarButtonItem) {
		if let characterCount = characterCountLabel.text?.int, characterCount >= 0 {
			let feedMessage = commentTextView.text.trimmed
			if feedMessage.isEmpty || feedMessage == placeholderText && commentTextView.textColor == KThemePicker.textFieldPlaceholderTextColor.colorValue {
				return
			}

			KService.postFeedMessage(withBody: feedMessage, relatedToParent: nil, isReply: nil, isReShare: nil, isNSFW: isNSFWSwitch.isOn, isSpoiler: isSpoilerSwitch.isOn) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let feedMessages):
					DispatchQueue.main.async {
						self.delegate?.updateMessages(with: feedMessages)
					}
				case .failure: break
				}
				self.dismiss(animated: true, completion: nil)
			}
		} else {
			SCLAlertView().showWarning("Character limit reached!", subTitle: "You have exceeded the character limit for a message.")
		}
	}
}

// MARK: - UITextViewDelegate
extension KFeedMessageEditorViewController: UITextViewDelegate {
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
