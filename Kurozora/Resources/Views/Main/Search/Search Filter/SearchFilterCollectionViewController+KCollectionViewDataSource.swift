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
		let dateCellRegistration = self.dateCellRegistration()
		let selectCellRegistration = self.selectCellRegistration()
		let textCellRegistration = self.textCellRegistration()

		self.dataSource = UICollectionViewDiffableDataSource<SearchFilterDataSource.Section, SearchFilterDataSource.ItemKind>(collectionView: self.collectionView) { collectionView, indexPath, item in
			switch item {
			case .searchFilter(let key, _):
				guard let descriptor = self.descriptor(for: key) else { return nil }

				switch descriptor.control {
				case .date:
					return collectionView.dequeueConfiguredReusableCell(using: dateCellRegistration, for: indexPath, item: item)
				case .text:
					return collectionView.dequeueConfiguredReusableCell(using: textCellRegistration, for: indexPath, item: item)
				case .numberPills, .textPills, .booleanPills, .buckets, .duration:
					return collectionView.dequeueConfiguredReusableCell(using: selectCellRegistration, for: indexPath, item: item)
				}
			}
		}
	}

	override func updateDataSource() {
		let itemKind: [SearchFilterDataSource.ItemKind] = self.descriptors.map { descriptor in
			return .searchFilter(key: descriptor.key, selectedValue: self.draftValue(for: descriptor.key))
		}

		var snapshot = NSDiffableDataSourceSnapshot<SearchFilterDataSource.Section, SearchFilterDataSource.ItemKind>()
		snapshot.appendSections([.main])
		snapshot.appendItems(itemKind, toSection: .main)

		self.dataSource.apply(snapshot)
	}
}

// MARK: - Cell Registrations
extension SearchFilterCollectionViewController {
	func dateCellRegistration() ->
	UICollectionView.CellRegistration<SearchFilterDateCollectionViewCell, SearchFilterDataSource.ItemKind> {
		return UICollectionView.CellRegistration<SearchFilterDateCollectionViewCell, SearchFilterDataSource.ItemKind>(cellNib: SearchFilterDateCollectionViewCell.nib) { searchFilterDateCollectionViewCell, _, item in
			switch item {
			case .searchFilter(let key, _):
				guard let descriptor = self.descriptor(for: key) else { return }

				var selected: Date?

				if case .date(let timeInterval) = self.draftValue(for: key) {
					selected = Date(timeIntervalSince1970: timeInterval)
				}

				searchFilterDateCollectionViewCell.delegate = self
				searchFilterDateCollectionViewCell.configureCell(title: descriptor.title, selected: selected)
				searchFilterDateCollectionViewCell.datePicker.datePickerMode = .date
			}
		}
	}

	func selectCellRegistration() ->
	UICollectionView.CellRegistration<SearchFilterSelectCollectionViewCell, SearchFilterDataSource.ItemKind> {
		return UICollectionView.CellRegistration<SearchFilterSelectCollectionViewCell, SearchFilterDataSource.ItemKind>(cellNib: SearchFilterSelectCollectionViewCell.nib) { searchFilterSelectCollectionViewCell, _, item in
			switch item {
			case .searchFilter(let key, _):
				guard let descriptor = self.descriptor(for: key) else { return }

				let titles = self.optionTitles(for: descriptor)
				let selected = self.selectedOptionTitle(for: descriptor)

				searchFilterSelectCollectionViewCell.delegate = self
				searchFilterSelectCollectionViewCell.configureCell(title: descriptor.title, options: titles, selected: selected)
			}
		}
	}

	func textCellRegistration() ->
	UICollectionView.CellRegistration<SearchFilterTextCollectionViewCell, SearchFilterDataSource.ItemKind> {
		return UICollectionView.CellRegistration<SearchFilterTextCollectionViewCell, SearchFilterDataSource.ItemKind>(cellNib: SearchFilterTextCollectionViewCell.nib) { searchFilterTextCollectionViewCell, _, item in
			switch item {
			case .searchFilter(let key, _):
				guard let descriptor = self.descriptor(for: key) else { return }

				var selected: String?

				if case .text(let text) = self.draftValue(for: key) {
					selected = text
				}

				searchFilterTextCollectionViewCell.delegate = self
				searchFilterTextCollectionViewCell.configureCell(title: descriptor.title, placeholder: nil, selected: selected)
			}
		}
	}
}

// MARK: - Options
extension SearchFilterCollectionViewController {
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
			return durations.map { Self.durationTitle(for: $0) }
		case .date, .text:
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
		case .numberPills(let options):
			guard case .selection(let selection) = value, let included = selection.included.first else { return nil }

			return options.first { $0.value == included }?.title
		case .textPills(let options):
			guard case .textSelection(let selection) = value, let included = selection.included.first else { return nil }

			return options.first { $0.value == included }?.title
		case .booleanPills(let trueTitle, let falseTitle):
			guard case .boolean(let boolean) = value else { return nil }

			return boolean ? trueTitle : falseTitle
		case .buckets(let buckets):
			guard case .range(let range) = value else { return nil }

			return buckets.first { $0.range == range }?.title
		case .duration(let durations):
			guard case .range(let range) = value, let maximum = range.maximum else { return nil }

			return durations.first { Int($0) == maximum }.map { Self.durationTitle(for: $0) }
		case .date, .text:
			return nil
		}
	}

	/// The value the given title writes.
	///
	/// - Parameters:
	///    - title: The title the user picked.
	///    - descriptor: The filter the title belongs to.
	///
	/// - Returns: The value to hold against the filter.
	func value(forOptionTitle title: String, in descriptor: FilterDescriptor) -> FilterValue? {
		switch descriptor.control {
		case .numberPills(let options):
			guard let option = options.first(where: { $0.title == title }) else { return nil }

			return .selection(FilterSelection(option.value))
		case .textPills(let options):
			guard let option = options.first(where: { $0.title == title }) else { return nil }

			return .textSelection(FilterSelection(option.value))
		case .booleanPills(let trueTitle, _):
			return .boolean(title == trueTitle)
		case .buckets(let buckets):
			guard let bucket = buckets.first(where: { $0.title == title }) else { return nil }

			return .range(bucket.range)
		case .duration(let durations):
			guard let duration = durations.first(where: { Self.durationTitle(for: $0) == title }) else { return nil }

			return .range(FilterRange(maximum: Int(duration)))
		case .date, .text:
			return nil
		}
	}

	/// The title shown for the given duration.
	///
	/// - Parameter duration: The duration in seconds.
	///
	/// - Returns: The title the control shows.
	static func durationTitle(for duration: TimeInterval) -> String {
		let formatted = Self.durationFormatter.string(from: duration) ?? ""

		return L10n.underDuration(formatted)
	}

	/// The formatter that writes a duration.
	private static let durationFormatter: DateComponentsFormatter = {
		let formatter = DateComponentsFormatter()
		formatter.allowedUnits = [.hour, .minute]
		formatter.unitsStyle = .abbreviated
		formatter.zeroFormattingBehavior = .dropAll
		return formatter
	}()
}
