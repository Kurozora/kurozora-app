//
//  SearchFilterCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension SearchFilterCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)

		guard let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { return }

		switch itemKind {
		case .pill(let key, let index, _):
			self.togglePill(at: index, for: key)
		case .duration(let key, let index, let isSelected):
			self.toggleDuration(at: index, for: key, isSelected: isSelected)
		case .row:
			break
		}
	}

	/// Moves the given pill to its next state.
	///
	/// - Parameters:
	///    - index: The position of the pill within its filter.
	///    - key: The filter the pill belongs to.
	private func togglePill(at index: Int, for key: FilterKey) {
		guard let descriptor = self.descriptor(for: key) else { return }

		let value = self.draftValue(for: key)

		switch descriptor.control {
		case .numberPills(let options):
			guard let option = options[safe: index] else { return }

			var selection = FilterSelection<Int>()

			if case .selection(let stored) = value {
				selection = stored
			}

			self.setDraftValue(.selection(selection.cycling(option.value)), for: key)
		case .textPills(let options):
			guard let option = options[safe: index] else { return }

			var selection = FilterSelection<String>()

			if case .textSelection(let stored) = value {
				selection = stored
			}

			self.setDraftValue(.textSelection(selection.cycling(option.value)), for: key)
		case .booleanPills:
			let tapped = index == 0

			if case .boolean(let boolean) = value, boolean == tapped {
				self.setDraftValue(nil, for: key)
			} else {
				self.setDraftValue(.boolean(tapped), for: key)
			}
		default:
			break
		}

		self.updateDataSource()
	}

	/// Moves the given duration to its next state.
	///
	/// - Parameters:
	///    - index: The position of the duration within its filter.
	///    - key: The filter the duration belongs to.
	///    - isSelected: Whether the duration is the chosen one.
	private func toggleDuration(at index: Int, for key: FilterKey, isSelected: Bool) {
		guard let descriptor = self.descriptor(for: key) else { return }
		guard case .duration(let durations) = descriptor.control else { return }
		guard let duration = durations[safe: index] else { return }

		if isSelected {
			self.setDraftValue(nil, for: key)
		} else {
			self.setDraftValue(.range(FilterRange(maximum: Int(duration))), for: key)
		}

		self.updateDataSource()
	}
}
