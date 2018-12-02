//
//  RichTextEditorView.swift
//  KRichTextEditor
//
//  Created by Khoren Katklian on 01/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import RichEditorView

class RichTextEditorView: UIViewController {
	@IBOutlet weak var richEditorView: RichEditorView!

	lazy var toolbar: RichEditorToolbar = {
		let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
		toolbar.options = RichEditorDefaultOption.all
		return toolbar
	}()

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

	// MARK: = IBActions
	@IBAction func cancelButton(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
}

extension KRichTextEditor: RichEditorToolbarDelegate {
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
		toolbar.editor?.insertImage("https://img.memecdn.com/if-anyone-can-it-amp-039-s-elon-musk_o_7214081.jpg", alt: "Elon-chan")
	}

	func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar) {
		// Can only add links to selected text, so make sure there is a range selection first
		if toolbar.editor?.hasRangeSelection == true {
			toolbar.editor?.insertLink("https://twitter.com/elonmusk/", title: "Elon Musk Twitter")
		}
	}
}
