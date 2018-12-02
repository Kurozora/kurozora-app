//
//  RichTextEditorView.swift
//  KRichTextEditor
//
//  Created by Khoren Katklian on 01/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import RichEditorView
import SCLAlertView

class RichTextEditorView: UIViewController, RichEditorDelegate, RichEditorToolbarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	@IBOutlet weak var richEditorView: RichEditorView!

	lazy var toolbar: RichEditorToolbar = {
		let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
		toolbar.options = RichEditorDefaultOption.all
		return toolbar
	}()

	var imagePicker = UIImagePickerController()

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		richEditorView.delegate = self
		richEditorView.inputAccessoryView = toolbar
		richEditorView.placeholder = "What's on your mind?"

		toolbar.delegate = self
		toolbar.editor = richEditorView
	}

	// MARK: - IBActions
	@IBAction func cancelButton(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}

	// MARK: - RichTextEditorToolbarDelegate
	fileprivate func randomColor() -> UIColor {
		let colors: [UIColor] = [
			.red,
			.orange,
			.yellow,
			.green,
			.blue,
			.purple
		]

		let color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
		return color
	}

	func richEditorToolbarChangeTextColor(_ toolbar: RichEditorToolbar) {
		let color = randomColor()
		toolbar.editor?.setTextColor(color)
	}

	func richEditorToolbarChangeBackgroundColor(_ toolbar: RichEditorToolbar) {
		let color = randomColor()
		toolbar.editor?.setTextBackgroundColor(color)
	}

	func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar) {
		imagePicker.sourceType = .photoLibrary
		imagePicker.allowsEditing = true
		imagePicker.delegate = self

		self.present(imagePicker, animated: true, completion: nil)
	}

	func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar) {
		// Can only add links to selected text, so make sure there is a range selection first

		if toolbar.editor?.hasRangeSelection == true {
			let alertView = SCLAlertView()
			let linkTextField = alertView.addTextField("https://")

			alertView.addButton("Link") {
				if let linkText = linkTextField.text, linkText != "" {
					toolbar.editor?.insertLink(linkText, title: "")
				}
			}

			alertView.showInfo("Add a link", closeButtonTitle: "Cancel")
		} else {
			SCLAlertView().showWarning("Please select a text first!")
		}
	}

	// MARK: - UIImagePickerControllerDelegate Methods
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		//obtaining saving path
//		let fileManager = FileManager.default
//		let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
//		let imagePath = documentsPath?.appendingPathComponent("image.jpg")

		// extract image from the picker and save it
		if let pickedImage = info[UIImagePickerController.InfoKey.referenceURL] as? URL {
			NSLog("\(pickedImage)")
			toolbar.editor?.insertImage(pickedImage.absoluteString, alt: "")
		}

		picker.dismiss(animated: true, completion: nil)
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}
}
