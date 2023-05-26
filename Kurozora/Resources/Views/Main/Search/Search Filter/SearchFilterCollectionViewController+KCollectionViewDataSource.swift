//
//  SearchFilterCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension SearchFilterCollectionViewController {
	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}

	override func configureDataSource() {
		let dateCellRegistration = self.dateCellRegistration()
		let selectCellRegistration = self.selectCellRegistration()
		let switchCellRegistration = self.switchCellRegistration()
		let textCellRegistration = self.textCellRegistration()
		let stepperCellRegistration = self.stepperCellRegistration()

		self.dataSource = UICollectionViewDiffableDataSource<SearchFilter.Section, SearchFilter.ItemKind>(collectionView: collectionView) { collectionView, indexPath, item in
			switch item {
			case .searchFilter(let attribute, _):
				switch attribute.type {
				case .singleSelection:
					return collectionView.dequeueConfiguredReusableCell(using: selectCellRegistration, for: indexPath, item: item)
				case .date:
					return collectionView.dequeueConfiguredReusableCell(using: dateCellRegistration, for: indexPath, item: item)
				case .time:
					return collectionView.dequeueConfiguredReusableCell(using: dateCellRegistration, for: indexPath, item: item)
				case .dateTime:
					return collectionView.dequeueConfiguredReusableCell(using: dateCellRegistration, for: indexPath, item: item)
				case .range:
					return collectionView.dequeueConfiguredReusableCell(using: textCellRegistration, for: indexPath, item: item)
				case .`switch`:
					return collectionView.dequeueConfiguredReusableCell(using: switchCellRegistration, for: indexPath, item: item)
				case .text:
					return collectionView.dequeueConfiguredReusableCell(using: textCellRegistration, for: indexPath, item: item)
				case .stepper:
					return collectionView.dequeueConfiguredReusableCell(using: stepperCellRegistration, for: indexPath, item: item)
				}
			}
		}
	}

	override func updateDataSource() {
		var itemKind: [SearchFilter.ItemKind] = []

		switch self.filter {
		case .show(let showFilter):
			itemKind = self.filterableAttributes.map { filterableAttribute in
				var value: Any?

				switch filterableAttribute.key {
				case .status:
					value = showFilter.status
				case .duration:
					value = showFilter.duration
				case .isNSFW:
					value = showFilter.isNSFW
				case .tvRating:
					value = showFilter.tvRating
				case .startedAt:
					value = showFilter.startedAt
				case .endedAt:
					value = showFilter.endedAt
				case .mediaType:
					value = showFilter.mediaType
				case .source:
					value = showFilter.source
				case .airDay:
					value = showFilter.airDay
				case .airSeason:
					value = showFilter.airSeason
				case .airTime:
					value = showFilter.airTime
				case .seasonCount:
					value = showFilter.seasonCount
				case .episodeCount:
					value = showFilter.episodeCount
				default: break
				}

				return .searchFilter(attribute: filterableAttribute.value, value: value)
			}
		default:
			itemKind = self.filterableAttributes.map { filterableAttribute in
				return .searchFilter(attribute: filterableAttribute.value, value: nil)
			}
		}

		var snapshot = NSDiffableDataSourceSnapshot<SearchFilter.Section, SearchFilter.ItemKind>()
		snapshot.appendSections([.main])
		snapshot.appendItems(itemKind, toSection: .main)

		self.dataSource.apply(snapshot)
	}
}

extension SearchFilterCollectionViewController {
	func dateCellRegistration() ->
	UICollectionView.CellRegistration<SearchFilterDateCollectionViewCell, SearchFilter.ItemKind> {
		return UICollectionView.CellRegistration<SearchFilterDateCollectionViewCell, SearchFilter.ItemKind>(cellNib: UINib(resource: R.nib.searchFilterDateCollectionViewCell)) { searchFilterDateCollectionViewCell, _, item in
			switch item {
			case .searchFilter(let attribute, _):
				searchFilterDateCollectionViewCell.delegate = self
				searchFilterDateCollectionViewCell.configureCell(title: attribute.name, selected: attribute.selected as? Date)

				switch attribute.type {
				case .date:
					searchFilterDateCollectionViewCell.datePicker.datePickerMode = .date
				case .dateTime:
					searchFilterDateCollectionViewCell.datePicker.datePickerMode = .dateAndTime
				case .time:
					searchFilterDateCollectionViewCell.datePicker.datePickerMode = .time
				default: break
				}
			}
		}
	}

	func selectCellRegistration() ->
	UICollectionView.CellRegistration<SearchFilterSelectCollectionViewCell, SearchFilter.ItemKind> {
		return UICollectionView.CellRegistration<SearchFilterSelectCollectionViewCell, SearchFilter.ItemKind>(cellNib: UINib(resource: R.nib.searchFilterSelectCollectionViewCell)) { searchFilterSelectCollectionViewCell, _, item in
			switch item {
			case .searchFilter(let attribute, let selectedValue):
				guard let options = attribute.options?.map({ key, _ in
					return key
				}) else { return }
				let selectedOption = attribute.options?.first { _, value in
					return value == selectedValue as? Int
				}

				searchFilterSelectCollectionViewCell.delegate = self
				searchFilterSelectCollectionViewCell.configureCell(title: attribute.name, options: Array(options), selected: selectedOption?.key)
			}
		}
	}

	func switchCellRegistration() ->
	UICollectionView.CellRegistration<SearchFilterSwitchCollectionViewCell, SearchFilter.ItemKind> {
		return UICollectionView.CellRegistration<SearchFilterSwitchCollectionViewCell, SearchFilter.ItemKind>(cellNib: UINib(resource: R.nib.searchFilterSwitchCollectionViewCell)) { searchFilterSwitchCollectionViewCell, _, item in
			switch item {
			case .searchFilter(let attribute, _):
				searchFilterSwitchCollectionViewCell.delegate = self
				searchFilterSwitchCollectionViewCell.configureCell(title: attribute.name, selected: attribute.selected as? Bool)
			}
		}
	}

	func textCellRegistration() ->
	UICollectionView.CellRegistration<SearchFilterTextCollectionViewCell, SearchFilter.ItemKind> {
		return UICollectionView.CellRegistration<SearchFilterTextCollectionViewCell, SearchFilter.ItemKind>(cellNib: UINib(resource: R.nib.searchFilterTextCollectionViewCell)) { searchFilterTextCollectionViewCell, _, item in
			switch item {
			case .searchFilter(let attribute, _):
				searchFilterTextCollectionViewCell.delegate = self
				searchFilterTextCollectionViewCell.configureCell(title: attribute.name, placeholder: nil, selected: attribute.selected as? String)
			}
		}
	}

	func stepperCellRegistration() ->
	UICollectionView.CellRegistration<SearchFilterStepperCollectionViewCell, SearchFilter.ItemKind> {
		return UICollectionView.CellRegistration<SearchFilterStepperCollectionViewCell, SearchFilter.ItemKind>(cellNib: UINib(resource: R.nib.searchFilterStepperCollectionViewCell)) { searchFilterStepperCollectionViewCell, _, item in
			switch item {
			case .searchFilter(let attribute, _):
				searchFilterStepperCollectionViewCell.delegate = self
				searchFilterStepperCollectionViewCell.configureCell(title: attribute.name, selected: attribute.selected as? Double)
			}
		}
	}
}
