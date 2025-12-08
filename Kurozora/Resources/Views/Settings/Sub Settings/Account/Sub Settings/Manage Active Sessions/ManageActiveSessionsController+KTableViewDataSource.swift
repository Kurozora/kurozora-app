//
//  ManageActiveSessionsController+KTableViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/07/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension ManageActiveSessionsController {
	override func registerNibs(for tableView: UITableView) -> [UITableViewHeaderFooterView.Type] {
		return [TitleHeaderTableReusableView.self]
	}

	func configureDataSource() {
		let currentSessionCellRegistration = getConfiguredCurrentSessionCell()
		let sessionLockupCellRegistration = getConfiguredSessionLockupCell()

		self.dataSource = SessionDataSource(tableView: self.tableView) { (tableView: UITableView, indexPath: IndexPath, itemKind: ItemKind) -> UITableViewCell? in
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
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		if let accessToken = User.current?.relationships?.accessTokens?.data.first {
			snapshot.appendSections([.current])
			snapshot.appendItems([.accessToken(accessToken)], toSection: .current)
		}

		if !self.sessionIdentities.isEmpty {
			let sessionIdentityItemKinds: [ItemKind] = self.sessionIdentities.map { sessionIdentity in
				return .sessionIdentity(sessionIdentity)
			}

			snapshot.appendSections([.other])
			snapshot.appendItems(sessionIdentityItemKinds, toSection: .other)
		}

		self.dataSource.apply(snapshot)
	}

	func fetchSession(_ itemKind: ItemKind) -> Session? {
		switch itemKind {
		case .sessionIdentity(let sessionIdentity):
			return self.sessions.first { _, session in
				session.id == sessionIdentity.id
			}?.value
		default: return nil
		}
	}

	func setItemKindNeedsUpdate(_ itemKind: ItemKind) {
		var snapshot = self.dataSource.snapshot()
		guard snapshot.indexOfItem(itemKind) != nil else { return }
		snapshot.reconfigureItems([itemKind])
		self.dataSource.apply(snapshot, animatingDifferences: true)
	}

	func getConfiguredCurrentSessionCell() -> UITableView.CellRegistration<SessionLockupCell, ItemKind> {
		return UITableView.CellRegistration<SessionLockupCell, ItemKind>(cellNib: SessionLockupCell.nib) { currentSessionCell, _, itemKind in
			switch itemKind {
			case .accessToken(let accessToken):
				currentSessionCell.configureCell(using: accessToken)
			default: break
			}
		}
	}

	func getConfiguredSessionLockupCell() -> UITableView.CellRegistration<SessionLockupCell, ItemKind> {
		return UITableView.CellRegistration<SessionLockupCell, ItemKind>(cellNib: SessionLockupCell.nib) { [weak self] sessionLockupCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .sessionIdentity(let sessionIdentity):
				let session = self.fetchSession(itemKind)

				if session == nil {
					Task {
						do {
							let sessionResponse = try await KService.getDetails(forSession: sessionIdentity).value
							self.sessions[indexPath] = sessionResponse.data.first
							self.setItemKindNeedsUpdate(itemKind)
						} catch {
							print(error.localizedDescription)
						}
					}
				}

				sessionLockupCell.configureCell(using: session)
			default: break
			}
		}
	}
}
