//
//  RequestRefundTableViewController+KTableViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

// MARK: - Data Source
class RequestRefundDataSource: UITableViewDiffableDataSource<RequestRefundTableViewController.SectionLayoutKind, RequestRefundTableViewController.ItemKind> {
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return self.sectionIdentifier(for: section)?.title
	}
}

extension RequestRefundTableViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return super.registerCells(for: tableView) + [
			IconTableViewCell.self
		]
	}

	func configureDataSource() {
		let headerCellRegistration = self.getConfiguredHeaderCell()
		let iconCellRegistration = self.getConfiguredIconCell()

		self.dataSource = RequestRefundDataSource(tableView: self.tableView) { (tableView: UITableView, indexPath: IndexPath, itemKind: ItemKind) -> UITableViewCell? in
			switch itemKind {
			case .header:
				return tableView.dequeueConfiguredReusableCell(using: headerCellRegistration, for: indexPath, item: itemKind)
			case .transaction:
				return tableView.dequeueConfiguredReusableCell(using: iconCellRegistration, for: indexPath, item: itemKind)
			}
		}
		self.dataSource.defaultRowAnimation = .fade
	}

	func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		if self.hasSettingsHeader {
			self.snapshot.appendSections([.header])
			self.snapshot.appendItems([.header], toSection: .header)
		}

		for section in [SectionLayoutKind.purchased, .refunded] {
			let sectionTransactions = self.transactions(in: section)
			guard !sectionTransactions.isEmpty else { continue }

			self.snapshot.appendSections([section])
			self.snapshot.appendItems(sectionTransactions.map { .transaction($0) }, toSection: section)
		}

		self.dataSource.apply(self.snapshot)
	}

	private func getConfiguredHeaderCell() -> UITableView.CellRegistration<SettingsHeaderCell, ItemKind> {
		return UITableView.CellRegistration<SettingsHeaderCell, ItemKind>(cellNib: SettingsHeaderCell.nib) { [weak self] cell, _, _ in
			guard let self = self else { return }
			cell.configure(image: self.headerImage, title: self.headerTitle ?? "", description: self.headerDescription ?? "")
		}
	}

	private func getConfiguredIconCell() -> UITableView.CellRegistration<IconTableViewCell, ItemKind> {
		return UITableView.CellRegistration<IconTableViewCell, ItemKind>(cellNib: IconTableViewCell.nib) { cell, _, itemKind in
			switch itemKind {
			case .header:
				break
			case .transaction(let transaction):
				let product = Store.shared.findProduct(byID: transaction.attributes.productID)
				cell.configureCell(using: transaction, product: product)
			}
		}
	}
}
