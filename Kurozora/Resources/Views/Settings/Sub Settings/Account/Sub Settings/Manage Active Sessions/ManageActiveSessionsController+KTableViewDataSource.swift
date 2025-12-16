//
//  ManageActiveSessionsController+KTableViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/07/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension ManageActiveSessionsController {
	override func registerNibs(for tableView: UITableView) -> [UITableViewHeaderFooterView.Type] {
		return [TitleHeaderTableReusableView.self]
	}

	func configureDataSource() {
		let currentSessionCellRegistration = self.getConfiguredCurrentSessionCell()
		let sessionLockupCellRegistration = self.getConfiguredSessionLockupCell()

		self.dataSource = UITableViewDiffableDataSource<SectionLayoutKind, ItemKind>(tableView: self.tableView) { (tableView: UITableView, indexPath: IndexPath, itemKind: ItemKind) -> UITableViewCell? in
			switch itemKind {
			case .accessToken:
				return tableView.dequeueConfiguredReusableCell(using: currentSessionCellRegistration, for: indexPath, item: itemKind)
			case .sessionIdentity:
				return tableView.dequeueConfiguredReusableCell(using: sessionLockupCellRegistration, for: indexPath, item: itemKind)
			}
		}
		self.dataSource.defaultRowAnimation = .top
	}

	func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		if let accessToken = User.current?.relationships?.accessTokens?.data.first {
			self.snapshot.appendSections([.current])
			self.snapshot.appendItems([.accessToken(accessToken)], toSection: .current)
		}

		if !self.sessionIdentities.isEmpty {
			let sessionIdentityItemKinds: [ItemKind] = self.sessionIdentities.map { sessionIdentity in
				.sessionIdentity(sessionIdentity)
			}

			self.snapshot.appendSections([.other])
			self.snapshot.appendItems(sessionIdentityItemKinds, toSection: .other)
		}

		self.dataSource.apply(self.snapshot)
	}
}
