//
//  KRichTextEditorViewController.swift
//  KRichTextEditor
//
//  Created by Khoren Katklian on 01/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
//import ColorSlider
//import RichEditorView
//import SCLAlertView
//import SwiftyJSON
//import SwiftTheme

//protocol KRichTextEditorViewDelegate: class {
//	func updateThreadsList(with thread: ForumsThreadElement)
//	func updateFeedPosts(with thread: FeedPostsElement)
//}

//class KRichTextEditorViewController: UIViewController, RichEditorDelegate, RichEditorToolbarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIWebViewDelegate {
//	@IBOutlet weak var richEditorView: RichEditorView?
//	@IBOutlet weak var titleTextField: UITextField! {
//		didSet {
//			titleTextField.theme_textColor = KThemePicker.textFieldTextColor.rawValue
//			titleTextField.theme_backgroundColor = KThemePicker.textFieldBackgroundColor.rawValue
//			titleTextField.theme_placeholderAttributes = ThemeStringAttributesPicker(keyPath: KThemePicker.textFieldPlaceholderTextColor.stringValue) { value -> [NSAttributedString.Key: Any]? in
//				guard let rgba = value as? String else { return nil }
//				let color = UIColor(rgba: rgba)
//				let titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]
//
//				return titleTextAttributes
//			}
//		}
//	}
//
//	enum TextElement: String {
//		case fontColor = "fontColor"
//		case backgroundColor = "backgroundColor"
//	}
//
//	lazy var toolbar: RichEditorToolbar = {
//		let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
//		toolbar.options = RichEditorDefaultOption.all
//		return toolbar
//	}()
//	var imagePicker = UIImagePickerController()
//	var sectionID: Int?
//	var textElement: String?
//	var colorSlider: ColorSlider!
//	weak var delegate: KRichTextEditorViewDelegate?
//
//	override func viewWillAppear(_ animated: Bool) {
//		super.viewWillAppear(animated)
//	}
//
//	override func viewDidLoad() {
//		super.viewDidLoad()
//		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
//
//		richEditorView?.delegate = self
//		richEditorView?.inputAccessoryView = toolbar
//		richEditorView?.placeholder = "What's on your mind?"
//		richEditorView?.setEditorFontColor(KThemePicker.textColor.colorValue)
//		richEditorView?.theme_tintColor = KThemePicker.tintColor.rawValue
//		richEditorView?.setEditorBackgroundColor(KThemePicker.tableViewCellBackgroundColor.colorValue)
//
//		toolbar.delegate = self
//		toolbar.editor = richEditorView
//		toolbar.editor?.theme_tintColor = KThemePicker.tintColor.rawValue
//	}
//
//	// MARK: - Functions
//	func initColorSlider(_ bool: Bool) {
//		if colorSlider == nil, bool {
//			// Setup ColorSlider
//			colorSlider = ColorSlider(orientation: .vertical, previewSide: .left)
//
//			// Observe ColorSlider events
//			colorSlider.addTarget(self, action: #selector(changedColor(_:)), for: .valueChanged)
//			view.addSubview(colorSlider)
//
//			colorSlider.translatesAutoresizingMaskIntoConstraints = false
//			NSLayoutConstraint.activate([
//				colorSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//				colorSlider.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//				colorSlider.widthAnchor.constraint(equalToConstant: 16),
//				colorSlider.heightAnchor.constraint(equalToConstant: 200),
//			])
//		} else if colorSlider != nil, !bool {
//			colorSlider.removeTarget(self, action: #selector(changedColor(_:)), for: .valueChanged)
//			colorSlider.removeFromSuperview()
//			colorSlider = nil
//		}
//	}
//
//	// MARK: - IBActions
//	@IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
//		dismiss(animated: true, completion: nil)
//	}
//
//	@IBAction func postButtonPressed(_ sender: UIBarButtonItem) {
//		guard let sectionID = sectionID else { return }
//		guard let title = titleTextField.text?.trimmed else { return }
//		guard let content = richEditorView?.contentHTML else { return }
//
//		Service.shared.postThread(inSection: sectionID, withTitle: title, content: content, withSuccess: { (threadID) in
//			DispatchQueue.main.async {
//				let creationDate = Date().string(withFormat: "yyyy-MM-dd HH:mm:ss")
//				let content = self.richEditorView?.text
//				let forumThreadJSON: JSON = [
//					"id": threadID,
//					"title": self.titleTextField.text!,
//					"content": content!,
//					"locked": false,
//					"poster_user_id": User.currentID!,
//					"poster_username": User.username!,
//					"creation_date": creationDate,
//					"reply_count": 0,
//					"score": 0
//					]
//				if let forumThreadsElement = try? ForumThreadsElement(json: forumThreadJSON) {
//					self.delegate?.updateThreadsList(with: forumThreadsElement)
//				}
//			}
//			self.dismiss(animated: true, completion: nil)
//		})
//	}
//
//	// Observe ColorSlider .valueChanged events.
//	@objc func changedColor(_ slider: ColorSlider) {
//		if textElement  == "fontColor" {
//			toolbar.editor?.setTextColor(slider.color)
//		} else if textElement == "backgroundColor" {
//			toolbar.editor?.setTextBackgroundColor(slider.color)
//		}
//	}
//
//	// MARK: - RichTextEditorToolbarDelegate
//	func richEditorToolbarChangeTextColor(_ toolbar: RichEditorToolbar) {
//		if toolbar.editor?.hasRangeSelection == true {
//			textElement = "fontColor"
//			initColorSlider(true)
//		} else {
//			initColorSlider(false)
//		}
//	}
//
//	func richEditorToolbarChangeBackgroundColor(_ toolbar: RichEditorToolbar) {
//		if toolbar.editor?.hasRangeSelection == true {
//			textElement = "backgroundColor"
//			initColorSlider(true)
//		} else {
//			initColorSlider(false)
//		}
//	}
//
//	func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar) {
//		imagePicker.sourceType = .photoLibrary
//		imagePicker.allowsEditing = true
//		imagePicker.delegate = self
//
//		self.present(imagePicker, animated: true, completion: nil)
//	}
//
//	func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar) {
//		// Can only add links to selected text, so make sure there is a range selection first
//
//		if toolbar.editor?.hasRangeSelection == true {
//			let alertView = SCLAlertView()
//			let linkTextField = alertView.addTextField("https://")
//
//			alertView.addButton("Link") {
//				if let linkText = linkTextField.text, !linkText.isEmpty {
//					toolbar.editor?.insertLink(linkText, title: "")
//				}
//			}
//
//			alertView.showInfo("Add a link", closeButtonTitle: "Cancel")
//		} else {
//			SCLAlertView().showWarning("Please select a text first!")
//		}
//	}
//
//	// MARK: - UIImagePickerControllerDelegate Methods
//	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//		// extract image from the picker and save it
//		if let pickedImage: UIImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//			if let pickedImageBase64 = pickedImage.toBase64(format: .jpeg(0.1)), !pickedImageBase64.isEmpty {
//				toolbar.editor?.insertImage("data:image/jpg;base64,\(pickedImageBase64)", alt: "")
//			}
//		}
//
//		picker.dismiss(animated: true, completion: nil)
//	}
//
//	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//		picker.dismiss(animated: true, completion: nil)
//	}
//
//	func webViewDidFinishLoad(_ webView: UIWebView) {
//		print("Loaded")
//	}
//}

class KRichTextEditorViewController: UIViewController {

}
