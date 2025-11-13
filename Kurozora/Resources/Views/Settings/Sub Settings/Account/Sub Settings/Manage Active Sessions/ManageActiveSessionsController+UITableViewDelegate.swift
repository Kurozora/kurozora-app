//
//  ManageActiveSessionsController+UITableViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

extension ManageActiveSessionsController {
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		guard let sectionIdentifier = self.dataSource.sectionIdentifier(for: indexPath.section) else { return }

		switch sectionIdentifier {
		case .current:
			return
		case .other:
			let sessionIdentities = self.sessionIdentities.count - 1
			var itemsCount = sessionIdentities / 4 / 2
			itemsCount = itemsCount > 15 ? 15 : itemsCount // Make sure count isn't above 15
			itemsCount = sessionIdentities - itemsCount
			itemsCount = itemsCount < 1 ? 1 : itemsCount // Make sure count isn't below 1

			if indexPath.item >= itemsCount && self.nextPageURL != nil {
				Task { [weak self] in
					guard let self = self else { return }
					await self.fetchSessions()
				}
			}
		}
	}

	override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		guard let sectionIdentifier = self.dataSource.sectionIdentifier(for: indexPath.section) else { return }

		switch sectionIdentifier {
		case .current:
			return
		case .other:
			guard let sessionLockupCell = tableView.cellForRow(at: indexPath) as? SessionLockupCell else { return }
		sessionLockupCell.contentView.theme_backgroundColor = KThemePicker.tableViewCellSelectedBackgroundColor.rawValue
		sessionLockupCell.primaryLabel.theme_textColor = KThemePicker.tableViewCellSelectedTitleTextColor.rawValue
		sessionLockupCell.secondaryLabel.theme_textColor = KThemePicker.tableViewCellSelectedSubTextColor.rawValue
		}
	}

	override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		guard let sectionIdentifier = self.dataSource.sectionIdentifier(for: indexPath.section) else { return }

		switch sectionIdentifier {
		case .current:
			return
		case .other:
			guard let sessionLockupCell = tableView.cellForRow(at: indexPath) as? SessionLockupCell else { return }
			sessionLockupCell.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
			sessionLockupCell.primaryLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
			sessionLockupCell.secondaryLabel.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}

	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		guard let sectionIdentifier = self.dataSource.sectionIdentifier(for: section) else { return nil }
		let titleHeaderTableReusableView = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: TitleHeaderTableReusableView.reuseIdentifier) as? TitleHeaderTableReusableView

		switch sectionIdentifier {
		case .current:
			titleHeaderTableReusableView?.configure(withTitle: Trans.currentSession)
		case .other:
			titleHeaderTableReusableView?.configure(withTitle: Trans.otherSessions)
		}

		titleHeaderTableReusableView?.headerButton.isHidden = true
		return titleHeaderTableReusableView
	}

	// MARK: - Responding to Row Actions
	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let signOutOfSessionAction = UIContextualAction(style: .destructive, title: "Sign Out") { [weak self] (_, _, completionHandler) in
			guard let self = self else { return }

			switch self.dataSource.itemIdentifier(for: indexPath) {
			case .sessionIdentity(let sessionIdentity):
				Task {
					let session = self.sessions.first { _, session in
						session.id == sessionIdentity.id
					}?.value
					await session?.signOutOfSession(at: indexPath)
					completionHandler(true)
				}
			default: break
			}
		}
		signOutOfSessionAction.backgroundColor = .kLightRed
		signOutOfSessionAction.image = UIImage(systemName: "minus.circle")

		let swipeActionsConfiguration = UISwipeActionsConfiguration(actions: [signOutOfSessionAction])
		swipeActionsConfiguration.performsFirstActionWithFullSwipe = true
		return swipeActionsConfiguration
	}

	// MARK: - Managing Context Menus
	override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let sectionIdentifier = self.dataSource.sectionIdentifier(for: indexPath.section) else { return nil }
		let tableViewCell = tableView.cellForRow(at: indexPath)

		switch sectionIdentifier {
		case .current:
			return nil
		case .other:
			switch self.dataSource.itemIdentifier(for: indexPath) {
			case .sessionIdentity(let sessionIdentity):
				let session = self.sessions.first { _, session in
					session.id == sessionIdentity.id
				}?.value

				return session?.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: tableViewCell?.contentView, barButtonItem: nil)
			default:
				return nil
			}
		}
	}

	override func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
		if let indexPath = configuration.identifier as? IndexPath, let tableViewCell = tableView.cellForRow(at: indexPath) {
			let parameters = UIPreviewParameters()
			parameters.backgroundColor = .clear
			return UITargetedPreview(view: tableViewCell, parameters: parameters)
		}
		return nil
	}

	override func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
		if let indexPath = configuration.identifier as? IndexPath, let tableViewCell = tableView.cellForRow(at: indexPath) {
			let parameters = UIPreviewParameters()
			parameters.backgroundColor = .clear
			return UITargetedPreview(view: tableViewCell, parameters: parameters)
		}
		return nil
	}
}
