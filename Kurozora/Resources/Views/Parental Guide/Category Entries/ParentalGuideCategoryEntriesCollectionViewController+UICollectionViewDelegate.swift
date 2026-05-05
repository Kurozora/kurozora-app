//
//  ParentalGuideCategoryEntriesCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension ParentalGuideCategoryEntriesCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { return nil }

		switch itemKind {
		case .entry(let entry):
			let cell = collectionView.cellForItem(at: indexPath)
			var info: [AnyHashable: Any] = ["indexPath": indexPath]

			if let mediaType = self.mediaType {
				info["mediaType"] = mediaType
			}

			return entry.contextMenuConfiguration(in: self, userInfo: info, sourceView: cell?.contentView, barButtonItem: nil)
		}
	}
}

// MARK: - ParentalGuideReasonCollectionViewCellDelegate
extension ParentalGuideCategoryEntriesCollectionViewController: ParentalGuideReasonCollectionViewCellDelegate {
	func parentalGuideReasonCollectionViewCell(_ cell: ParentalGuideReasonCollectionViewCell, didTapVote vote: ParentalGuideVote?) {
		guard
			let indexPath = self.collectionView.indexPath(for: cell),
			let itemKind = self.dataSource.itemIdentifier(for: indexPath),
			case .entry(let entry) = itemKind
		else { return }

		Task { [weak self] in
			guard let self = self else { return }
			let signedIn = await WorkflowController.shared.isSignedIn(on: self)
			guard signedIn else { return }

			let oldHelpful = entry.attributes.isHelpful
			let tapHelpful: Bool? = vote.map { $0 == .helpful }
			let predicted: Bool? = (oldHelpful == tapHelpful) ? nil : tapHelpful

			entry.attributes.applyVote(predicted)
			NotificationCenter.default.post(
				name: .KPGEntryDidUpdate,
				object: nil,
				userInfo: ["entry": entry, "indexPath": indexPath]
			)

			let entryIdentity = ParentalGuideEntryIdentity(id: entry.id)
			let request = ParentalGuideVoteRequest(vote: vote)

			do {
				let response = try await KService.voteParentalGuideEntry(entryIdentity, request: request).response()
				entry.attributes.applyVote(response.data.isHelpful)
				NotificationCenter.default.post(
					name: .KPGEntryDidUpdate,
					object: nil,
					userInfo: ["entry": entry, "indexPath": indexPath]
				)
			} catch {
				entry.attributes.applyVote(oldHelpful)
				NotificationCenter.default.post(
					name: .KPGEntryDidUpdate,
					object: nil,
					userInfo: ["entry": entry, "indexPath": indexPath]
				)
				print(error.localizedDescription)
			}
		}
	}

	func parentalGuideReasonCollectionViewCell(_ cell: ParentalGuideReasonCollectionViewCell, contextMenuFor entry: ParentalGuideEntry) -> UIMenu? {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return nil }

		var info: [AnyHashable: Any] = ["indexPath": indexPath]

		if let mediaType = self.mediaType {
			info["mediaType"] = mediaType
		}

		return entry.makeContextMenu(in: self, userInfo: info, sourceView: cell.contentView, barButtonItem: nil)
	}

	func parentalGuideReasonCollectionViewCellDidTapShowMore(_ cell: ParentalGuideReasonCollectionViewCell) {
		guard
			let indexPath = self.collectionView.indexPath(for: cell),
			let itemKind = self.dataSource.itemIdentifier(for: indexPath),
			case .entry(let entry) = itemKind
		else { return }

		self.expandedEntryIDs.insert(entry.id)
		self.reloadEntry(at: indexPath)
	}
}
