//
//  ForumsListViewController+UITableViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

extension ForumsListViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: R.segue.forumsListViewController.threadSegue, sender: self.forumsThreads[indexPath.section])
	}

	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let numberOfSections = tableView.numberOfSections

		if indexPath.section == numberOfSections - 5 {
			if self.nextPageURL != nil {
				self.fetchThreads()
			}
		}
	}

	override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		if let forumsCell = tableView.cellForRow(at: indexPath) as? ForumsCell {
			forumsCell.contentView.theme_backgroundColor = KThemePicker.tableViewCellSelectedBackgroundColor.rawValue

			forumsCell.titleLabel.theme_textColor = KThemePicker.tableViewCellSelectedTitleTextColor.rawValue
			forumsCell.contentLabel.theme_textColor = KThemePicker.tableViewCellSelectedSubTextColor.rawValue
			forumsCell.byLabel.theme_textColor = KThemePicker.tableViewCellSelectedSubTextColor.rawValue

		}
	}

	override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		if let forumsCell = tableView.cellForRow(at: indexPath) as? ForumsCell {
			forumsCell.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue

			forumsCell.titleLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
			forumsCell.contentLabel.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
			forumsCell.byLabel.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}

	// MARK: - Managing Context Menus
	override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		return self.forumsThreads[indexPath.section].contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
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

	override func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
		animator.addCompletion {
			if let previewViewController = animator.previewViewController {
				self.show(previewViewController, sender: self)
			}
		}
	}
}
