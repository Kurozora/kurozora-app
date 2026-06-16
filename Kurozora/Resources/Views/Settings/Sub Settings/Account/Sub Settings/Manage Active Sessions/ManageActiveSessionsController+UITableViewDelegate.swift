//
//  ManageActiveSessionsController+UITableViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension ManageActiveSessionsController {
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		guard let sectionIdentifier = self.dataSource.sectionIdentifier(for: indexPath.section) else { return }

		switch sectionIdentifier {
		case .current:
			return
		case .other:
			let lastItemIndex = tableView.numberOfRows(inSection: indexPath.section) - 1

			if indexPath.item >= lastItemIndex - 5, self.nextPageCursor != nil {
				Task { [weak self] in
					guard let self = self else { return }
					await self.fetchSessions()
				}
			}
		}
	}

	override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		guard !self.isEditing else { return }
		(tableView.cellForRow(at: indexPath) as? SessionLockupCell)?.applyHighlightedAppearance(highlighted: true)
	}

	override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		guard !self.isEditing else { return }
		(tableView.cellForRow(at: indexPath) as? SessionLockupCell)?.applyHighlightedAppearance(highlighted: false)
	}

	override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		return self.dataSource.sectionIdentifier(for: indexPath.section) == .current ? nil : indexPath
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard self.isEditing else {
			tableView.deselectRow(at: indexPath, animated: true)
			return
		}
		self.didUpdateBatchSelection()
	}

	override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		guard self.isEditing else { return }
		self.didUpdateBatchSelection()
	}

	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		guard let sectionIdentifier = self.dataSource.sectionIdentifier(for: section) else { return nil }
		let titleHeaderTableReusableView = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: TitleHeaderTableReusableView.reuseIdentifier) as? TitleHeaderTableReusableView

		switch sectionIdentifier {
		case .current:
			titleHeaderTableReusableView?.configure(withTitle: L10n.currentSession)
		case .other:
			titleHeaderTableReusableView?.configure(withTitle: L10n.otherSessions)
		}

		titleHeaderTableReusableView?.headerButton.isHidden = true
		return titleHeaderTableReusableView
	}

	// MARK: - Responding to Row Actions
	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		guard let sectionIdentifier = self.dataSource.sectionIdentifier(for: indexPath.section) else { return nil }

		switch sectionIdentifier {
		case .current:
			return nil
		case .other:
			let signOutOfSessionAction = UIContextualAction(style: .destructive, title: L10n.signOut) { [weak self] _, _, completionHandler in
				guard
					let self = self,
					let itemKind = self.dataSource.itemIdentifier(for: indexPath)
				else { return }

				Task {
					switch itemKind {
					case .accessToken(let accessToken):
						await accessToken.signOutOfAccessToken(at: indexPath)
					case .sessionIdentity:
						if let session = self.cache[indexPath] as? Session {
							await session.signOutOfSession(at: indexPath)
						}
					}
					completionHandler(true)
				}
			}
			signOutOfSessionAction.backgroundColor = .kLightRed
			signOutOfSessionAction.image = UIImage(systemName: "minus.circle")

			let swipeActionsConfiguration = UISwipeActionsConfiguration(actions: [signOutOfSessionAction])
			swipeActionsConfiguration.performsFirstActionWithFullSwipe = true
			return swipeActionsConfiguration
		}
	}

	// MARK: - Managing Context Menus
	override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let sectionIdentifier = self.dataSource.sectionIdentifier(for: indexPath.section) else { return nil }

		switch sectionIdentifier {
		case .current:
			return nil
		case .other:
			guard let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { return nil }
			let tableViewCell = tableView.cellForRow(at: indexPath)

			switch itemKind {
			case .accessToken(let accessToken):
				return accessToken.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: tableViewCell?.contentView, barButtonItem: nil)
			case .sessionIdentity:
				guard let session = self.cache[indexPath] as? Session else { return nil }
				return session.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: tableViewCell?.contentView, barButtonItem: nil)
			}
		}
	}

	override func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
		if let indexPath = configuration.identifier as? IndexPath, let tableViewCell = tableView.cellForRow(at: indexPath), tableViewCell.window != nil {
			let parameters = UIPreviewParameters()
			parameters.backgroundColor = .clear
			return UITargetedPreview(view: tableViewCell, parameters: parameters)
		}
		return nil
	}

	override func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
		if let indexPath = configuration.identifier as? IndexPath, let tableViewCell = tableView.cellForRow(at: indexPath), tableViewCell.window != nil {
			let parameters = UIPreviewParameters()
			parameters.backgroundColor = .clear
			return UITargetedPreview(view: tableViewCell, parameters: parameters)
		}
		return nil
	}
}
