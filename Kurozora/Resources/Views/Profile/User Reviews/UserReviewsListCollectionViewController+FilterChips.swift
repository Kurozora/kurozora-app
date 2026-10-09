//
//  UserReviewsListCollectionViewController+FilterChips.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/10/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension UserReviewsListCollectionViewController {
	/// Rebuilds the row of applied filter chips.
	func refreshFilterChips() {
		let chips = self.filterDescriptors.flatMap { descriptor -> [FilterChip] in
			guard let value = self.filterValues[descriptor.key], !value.isEmpty else { return [] }

			return descriptor.chips(for: value)
		}

		self.appliedFilterChips = chips
		self.filterChipsView.titles = chips.map { chip in
			chip.title(includesFilterTitle: chip.needsTitle)
		}

		self.setShowFilterChips(!chips.isEmpty)
	}

	/// Shows or hides the row of applied filter chips.
	///
	/// - Parameter show: Whether the row is shown.
	private func setShowFilterChips(_ show: Bool) {
		self.installFilterChipsViewIfNeeded()

		self.filterChipsView.isHidden = !show
		self.collectionView.contentInset.top = show ? KFilterChipsView.rowHeight : 0
		self.collectionView.verticalScrollIndicatorInsets.top = self.collectionView.contentInset.top
	}

	/// Places the row of applied filter chips below the navigation bar.
	private func installFilterChipsViewIfNeeded() {
		guard self.filterChipsView.superview == nil else { return }

		self.filterChipsView.translatesAutoresizingMaskIntoConstraints = false
		self.view.addSubview(self.filterChipsView)

		NSLayoutConstraint.activate([
			self.filterChipsView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.filterChipsView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.filterChipsView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
			self.filterChipsView.heightAnchor.constraint(equalToConstant: KFilterChipsView.rowHeight)
		])
	}

	/// Clears the choice the removed chip stands for.
	///
	/// - Parameter index: The position of the chip the user removed.
	func removeFilterChip(at index: Int) {
		guard let chip = self.appliedFilterChips[safe: index] else { return }

		self.filterValues[chip.key] = nil

		self.refreshFilterChips()
		self.refreshFilterBarButtonImage()
		self.reloadForQueryChange()
	}

	/// Updates the filter button to reflect whether a filter is applied.
	func refreshFilterBarButtonImage() {
		let imageName = self.filterValues.isEmpty ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill"

		self.filterBarButtonItem.image = UIImage(systemName: imageName)
	}
}
