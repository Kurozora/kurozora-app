//
//  LibraryImportTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/02/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit
import UniformTypeIdentifiers
import UIKit

class LibraryImportTableViewController: ServiceTableViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var rightNavigationBarButton: UIBarButtonItem!

	// MARK: - Properties
	var textFieldArray: [UITextField?] = []
	var selectedImportService: LibraryImport.Service? {
		didSet {
			self.tableView.reloadData()
		}
	}

	var selectedImpotBehavrior: LibraryImport.Behavior? {
		didSet {
			self.tableView.reloadData()
		}
	}

	var selectedFileURL: URL? {
		didSet {
			self.tableView.reloadData()
		}
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		// Configure properties
		self.previewImage = R.image.promotional.moveToKurozora()
		self.serviceType = .libraryImport

		self.rightNavigationBarButton.isEnabled = false
	}

	// MARK: - Functions
	/// Dismiss the view. Used by the dismiss button when presented modally.
	@objc func dismissButtonPressed() {
		self.dismiss(animated: true, completion: nil)
	}

	// MARK: - IBActions
	@IBAction func rightNavigationBarButtonPressed(sender: AnyObject) {
		guard let filePath = self.selectedFileURL else { return }

		self.rightNavigationBarButton.isEnabled = false

		Task { [weak self] in
			// Make sure you release the security-scoped resource when you finish.
			defer {
				filePath.stopAccessingSecurityScopedResource()
			}

			guard let self = self else { return }

			do {
				_ = try await KService.importToLibrary(.shows, importService: .mal, importBehavior: .overwrite, filePath: filePath).value
			} catch let error as KKAPIError {
				_ = await MainActor.run {
					self.presentAlertController(title: "Can't Import To Library 😔", message: error.message)
				}

				print("----- Library import failed", error.message)
			}
		}
	}
}

// MARK: - UITableViewDataSource
extension LibraryImportTableViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch Section(rawValue: section) {
		case .body:
			return 3
		default:
			return 1
		}
	}

	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [
			ActionButtonTableViewCell.self,
			ServicePreviewTableViewCell.self,
			ServiceHeaderTableViewCell.self,
			ServiceFooterTableViewCell.self,
			SelectTableViewCell.self,
		]
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch Section(rawValue: indexPath.section) {
		case .body:
			switch Row(rawValue: indexPath.row) {
			case .service:
				guard let selectTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.selectTableViewCell, for: indexPath) else {
					fatalError("Cannot dequeue reusable cell with identifier \(R.reuseIdentifier.selectTableViewCell.identifier)")
				}
				selectTableViewCell.configureCell(using: "\(self.selectedImportService?.stringValue ?? Trans.selectService) ▾", buttonTag: indexPath.row)
				selectTableViewCell.delegate = self
				return selectTableViewCell
			case .behavior:
				guard let selectTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.selectTableViewCell, for: indexPath) else {
					fatalError("Cannot dequeue reusable cell with identifier \(R.reuseIdentifier.selectTableViewCell.identifier)")
				}
				selectTableViewCell.configureCell(using: "\(self.selectedImpotBehavrior?.stringValue ?? Trans.selectBehavior) ▾", buttonTag: indexPath.row)
				selectTableViewCell.delegate = self
				return selectTableViewCell
			default:
				guard let actionButtonTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.actionButtonTableViewCell, for: indexPath) else {
					fatalError("Cannot dequeue reusable cell with identifier \(R.reuseIdentifier.actionButtonTableViewCell.identifier)")
				}
				actionButtonTableViewCell.delegate = self
				actionButtonTableViewCell.actionButton.setTitle(Trans.selectFile, for: .normal)
				actionButtonTableViewCell.actionTextField.tag = indexPath.row
				actionButtonTableViewCell.actionTextField.delegate = self
				actionButtonTableViewCell.actionTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
				actionButtonTableViewCell.actionTextField.isEnabled = false

				if let selectedImportService = self.selectedImportService {
					actionButtonTableViewCell.actionTextField.placeholder = "\(selectedImportService.stringValue).xml"
				} else {
					actionButtonTableViewCell.actionTextField.placeholder = Trans.libraryXML
				}

				if self.selectedFileURL != nil {
					if let lastPathComponent = self.selectedFileURL?.lastPathComponent {
						actionButtonTableViewCell.actionTextField.text = ".../" + lastPathComponent
						self.rightNavigationBarButton.isEnabled = true
					}
				}

				self.textFieldArray.append(actionButtonTableViewCell.actionTextField)
				return actionButtonTableViewCell
			}
		default:
			return super.tableView(tableView, cellForRowAt: indexPath)
		}
	}
}

// MARK: - ActionButtonTableViewCellDelegate
extension LibraryImportTableViewController: ActionButtonTableViewCellDelegate {
	func actionButtonTableViewCell(_ cell: ActionButtonTableViewCell, didPressButton actionButton: UIButton) {
		let documentPicker: UIDocumentPickerViewController
		let types: [UTType] = [.xml]
		documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: types)
		documentPicker.delegate = self
		documentPicker.modalPresentationStyle = .formSheet
		self.present(documentPicker, animated: true, completion: nil)
	}
}

// MARK: - UITextFieldDelegate
extension LibraryImportTableViewController: UITextFieldDelegate {
	@objc func editingChanged(_ textField: UITextField) {
		if textField.text?.count == 1, textField.text?.first == " " {
			textField.text = ""
			return
		}

		var rightNavigationBarButtonIsEnabled = false
		for item in self.textFieldArray {
			if let textField = item?.text, !textField.isEmpty {
				rightNavigationBarButtonIsEnabled = true
				continue
			}
			rightNavigationBarButtonIsEnabled = false
		}

		self.rightNavigationBarButton.isEnabled = rightNavigationBarButtonIsEnabled
	}

	func textFieldDidBeginEditing(_ textField: UITextField) {
		textField.returnKeyType = textField.tag == self.textFieldArray.count - 1 ? .send : .next
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField.tag == self.textFieldArray.count - 1 {
			self.rightNavigationBarButtonPressed(sender: textField)
		} else {
			self.textFieldArray[textField.tag + 1]?.becomeFirstResponder()
		}

		return true
	}
}

// MARK: - SelectTableViewCellDelegate
extension LibraryImportTableViewController: SelectTableViewCellDelegate {
	func selectTableViewCell(_ cell: SelectTableViewCell, didPressButton selectButton: UIButton) {
		switch Row(rawValue: selectButton.tag) {
		case .service:
			let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: LibraryImport.Service.alertControllerItems, currentSelection: self.selectedImportService, action: { [weak self] _, value in
				guard let self = self else { return }
				self.selectedImportService = value
			})

			// Present the controller
			if let popoverController = actionSheetAlertController.popoverPresentationController {
				popoverController.sourceView = selectButton
				popoverController.sourceRect = selectButton.bounds
			}

			if (self.navigationController?.visibleViewController as? UIAlertController) == nil {
				self.present(actionSheetAlertController, animated: true, completion: nil)
			}
		case .behavior:
			let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: LibraryImport.Behavior.alertControllerItems, currentSelection: self.selectedImpotBehavrior, action: { [weak self] _, value in
				guard let self = self else { return }
				self.selectedImpotBehavrior = value
			})

			// Present the controller
			if let popoverController = actionSheetAlertController.popoverPresentationController {
				popoverController.sourceView = selectButton
				popoverController.sourceRect = selectButton.bounds
			}

			if (self.navigationController?.visibleViewController as? UIAlertController) == nil {
				self.present(actionSheetAlertController, animated: true, completion: nil)
			}
		default:
			break
		}
	}
}

// MARK: - UIDocumentPickerDelegate
extension LibraryImportTableViewController: UIDocumentPickerDelegate {
	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		guard let url = urls.first else { return }

		// Start accessing a security-scoped resource.
		guard url.startAccessingSecurityScopedResource() else {
			// Handle the failure here.
			return
		}

		self.selectedFileURL = url
	}
}

extension LibraryImportTableViewController {
	enum Row: Int, CaseIterable {
		case service
		case behavior
		case file
	}
}
