//
//  SearchFilterCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension SearchFilterCollectionViewController {
	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}

	override func configureDataSource() {
		let pillCellRegistration = self.pillCellRegistration()
		let durationCellRegistration = self.durationCellRegistration()
		let menuCellRegistration = self.menuCellRegistration()
		let textCellRegistration = self.textCellRegistration()
		let starsCellRegistration = self.starsCellRegistration()

		self.dataSource = UICollectionViewDiffableDataSource<SearchFilterDataSource.Section, SearchFilterDataSource.ItemKind>(collectionView: self.collectionView) { collectionView, indexPath, item in
			switch item {
			case .pill:
				return collectionView.dequeueConfiguredReusableCell(using: pillCellRegistration, for: indexPath, item: item)
			case .duration:
				return collectionView.dequeueConfiguredReusableCell(using: durationCellRegistration, for: indexPath, item: item)
			case .row(let key, _, _):
				guard let descriptor = self.descriptor(for: key) else { return nil }

				switch descriptor.control {
				case .text:
					return collectionView.dequeueConfiguredReusableCell(using: textCellRegistration, for: indexPath, item: item)
				case .stars:
					return collectionView.dequeueConfiguredReusableCell(using: starsCellRegistration, for: indexPath, item: item)
				default:
					return collectionView.dequeueConfiguredReusableCell(using: menuCellRegistration, for: indexPath, item: item)
				}
			}
		}

		self.dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
			let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TitleHeaderCollectionReusableView.reuseIdentifier, for: indexPath) as? TitleHeaderCollectionReusableView
			let section = self.dataSource.sectionIdentifier(for: indexPath.section)

			switch section {
			case .filter(let key):
				titleHeaderCollectionReusableView?.configure(withTitle: self.headerTitle(for: key))
			case .details:
				titleHeaderCollectionReusableView?.configure(withTitle: L10n.information)
			case .none:
				break
			}

			return titleHeaderCollectionReusableView
		}
	}

	override func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SearchFilterDataSource.Section, SearchFilterDataSource.ItemKind>()

		for descriptor in self.descriptors where !descriptor.control.isRow {
			snapshot.appendSections([.filter(descriptor.key)])
			snapshot.appendItems(self.items(for: descriptor), toSection: .filter(descriptor.key))
		}

		let rowDescriptors = self.descriptors.filter { $0.control.isRow }

		if !rowDescriptors.isEmpty {
			snapshot.appendSections([.details])
			snapshot.appendItems(rowDescriptors.enumerated().map { index, descriptor in
				.row(
					key: descriptor.key,
					selectedValue: self.draftValue(for: descriptor.key),
					position: GroupedRowPosition(index: index, count: rowDescriptors.count)
				)
			}, toSection: .details)
		}

		self.dataSource.apply(snapshot, animatingDifferences: false)
	}

	/// The items the given filter contributes.
	///
	/// - Parameter descriptor: The filter to read.
	///
	/// - Returns: The items the section holds.
	private func items(for descriptor: FilterDescriptor) -> [SearchFilterDataSource.ItemKind] {
		let value = self.draftValue(for: descriptor.key)

		switch descriptor.control {
		case .numberPills(let options):
			var selection = FilterSelection<Int>()

			if case .selection(let stored) = value {
				selection = stored
			}

			return options.enumerated().map { index, option in
				.pill(key: descriptor.key, index: index, state: selection.state(of: option.value))
			}
		case .textPills(let options):
			var selection = FilterSelection<String>()

			if case .textSelection(let stored) = value {
				selection = stored
			}

			return options.enumerated().map { index, option in
				.pill(key: descriptor.key, index: index, state: selection.state(of: option.value))
			}
		case .booleanPills:
			var states: [FilterSelectionState] = [.neutral, .neutral]

			if case .boolean(let boolean) = value {
				states = boolean ? [.included, .neutral] : [.neutral, .included]
			}

			return states.enumerated().map { index, state in
				.pill(key: descriptor.key, index: index, state: state)
			}
		case .duration(let durations):
			var selected: Int?

			if case .range(let range) = value {
				selected = range.maximum
			}

			return durations.enumerated().map { index, duration in
				.duration(key: descriptor.key, index: index, isSelected: Int(duration) == selected)
			}
		case .buckets, .date, .text, .stars:
			return [.row(key: descriptor.key, selectedValue: value, position: .only)]
		}
	}
}

// MARK: - Cell Registrations
extension SearchFilterCollectionViewController {
	func pillCellRegistration() ->
	UICollectionView.CellRegistration<SearchFilterPillCollectionViewCell, SearchFilterDataSource.ItemKind> {
		return UICollectionView.CellRegistration<SearchFilterPillCollectionViewCell, SearchFilterDataSource.ItemKind> { searchFilterPillCollectionViewCell, _, item in
			switch item {
			case .pill(let key, let index, let state):
				guard let descriptor = self.descriptor(for: key) else { return }
				guard let title = self.optionTitles(for: descriptor)[safe: index] else { return }

				searchFilterPillCollectionViewCell.configureCell(
					title: title,
					subtitle: self.optionSubtitles(for: descriptor)[safe: index] ?? nil,
					state: state
				)
			default:
				break
			}
		}
	}

	func durationCellRegistration() ->
	UICollectionView.CellRegistration<SearchFilterDurationCollectionViewCell, SearchFilterDataSource.ItemKind> {
		return UICollectionView.CellRegistration<SearchFilterDurationCollectionViewCell, SearchFilterDataSource.ItemKind> { searchFilterDurationCollectionViewCell, _, item in
			switch item {
			case .duration(let key, let index, let isSelected):
				guard let descriptor = self.descriptor(for: key) else { return }
				guard case .duration(let durations) = descriptor.control else { return }
				guard let duration = durations[safe: index] else { return }

				searchFilterDurationCollectionViewCell.configureCell(duration: duration, isSelected: isSelected)
			default:
				break
			}
		}
	}

	func menuCellRegistration() ->
	UICollectionView.CellRegistration<SearchFilterMenuCollectionViewCell, SearchFilterDataSource.ItemKind> {
		return UICollectionView.CellRegistration<SearchFilterMenuCollectionViewCell, SearchFilterDataSource.ItemKind> { searchFilterMenuCollectionViewCell, _, item in
			switch item {
			case .row(let key, _, let position):
				guard let descriptor = self.descriptor(for: key) else { return }

				searchFilterMenuCollectionViewCell.configureCell(
					title: descriptor.title,
					value: self.selectedOptionTitle(for: descriptor),
					menu: self.menu(for: descriptor),
					position: position
				)
			default:
				break
			}
		}
	}

	func textCellRegistration() ->
	UICollectionView.CellRegistration<SearchFilterTextCollectionViewCell, SearchFilterDataSource.ItemKind> {
		return UICollectionView.CellRegistration<SearchFilterTextCollectionViewCell, SearchFilterDataSource.ItemKind>(cellNib: SearchFilterTextCollectionViewCell.nib) { searchFilterTextCollectionViewCell, _, item in
			switch item {
			case .row(let key, _, _):
				guard let descriptor = self.descriptor(for: key) else { return }

				var selected: String?

				if case .text(let text) = self.draftValue(for: key) {
					selected = text
				}

				searchFilterTextCollectionViewCell.delegate = self
				searchFilterTextCollectionViewCell.configureCell(title: descriptor.title, placeholder: nil, selected: selected)
			default:
				break
			}
		}
	}

	func starsCellRegistration() ->
	UICollectionView.CellRegistration<SearchFilterStarsCollectionViewCell, SearchFilterDataSource.ItemKind> {
		return UICollectionView.CellRegistration<SearchFilterStarsCollectionViewCell, SearchFilterDataSource.ItemKind> { searchFilterStarsCollectionViewCell, _, item in
			switch item {
			case .row(let key, _, let position):
				guard let descriptor = self.descriptor(for: key) else { return }

				let rating: Double? = switch self.draftValue(for: key) {
				case .rating(let rating): rating
				default: nil
				}

				searchFilterStarsCollectionViewCell.delegate = self
				searchFilterStarsCollectionViewCell.configureCell(title: descriptor.title, rating: rating, position: position)
			default:
				break
			}
		}
	}
}

// MARK: - Options
extension SearchFilterCollectionViewController {
	/// The title shown above the given filter.
	///
	/// - Parameter key: The filter to read.
	///
	/// - Returns: The title the header shows.
	func headerTitle(for key: FilterKey) -> String {
		guard let descriptor = self.descriptor(for: key) else { return "" }

		if case .duration = descriptor.control {
			return L10n.durationInUnder
		}

		return descriptor.title
	}

	/// The titles the given filter offers.
	///
	/// - Parameter descriptor: The filter to read.
	///
	/// - Returns: The titles the control lists.
	func optionTitles(for descriptor: FilterDescriptor) -> [String] {
		switch descriptor.control {
		case .numberPills(let options):
			return options.map { $0.title }
		case .textPills(let options):
			return options.map { $0.title }
		case .booleanPills(let trueTitle, let falseTitle):
			return [trueTitle, falseTitle]
		case .buckets(let buckets):
			return buckets.map { $0.title }
		case .duration(let durations):
			return durations.map { SearchFilterDurationCollectionViewCell.parts(of: $0).0 }
		case .date, .text, .stars:
			return []
		}
	}

	/// The details the given filter's choices carry.
	///
	/// - Parameter descriptor: The filter to read.
	///
	/// - Returns: The detail shown under each choice.
	func optionSubtitles(for descriptor: FilterDescriptor) -> [String?] {
		switch descriptor.control {
		case .numberPills(let options):
			return options.map { $0.subtitle }
		case .textPills(let options):
			return options.map { $0.subtitle }
		default:
			return []
		}
	}

	/// The title of the choice the user has made.
	///
	/// - Parameter descriptor: The filter to read.
	///
	/// - Returns: The title the control shows.
	func selectedOptionTitle(for descriptor: FilterDescriptor) -> String? {
		let value = self.draftValue(for: descriptor.key)

		switch descriptor.control {
		case .buckets(let buckets):
			guard case .range(let range) = value else { return nil }

			return buckets.first { $0.range == range }?.title
		case .date:
			guard case .date(let timeInterval) = value else { return nil }

			return Self.dateFormatter.string(from: Date(timeIntervalSince1970: timeInterval))
		default:
			return nil
		}
	}

	/// The menu the given filter's row offers.
	///
	/// - Parameter descriptor: The filter to read.
	///
	/// - Returns: The menu the row shows.
	func menu(for descriptor: FilterDescriptor) -> UIMenu {
		let isUnset = self.draftValue(for: descriptor.key) == nil
		let anyAction = UIAction(title: L10n.filterAny, state: isUnset ? .on : .off) { [weak self] _ in
			self?.setDraftValue(nil, for: descriptor.key)
			self?.updateDataSource()
		}

		switch descriptor.control {
		case .buckets(let buckets):
			let selected = self.selectedOptionTitle(for: descriptor)
			let actions = buckets.map { bucket in
				UIAction(title: bucket.title, state: bucket.title == selected ? .on : .off) { [weak self] _ in
					self?.setDraftValue(.range(bucket.range), for: descriptor.key)
					self?.updateDataSource()
				}
			}

			return UIMenu(options: .singleSelection, children: [anyAction] + actions)
		case .date:
			let chooseAction = UIAction(title: L10n.chooseDate) { [weak self] _ in
				self?.presentDatePicker(for: descriptor)
			}

			return UIMenu(children: [anyAction, chooseAction])
		default:
			return UIMenu(children: [anyAction])
		}
	}

	/// The formatter that writes a chosen date.
	private static let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = LanguageManager.shared.locale
		formatter.dateStyle = .medium
		formatter.timeStyle = .none
		return formatter
	}()

	/// The value the given title writes.
	///
	/// - Parameters:
	///    - title: The title the user picked.
	///    - descriptor: The filter the title belongs to.
	///
	/// - Returns: The value to hold against the filter.
	func value(forOptionTitle title: String, in descriptor: FilterDescriptor) -> FilterValue? {
		guard case .buckets(let buckets) = descriptor.control else { return nil }
		guard let bucket = buckets.first(where: { $0.title == title }) else { return nil }

		return .range(bucket.range)
	}
}
