//
//  NotificationsTableViewController+KTableViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/08/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension NotificationsTableViewController {
	override func registerNibs(for tableView: UITableView) -> [UITableViewHeaderFooterView.Type] {
		return [TitleHeaderTableReusableView.self]
	}

	func configureDataSource() {
		let baseNotificationCellRegistration = self.getConfiguredBaseNotificationCell()
		let basicNotificationCellRegistration = self.getConfiguredBasicNotificationCell()
		let iconNotificationCellRegistration = self.getConfiguredIconNotificationCell()

		self.dataSource = NotificationDataSource(tableView: self.tableView) { (tableView: UITableView, indexPath: IndexPath, userNotification: UserNotification) -> UITableViewCell? in
			switch userNotification.attributes.type {
			case .session:
				return tableView.dequeueConfiguredReusableCell(using: basicNotificationCellRegistration, for: indexPath, item: userNotification)
			case .follower:
				return tableView.dequeueConfiguredReusableCell(using: iconNotificationCellRegistration, for: indexPath, item: userNotification)
			case .feedMessageReply, .feedMessageReShare:
				return tableView.dequeueConfiguredReusableCell(using: iconNotificationCellRegistration, for: indexPath, item: userNotification)
			case .animeImportFinished, .subscriptionStatus:
				return tableView.dequeueConfiguredReusableCell(using: basicNotificationCellRegistration, for: indexPath, item: userNotification)
			case .other:
				return tableView.dequeueConfiguredReusableCell(using: baseNotificationCellRegistration, for: indexPath, item: userNotification)
			}
		}
	}

	func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, UserNotification>()

		switch self.grouping {
		case .automatic, .byType:
			if !self.groupedNotifications.isEmpty {
				self.groupedNotifications.forEach { groupedNotification in
					let groupedSection: SectionLayoutKind = .grouped(groupedNotification)
					snapshot.appendSections([groupedSection])
					snapshot.appendItems(groupedNotification.sectionNotifications, toSection: groupedSection)
				}
			}
		case .off:
			if !self.userNotifications.isEmpty {
				snapshot.appendSections([.main])
				snapshot.appendItems(self.userNotifications, toSection: .main)
			}
		}

		self.dataSource.apply(snapshot)
	}

	func getConfiguredBaseNotificationCell() -> UITableView.CellRegistration<BaseNotificationCell, UserNotification> {
		return UITableView.CellRegistration<BaseNotificationCell, UserNotification>(cellNib: UINib(resource: R.nib.baseNotificationCell)) { baseNotificationCell, _, userNotification in
			baseNotificationCell.configureCell(using: userNotification)
		}
	}

	func getConfiguredBasicNotificationCell() -> UITableView.CellRegistration<BasicNotificationCell, UserNotification> {
		return UITableView.CellRegistration<BasicNotificationCell, UserNotification>(cellNib: UINib(resource: R.nib.basicNotificationCell)) { basicNotificationCell, _, userNotification in
			basicNotificationCell.configureCell(using: userNotification)
		}
	}

	func getConfiguredIconNotificationCell() -> UITableView.CellRegistration<IconNotificationCell, UserNotification> {
		return UITableView.CellRegistration<IconNotificationCell, UserNotification>(cellNib: UINib(resource: R.nib.iconNotificationCell)) { iconNotificationCell, _, userNotification in
			iconNotificationCell.configureCell(using: userNotification)
		}
	}
}
