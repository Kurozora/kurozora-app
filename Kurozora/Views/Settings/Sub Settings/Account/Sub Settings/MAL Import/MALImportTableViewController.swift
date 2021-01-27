//
//  MALImportTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/02/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class MALImportTableViewController: ServiceTableViewController {
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

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		// Confgure properties
		self.previewImage = R.image.promotional.moveToKurozora()
		self.serviceType = .malImport

		rightNavigationBarButton.isEnabled = false
	}

	// MARK: - IBActions
	@IBAction func rightNavigationBarButtonPressed(sender: AnyObject) {
		DispatchQueue.global(qos: .background).async {
			guard let filePath = self.selectedFileURL else { return }

			KService.importMALLibrary(filePath: filePath, importBehavior: .overwrite) { _ in
			}
		}

		self.rightNavigationBarButton.isEnabled = false
	}
}

// MARK: - UITableViewDataSource
extension MALImportTableViewController {
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch Section(rawValue: indexPath.section) {
		case .body:
			guard let malImportActionTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.malImportActionTableViewCell, for: indexPath) else {
				fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.malImportActionTableViewCell.identifier)")
			}
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
			return malImportActionTableViewCell
		default:
			return super.tableView(tableView, cellForRowAt: indexPath)
		}
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
