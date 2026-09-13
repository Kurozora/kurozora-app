//
//  SearchResultsCollectionViewController+FilterChips.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension SearchResultsCollectionViewController {
	/// Rebuilds the row of applied filter chips.
	func refreshFilterChips() {
		guard let searchType = self.searchTypes[safe: self.currentIndex] else {
			self.setShowFilterChips(false)
			return
		}

		let descriptors = searchType.filterDescriptors
		let chips = self.appliedFilterChips(for: searchType, descriptors: descriptors)
		let ambiguousTitles = Self.ambiguousOptionTitles(in: descriptors)

		self.appliedFilterChips = chips
		self.filterChipsView.titles = chips.map { chip in
			let needsTitle = chip.needsTitle || ambiguousTitles.contains(chip.optionTitle)
			return chip.title(includesFilterTitle: needsTitle)
		}

		self.setShowFilterChips(!chips.isEmpty)
	}

	/// The chips describing the filter applied to the given search type.
	///
	/// - Parameters:
	///    - searchType: The type whose filter is read.
	///    - descriptors: The filters the type offers.
	///
	/// - Returns: One chip per choice the user made.
	private func appliedFilterChips(for searchType: SearchType, descriptors: [FilterDescriptor]) -> [FilterChip] {
		guard let filter = self.searchFilters[searchType] ?? nil else { return [] }

		return descriptors.flatMap { descriptor -> [FilterChip] in
			guard let value = filter[descriptor.key], !value.isEmpty else { return [] }

			return descriptor.chips(for: value)
		}
	}

	/// The choice names that more than one filter offers.
	///
	/// - Parameter descriptors: The filters the type offers.
	///
	/// - Returns: The names that do not stand on their own.
	private static func ambiguousOptionTitles(in descriptors: [FilterDescriptor]) -> Set<String> {
		var counts: [String: Int] = [:]

		for descriptor in descriptors {
			for title in descriptor.optionTitles {
				counts[title, default: 0] += 1
			}
		}

		return Set(counts.filter { $0.value > 1 }.keys)
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

	/// Places the row of applied filter chips below the search bar.
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
		guard let searchType = self.searchTypes[safe: self.currentIndex] else { return }
		guard let chip = self.appliedFilterChips[safe: index] else { return }
		guard let filter = self.searchFilters[searchType] ?? nil else { return }

		let newFilter = filter.setting(self.value(clearing: chip, in: filter), for: chip.key)
		self.searchFilters[searchType] = newFilter.isEmpty ? nil : newFilter

		self.refreshFilterChips()
		self.refreshFilterBarButtonImage(for: searchType)

		guard let searchScope = SearchScope(rawValue: self.kSearchController.searchBar.selectedScopeButtonIndex) else { return }

		self.performSearch(
			with: self.searchQuery,
			in: searchScope,
			for: [searchType],
			with: self.searchFilters[searchType] ?? nil,
			next: nil,
			resettingResults: true
		)
	}

	/// The value left once the given chip is cleared.
	///
	/// - Parameters:
	///    - chip: The chip the user removed.
	///    - filter: The filter the chip belongs to.
	///
	/// - Returns: The value to hold against the attribute.
	private func value(clearing chip: FilterChip, in filter: SearchFilter) -> FilterValue? {
		switch chip.removal {
		case .wholeKey:
			return nil
		case .number(let number):
			guard case .selection(let selection) = filter[chip.key] else { return nil }

			let remaining = FilterSelection(
				included: selection.included.subtracting([number]),
				excluded: selection.excluded.subtracting([number])
			)
			return remaining.isEmpty ? nil : .selection(remaining)
		case .text(let text):
			guard case .textSelection(let selection) = filter[chip.key] else { return nil }

			let remaining = FilterSelection(
				included: selection.included.subtracting([text]),
				excluded: selection.excluded.subtracting([text])
			)
			return remaining.isEmpty ? nil : .textSelection(remaining)
		}
	}

	/// Updates the filter button to reflect whether a filter is applied.
	///
	/// - Parameter searchType: The type whose filter is read.
	func refreshFilterBarButtonImage(for searchType: SearchType) {
		let isFiltered = (self.searchFilters[searchType] ?? nil) != nil
		let imageName = isFiltered ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle"

		self.kSearchController.searchBar.setImage(UIImage(systemName: imageName), for: .bookmark, state: .normal)
	}
}
