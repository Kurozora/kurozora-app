//
//  ServiceTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/05/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/// A view controller that specializes in managing a service view.
///
/// Subclass `ServiceTableViewController` when your interface consists of a table that provides a service.
/// Table view controllers already adopt the protocols you need to manage your table view's content and respond to changes.
/// In addition, `ServiceTableViewController` implements the following behaviors:
/// - Disables refresh control.
/// - Disables activity indicator.
/// - Registers an instance of [ServicePreviewTableViewCell](x-source-tag://ServicePreviewTableViewCell)
/// - Registers an instance of [ServiceHeaderTableViewCell](x-source-tag://ServiceHeaderTableViewCell)
/// - Registers an instance of [ServiceFooterTableViewCell](x-source-tag://ServiceFooterTableViewCell)
///
/// - Tag: ServiceTableViewController
class ServiceTableViewController: KTableViewController {
	/// The preview image shown at the top of the table view.
	var previewImage: UIImage?

	/// The service type used to populate the table view cells.
	var serviceType: ServiceType?

	// Refresh control
	var _prefersRefreshControlDisabled = false {
		didSet {
			self.setNeedsRefreshControlAppearanceUpdate()
		}
	}
	override var prefersRefreshControlDisabled: Bool {
		return self._prefersRefreshControlDisabled
	}

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}
	override var prefersActivityIndicatorHidden: Bool {
		return self._prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		// Stop activity indicator and disable refresh control
		self._prefersActivityIndicatorHidden = true
		self._prefersRefreshControlDisabled = true
	}
}

// MARK: - UITableViewDataSource
extension ServiceTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return Section.allCases.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}

	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [
			ServicePreviewTableViewCell.self,
			ServiceHeaderTableViewCell.self,
			ServiceFooterTableViewCell.self
		]
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch Section(rawValue: indexPath.section) {
		case .preview:
			guard let servicePreviewTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.servicePreviewTableViewCell, for: indexPath) else {
				fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.servicePreviewTableViewCell.identifier)")
			}
			servicePreviewTableViewCell.previewImage = previewImage
			return servicePreviewTableViewCell
		case .header:
			guard let serviceHeaderTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.serviceHeaderTableViewCell, for: indexPath) else {
				fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.serviceHeaderTableViewCell.identifier)")
			}
			serviceHeaderTableViewCell.serviceType = serviceType
			return serviceHeaderTableViewCell
		default:
			guard let serviceFooterTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.serviceFooterTableViewCell, for: indexPath) else {
				fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.serviceFooterTableViewCell.identifier)")
			}
			serviceFooterTableViewCell.delegate = self
			serviceFooterTableViewCell.serviceType = serviceType
			return serviceFooterTableViewCell
		}
	}
}

// MARK: - UITableViewDelegate
extension ServiceTableViewController {
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return CGFloat.leastNormalMagnitude
	}

	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		switch Section(rawValue: section) {
		case .preview:
			return .leastNormalMagnitude
		default:
			return 28
		}
	}
}

// MARK: - ServiceFooterTableViewCellDelegate
extension ServiceTableViewController: ServiceFooterTableViewCellDelegate {
	func serviceFooterTableViewCell(_ cell: ServiceFooterTableViewCell, didPressButton button: UIButton) {
		if let legalKNavigationViewController = R.storyboard.legal.instantiateInitialViewController() {
			self.present(legalKNavigationViewController, animated: true)
		}
	}
}

extension ServiceTableViewController {
	/// The set of available [ServiceTableViewController](x-source-tag://ServiceTableViewController) sections.
	enum Section: Int, CaseIterable {
		/// The preview section of the table view.
		case preview

		/// The heder section of the table view.
		case header

		/// The body section of the table view.
		case body

		/// The heder section of the table view.
		case footer
	}
}
