//
//  MALImportTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/02/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import SCLAlertView
import MobileCoreServices

class MALImportActionTableViewCell: ProductActionTableViewCell {
	// MARK: - Functions
	override func actionButtonPressed(_ sender: UIButton) {
		let types: [String] = [kUTTypeXML as String]
		let documentPicker = UIDocumentPickerViewController(documentTypes: types, in: .import)
		documentPicker.delegate = self.parentViewController as? MALImportTableViewController
		documentPicker.modalPresentationStyle = .formSheet
		self.parentViewController?.present(documentPicker, animated: true, completion: nil)
	}
}

class MALImportTableViewController: KTableViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var rightNavigationBarButton: UIBarButtonItem!

	// MARK: - Properties
	var textFieldArray: [UITextField?] = []
	var selectedFileURL: URL? {
		didSet {
			if selectedFileURL != nil {
				if let lastPathComponent = selectedFileURL?.lastPathComponent {
					textFieldArray.first??.text = ".../" + lastPathComponent
					self.rightNavigationBarButton.isEnabled = true
				}
			}
		}
	}

	let previewImages = [R.image.move_to_kurozora()]

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}
	override var prefersActivityIndicatorHidden: Bool {
		return _prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		// Stop activity indicator as it's not needed for now.
		_prefersActivityIndicatorHidden = true

		rightNavigationBarButton.isEnabled = false
	}

	// MARK: - IBActions
	@IBAction func rightNavigationBarButtonPressed(sender: AnyObject) {
		DispatchQueue.global(qos: .background).async {
			guard let userID = User.current?.id else { return }
			guard let filePath = self.selectedFileURL else { return }

			KService.importMALLibrary(forUserID: userID, filePath: filePath, importBehavior: .overwrite) { _ in
			}
		}

		self.rightNavigationBarButton.isEnabled = false
	}
}

// MARK: - UITableViewDataSource
extension MALImportTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 4
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			guard let productPreviewTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.productPreviewTableViewCell, for: indexPath) else {
				fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.productPreviewTableViewCell.identifier)")
			}
			return productPreviewTableViewCell
		} else if indexPath.section == 1 {
			guard let productHeaderTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.productHeaderTableViewCell, for: indexPath) else {
				fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.productHeaderTableViewCell.identifier)")
			}
			return productHeaderTableViewCell
		} else if indexPath.section == 2 {
			guard let malImportActionTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.malImportActionTableViewCell, for: indexPath) else {
				fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.malImportActionTableViewCell.identifier)")
			}
			return malImportActionTableViewCell
		}

		guard let productInfoTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.productInfoTableViewCell, for: indexPath) else {
			fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.productInfoTableViewCell.identifier)")
		}
		return productInfoTableViewCell
	}
}

// MARK: - UITableViewDelegate
extension MALImportTableViewController {
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if indexPath.section == 0 {
			let productPreviewTableViewCell = cell as? ProductPreviewTableViewCell
			productPreviewTableViewCell?.previewImages = previewImages
		} else if indexPath.section == 2 {
			if let malImportActionTableViewCell = cell as? ProductActionTableViewCell {
				malImportActionTableViewCell.actionTextField.tag = indexPath.row
				malImportActionTableViewCell.actionTextField.delegate = self
				malImportActionTableViewCell.actionTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
				if selectedFileURL != nil {
					if let lastPathComponent = selectedFileURL?.lastPathComponent {
						malImportActionTableViewCell.actionTextField.text = ".../" + lastPathComponent
						self.rightNavigationBarButton.isEnabled = true
					}
				}
				textFieldArray.append(malImportActionTableViewCell.actionTextField)
			}
		}
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.section == 0 {
			let cellRatio: CGFloat = UIDevice.isLandscape ? 1.5 : 3
			return view.frame.height / cellRatio
		}

		return UITableView.automaticDimension
	}

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return CGFloat.leastNormalMagnitude
	}

	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 22
	}
}

// MARK: - UITextFieldDelegate
extension MALImportTableViewController: UITextFieldDelegate {
	@objc func editingChanged(_ textField: UITextField) {
		if textField.text?.count == 1, textField.text?.first == " " {
			textField.text = ""
			return
		}

		var rightNavigationBarButtonIsEnabled = false
		textFieldArray.forEach({
			if let textField = $0?.text, !textField.isEmpty {
				rightNavigationBarButtonIsEnabled = true
				return
			}
			rightNavigationBarButtonIsEnabled = false
		})

		rightNavigationBarButton.isEnabled = rightNavigationBarButtonIsEnabled
	}

	func textFieldDidBeginEditing(_ textField: UITextField) {
		textField.returnKeyType = textField.tag == textFieldArray.count - 1 ? .send : .next
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField.tag == textFieldArray.count - 1 {
			rightNavigationBarButtonPressed(sender: textField)
		} else {
			textFieldArray[textField.tag + 1]?.becomeFirstResponder()
		}

		return true
	}
}

// MARK: - UIDocumentPickerDelegate
extension MALImportTableViewController: UIDocumentPickerDelegate {
	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		selectedFileURL = urls.first
	}
}
