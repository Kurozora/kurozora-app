//
//  LibraryDeleteTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/10/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class LibraryDeleteTableViewController: ServiceTableViewController {
	// MARK: - Views
	private var rightNavigationBarButton: UIBarButtonItem!

	// MARK: - Initializers
	init() {
		super.init(style: .grouped)
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	// MARK: - Properties
	var selectedLibraryKind: KKLibrary.Kind? {
		didSet {
			self.tableView.reloadData()
		}
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = "Delete Library"

		self.configureNavigationItems()

		// Confgure properties
		self.previewImage = .Promotional.deleteLibrary
		self.serviceType = .libraryDelete

		self.rightNavigationBarButton.isEnabled = false
	}

	// MARK: - Functions
	/// Configures the navigation items.
	private func configureNavigationItems() {
		let rightNavigationBarButton = UIBarButtonItem(
			title: "Delete",
			style: .plain,
			target: self,
			action: #selector(rightNavigationBarButtonPressed(sender:))
		)
		rightNavigationBarButton.tintColor = UIColor(red: 1, green: 0.3019607843, blue: 0.262745098, alpha: 1)
		self.rightNavigationBarButton = rightNavigationBarButton
		self.navigationItem.rightBarButtonItem = rightNavigationBarButton
	}

	/// Dismiss the view. Used by the dismiss button when presented modally.
	@objc func dismissButtonPressed() {
		self.dismiss(animated: true, completion: nil)
	}

	// MARK: - IBActions
	@IBAction func rightNavigationBarButtonPressed(sender: AnyObject) {
		guard let selectedLibraryKind = self.selectedLibraryKind else { return }

		let alertController = self.presentAlertController(
			title: Trans.libraryDeleteHeadline,
			message: Trans.libraryDeleteFooter,
			defaultActionButtonTitle: Trans.cancel
		)

		alertController.addTextField { textField in
			textField.textType = .password
			textField.placeholder = Trans.password
		}

		alertController.addAction(UIAlertAction(title: Trans.deletePermanently, style: .destructive) { [weak self] _ in
			guard let self = self else { return }
			guard let passwordTextField = alertController.textFields?.first else { return }
			guard let password = passwordTextField.text else { return }

			self.rightNavigationBarButton.isEnabled = false

			Task {
				do {
					_ = try await KService.clearLibrary(selectedLibraryKind, password: password).value
				} catch let error as KKAPIError {
					await MainActor.run {
						self.presentAlertController(title: Trans.cantDeleteLibrary, message: error.message)
						self.rightNavigationBarButton.isEnabled = false
					}

					print("----- Library delete failed", error.message)
				}
			}
		})
	}
}

// MARK: - UITableViewDataSource
extension LibraryDeleteTableViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch Section(rawValue: section) {
		case .body:
			return Row.allCases.count
		default:
			return 1
		}
	}

	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [
			ServicePreviewTableViewCell.self,
			ServiceHeaderTableViewCell.self,
			ServiceFooterTableViewCell.self,
			SelectTableViewCell.self
		]
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch Section(rawValue: indexPath.section) {
		case .body:
			switch Row(rawValue: indexPath.row) {
			case .library:
				guard let selectTableViewCell = tableView.dequeueReusableCell(withIdentifier: SelectTableViewCell.self, for: indexPath) else {
					fatalError("Cannot dequeue reusable cell with identifier \(SelectTableViewCell.reuseID)")
				}
				selectTableViewCell.configureCell(using: "\(self.selectedLibraryKind?.stringValue ?? "Select library") ▾", buttonTag: indexPath.row)
				selectTableViewCell.delegate = self
				return selectTableViewCell
			default:
				return super.tableView(tableView, cellForRowAt: indexPath)
			}
		default:
			return super.tableView(tableView, cellForRowAt: indexPath)
		}
	}
}

// MARK: - SelectTableViewCellDelegate
extension LibraryDeleteTableViewController: SelectTableViewCellDelegate {
	func selectTableViewCell(_ cell: SelectTableViewCell, didPressButton selectButton: UIButton) {
		switch Row(rawValue: selectButton.tag) {
		case .library:
			let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: KKLibrary.Kind.alertControllerItems, currentSelection: self.selectedLibraryKind, action: { [weak self] _, value in
				guard let self = self else { return }
				self.selectedLibraryKind = value
				self.rightNavigationBarButton.isEnabled = true
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

extension LibraryDeleteTableViewController {
	enum Row: Int, CaseIterable {
		case library
	}
}
