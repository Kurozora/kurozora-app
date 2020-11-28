//
//  KRichTextEditorViewController.swift
//  KRichTextEditor
//
//  Created by Khoren Katklian on 01/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
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
		guard let title = titleTextField.text?.trimmed, !title.isEmpty else {
			self.presentAlertController(title: "Missing Title", message: "The title of the thread can't be left is empty.")
			return
		}
		guard let content = richTextView.text, !(content == self.placeholderText && richTextView.textColor == KThemePicker.textFieldPlaceholderTextColor.colorValue), !content.isEmpty else {
			self.presentAlertController(title: "Missing Content", message: "The content of the thread can't be left empty.")
			return
		}

		self.view.endEditing(true)
		KService.postThread(inSection: sectionID, withTitle: title, content: content) {[weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let forumsThreads):
				self.delegate?.updateThreadsList(with: forumsThreads)
				self.dismiss(animated: true, completion: nil)
			case .failure: break
			}
		}
	}
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
