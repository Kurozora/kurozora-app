//
//  KRichTextEditorViewController.swift
//  KRichTextEditor
//
//  Created by Khoren Katklian on 01/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SCLAlertView
import SwiftyJSON
import SwiftTheme
import RichTextView

protocol KRichTextEditorViewDelegate: class {
	func updateThreadsList(with thread: ForumsThreadElement)
//	func updateFeedPosts(with thread: FeedPostsElement)
}

class KRichTextEditorViewController: UIViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var titleTextField: UITextField! {
		didSet {
			titleTextField.theme_textColor = KThemePicker.textFieldTextColor.rawValue
			titleTextField.theme_backgroundColor = KThemePicker.textFieldBackgroundColor.rawValue
			titleTextField.theme_placeholderAttributes = ThemeStringAttributesPicker(keyPath: KThemePicker.textFieldPlaceholderTextColor.stringValue) { value -> [NSAttributedString.Key: Any]? in
				guard let rgba = value as? String else { return nil }
				let color = UIColor(rgba: rgba)
				let titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]

				return titleTextAttributes
			}
		}
	}
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
	var imagePicker = UIImagePickerController()
	var sectionID: Int?
	var textElement: String?
	var richTextView: RichTextView!
	weak var delegate: KRichTextEditorViewDelegate?
	var placeholderText = "What's on your mind?"

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		richTextView = RichTextView(input: placeholderText, textColor: KThemePicker.textColor.colorValue, isSelectable: true, isEditable: true, interactiveTextColor: KThemePicker.tintColor.colorValue, textViewDelegate: self, frame: .zero, completion: nil)
		richTextViewBubbleView.addSubview(richTextView)
		applyRichTextViewConstraints()

		let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 48))
		toolbar.items = toolbarItems
		richTextView.textView?.inputAccessoryView = toolbar
	}

	// MARK: - Functions
	/**
		Instantiates and returns a view controller from the relevant storyboard.

		- Returns: a view controller from the relevant storyboard.
	*/
	static func instantiateFromStoryboard() -> UIViewController? {
		let editorStoryboard = UIStoryboard(name: "editor", bundle: nil)
		return editorStoryboard.instantiateViewController(withIdentifier: "KRichTextEditorViewController")
	}

	func applyRichTextViewConstraints() {
		richTextView.translatesAutoresizingMaskIntoConstraints = false

		let left = richTextView.leftAnchor.constraint(equalTo: richTextViewBubbleView.leftAnchor, constant: 8)
		let right = richTextView.rightAnchor.constraint(equalTo: richTextViewBubbleView.rightAnchor, constant: -8)
		let top = richTextView.topAnchor.constraint(equalTo: richTextViewBubbleView.topAnchor, constant: 8)
		let bottom = richTextView.bottomAnchor.constraint(equalTo: richTextViewBubbleView.bottomAnchor, constant: -8)
		NSLayoutConstraint.activate([left, right, top, bottom])
	}

	// MARK: - IBActions
	@IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
		dismiss(animated: true, completion: nil)
	}

	@IBAction func postButtonPressed(_ sender: UIBarButtonItem) {
		guard let sectionID = sectionID else { return }
		guard let title = titleTextField.text?.trimmed else { return }
		guard let content = richTextView.textView?.text else { return }
		print("Input: \(content)")

		KService.shared.postThread(inSection: sectionID, withTitle: title, content: content, withSuccess: { (threadID) in
			DispatchQueue.main.async {
				let creationDate = Date().string(withFormat: "yyyy-MM-dd HH:mm:ss")
				let forumThreadJSON: JSON = [
					"id": threadID,
					"title": title,
					"content": content,
					"locked": false,
					"poster_user_id": User.currentID,
					"poster_username": User.username,
					"creation_date": creationDate,
					"reply_count": 0,
					"score": 0
					]
				if let forumThreadsElement = try? ForumsThreadElement(json: forumThreadJSON) {
					self.delegate?.updateThreadsList(with: forumThreadsElement)
				}
			}
			self.dismiss(animated: true, completion: nil)
		})
	}

	@IBAction func insertImageButtonPressed(_ sender: UIBarButtonItem) {
		imagePicker.sourceType = .photoLibrary
		imagePicker.allowsEditing = true
		imagePicker.delegate = self

		self.present(imagePicker, animated: true, completion: nil)
	}

	@IBAction func insertYouTubeButtonPressed(_ sender: UIBarButtonItem) {
		let alertView = SCLAlertView()
		let textField = alertView.addTextField("9R8LzNUW4s4")
		alertView.addButton("Done") {
			if let youtubeID = textField.text, !youtubeID.isEmpty {
				self.richTextView.textView?.insertText("youtube[\(youtubeID)]")
			}
			alertView.dismiss(animated: true, completion: nil)
		}
		alertView.showInfo("Add a YouTube video", closeButtonTitle: "Cancel")
		textField.becomeFirstResponder()
	}

	@IBAction func insertLinkButtonPressed(_ sender: UIBarButtonItem) {
		if let selectedRange = richTextView.textView?.selectedTextRange, !selectedRange.isEmpty {
			let alertView = SCLAlertView()
			let textField = alertView.addTextField("https://")
			alertView.addButton("Done") {
				if let linkText = textField.text, !linkText.isEmpty {
					let selectedText = self.richTextView.textView?.text(in: selectedRange) ?? ""
					self.richTextView.textView?.insertText("[\(selectedText))](\(linkText))")
				}
			}
			alertView.showInfo("Add a link", closeButtonTitle: "Cancel")
			textField.becomeFirstResponder()
		} else {
			SCLAlertView().showWarning("Please select a text first!")
		}
	}

	@IBAction func insertMentionButtonPressed(_ sender: UIBarButtonItem) {
		let alertView = SCLAlertView()
		let textField = alertView.addTextField("Enter username")
		alertView.addButton("Done") {
			if let username = textField.text, !username.isEmpty {
				self.richTextView.textView?.insertText("[interactive-element id=<2>]@\(username)[/interactive-element]")
			}
			alertView.dismiss(animated: true, completion: nil)
		}
		alertView.showInfo("Mention a user", subTitle: "Enter the username of the user you want to mention.", closeButtonTitle: "Cancel")
		textField.becomeFirstResponder()
	}
}

// MARK: - UITextViewDelegate
extension KRichTextEditorViewController: UITextViewDelegate {
	func textViewDidBeginEditing(_ textView: UITextView) {
		if textView.text == placeholderText {
			textView.text = ""
		}
	}

	func textViewDidEndEditing(_ textView: UITextView) {
		if textView.text.isEmpty {
			textView.text = placeholderText
		}
	}
}

// MARK: - UIImagePickerControllerDelegate
extension KRichTextEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		if let pickedImage: UIImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
			if let pickedImageBase64 = pickedImage.toBase64(format: .jpeg(0.1)), !pickedImageBase64.isEmpty {
				self.richTextView.textView?.insertText("![alt text](data:image/jpg;base64,\(pickedImageBase64))")
			}
		}

		picker.dismiss(animated: true, completion: nil)
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}
}

// MARK: - RichTextEditorDelegate
extension KRichTextEditorViewController: RichTextViewDelegate {
	func didTapCustomLink(withID linkID: String) {
		DispatchQueue.main.async {

		}
	}
}
