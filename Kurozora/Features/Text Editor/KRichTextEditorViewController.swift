//
//  KRichTextEditorViewController.swift
//  KRichTextEditor
//
//  Created by Khoren Katklian on 01/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import SCLAlertView
import SwiftyJSON

protocol KRichTextEditorViewDelegate: class {
	func updateThreadsList(with forumsThreads: [ForumsThread])
}

class KRichTextEditorViewController: KViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var titleTextField: KTextField!
	@IBOutlet var richTextView: KTextView!
	@IBOutlet var titleTextFieldBubbleView: UIView! {
		didSet {
			titleTextFieldBubbleView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}
	}
	@IBOutlet var richTextViewBubbleView: UIView! {
		didSet {
			richTextViewBubbleView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}
	}

	// MARK: - Properties
	var sectionID: Int?
	var textElement: String?
	weak var delegate: KRichTextEditorViewDelegate?
	var placeholderText = "What's on your mind?"

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		richTextView.text = placeholderText
		richTextView.theme_textColor = KThemePicker.textFieldPlaceholderTextColor.rawValue
	}

	// MARK: - IBActions
	@IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
		dismiss(animated: true, completion: nil)
	}

	@IBAction func postButtonPressed(_ sender: UIBarButtonItem) {
		guard let sectionID = sectionID else { return }
		guard let title = titleTextField.text?.trimmed else {
			SCLAlertView().showWarning("Thread's title is empty!")
			return
		}
		guard let content = richTextView.text else {
			SCLAlertView().showWarning("Thread's content is empty!")
			return
		}
		print("Input: \(content)")

		KService.postThread(inSection: sectionID, withTitle: title, content: content) {[weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let forumsThreads):
				DispatchQueue.main.async {
					self.delegate?.updateThreadsList(with: forumsThreads)
				}
				self.dismiss(animated: true, completion: nil)
			case .failure: break
			}
		}
	}

//	@IBAction func insertYouTubeButtonPressed(_ sender: UIBarButtonItem) {
//		let alertView = SCLAlertView()
//		let textField = alertView.addTextField("9R8LzNUW4s4")
//		alertView.addButton("Done") {
//			if let youtubeID = textField.text, !youtubeID.isEmpty {
//				self.richTextView.insertText("youtube[\(youtubeID)]")
//			}
//			alertView.dismiss(animated: true, completion: nil)
//		}
//		alertView.showInfo("Add a YouTube video", closeButtonTitle: "Cancel")
//		textField.becomeFirstResponder()
//	}
//
//	@IBAction func insertLinkButtonPressed(_ sender: UIBarButtonItem) {
//		if let selectedRange = richTextView.selectedTextRange, !selectedRange.isEmpty {
//			let alertView = SCLAlertView()
//			let textField = alertView.addTextField("https://")
//			alertView.addButton("Done") {
//				if let linkText = textField.text, !linkText.isEmpty {
//					let selectedText = self.richTextView.text(in: selectedRange) ?? ""
//					self.richTextView.insertText("[\(selectedText))](\(linkText))")
//				}
//			}
//			alertView.showInfo("Add a link", closeButtonTitle: "Cancel")
//			textField.becomeFirstResponder()
//		} else {
//			SCLAlertView().showWarning("Please select a text first!")
//		}
//	}
//
//	@IBAction func insertMentionButtonPressed(_ sender: UIBarButtonItem) {
//		let alertView = SCLAlertView()
//		let textField = alertView.addTextField("Enter username")
//		alertView.addButton("Done") {
//			if let username = textField.text, !username.isEmpty {
//				self.richTextView.insertText("@\(username)")
//			}
//			alertView.dismiss(animated: true, completion: nil)
//		}
//		alertView.showInfo("Mention a user", subTitle: "Enter the username of the user you want to mention.", closeButtonTitle: "Cancel")
//		textField.becomeFirstResponder()
//	}
//
//	@IBAction func insertTagButtonPressed(_ sender: UIBarButtonItem) {
//		let alertView = SCLAlertView()
//		let textField = alertView.addTextField("Enter username")
//		alertView.addButton("Done") {
//			if let username = textField.text, !username.isEmpty {
//				self.richTextView.insertText("@\(username)")
//			}
//			alertView.dismiss(animated: true, completion: nil)
//		}
//		alertView.showInfo("Mention a user", subTitle: "Enter the username of the user you want to mention.", closeButtonTitle: "Cancel")
//		textField.becomeFirstResponder()
//	}
}

// MARK: - UITextViewDelegate
extension KRichTextEditorViewController: UITextViewDelegate {
	func textViewDidBeginEditing(_ textView: UITextView) {
		if textView.text == placeholderText && textView.textColor == KThemePicker.textFieldPlaceholderTextColor.colorValue {
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
