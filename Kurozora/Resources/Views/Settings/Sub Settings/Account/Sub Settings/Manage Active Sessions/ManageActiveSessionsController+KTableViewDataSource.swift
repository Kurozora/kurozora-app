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
		let accessTokenCellRegistration = self.getConfiguredAccessTokenCell()
		let sessionLockupCellRegistration = self.getConfiguredSessionLockupCell()

		self.dataSource = SessionDataSource(tableView: self.tableView) { (tableView: UITableView, indexPath: IndexPath, itemKind: ItemKind) -> UITableViewCell? in
			switch itemKind {
			case .accessToken:
				return tableView.dequeueConfiguredReusableCell(using: accessTokenCellRegistration, for: indexPath, item: itemKind)
			case .sessionIdentity:
				return tableView.dequeueConfiguredReusableCell(using: sessionLockupCellRegistration, for: indexPath, item: itemKind)
			}
		}
		self.dataSource.defaultRowAnimation = .top
	}

	func updateDataSource() {
		self.cache.removeAll()
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		let currentAccessToken = self.currentAccessToken
		if let currentAccessToken = currentAccessToken {
			self.snapshot.appendSections([.current])
			self.snapshot.appendItems([.accessToken(currentAccessToken)], toSection: .current)
		}

		// Merge app and web sessions into one list, ordered by most recent activity.
		let appEntries: [(date: Date, item: ItemKind, session: Session?)] = self.appSessions
			.filter { $0.id != currentAccessToken?.id }
			.map { (date: $0.attributes.lastValidatedAt ?? .distantPast, item: .accessToken($0), session: nil) }
		let webEntries: [(date: Date, item: ItemKind, session: Session?)] = self.webSessions
			.map { (date: $0.attributes.lastValidatedAt, item: .sessionIdentity(SessionIdentity(id: $0.id)), session: $0) }
		let sessionEntries = (appEntries + webEntries).sorted { $0.date > $1.date }

		if !sessionEntries.isEmpty {
			self.snapshot.appendSections([.other])
			self.snapshot.appendItems(sessionEntries.map { $0.item }, toSection: .other)
		}

		// Pre-fill the cache with resolved web sessions so their cells render without a lazy fetch.
		let otherSectionIndex = currentAccessToken != nil ? 1 : 0
		for (index, entry) in sessionEntries.enumerated() {
			if let session = entry.session {
				self.cache[IndexPath(item: index, section: otherSectionIndex)] = session
			}
		}

		self.dataSource.apply(self.snapshot)
	}
}
