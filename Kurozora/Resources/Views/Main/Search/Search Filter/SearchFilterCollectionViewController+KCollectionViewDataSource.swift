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

		self.dataSource = UICollectionViewDiffableDataSource<SearchFilter.Section, SearchFilter.ItemKind>(collectionView: self.collectionView) { collectionView, indexPath, item in
			switch item {
			case .searchFilter(let attribute, _):
				switch attribute.type {
				case .singleSelection:
					return collectionView.dequeueConfiguredReusableCell(using: selectCellRegistration, for: indexPath, item: item)
				case .multiSelection:
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
		case .character(let characterFilter):
			itemKind = self.filterableAttributes.map { filterableAttribute in
				var value: AnyHashable?

				switch filterableAttribute.key {
				case .status:
					if let status = characterFilter.status {
						value = CharacterStatus(rawValue: status)?.title
					}
				case .age:
					value = characterFilter.age
				case .birthDay:
					if let birthDay = characterFilter.birthDay {
						value = birthDay < 10 ? "0\(birthDay)" : "\(birthDay)"
					}
				case .birthMonth:
					if let birthMonth = characterFilter.birthMonth {
						value = Month(rawValue: birthMonth)?.name
					}
				case .height:
					value = characterFilter.height
				case .weight:
					value = characterFilter.weight
				case .bust:
					value = characterFilter.bust
				case .waist:
					value = characterFilter.waist
				case .hip:
					value = characterFilter.hip
				case .astrologicalSign:
					if let astrologicalSignValue = characterFilter.astrologicalSign, let astrologicalSign = AstrologicalSign(rawValue: astrologicalSignValue) {
						value = "\(astrologicalSign.title) \(astrologicalSign.emoji)"
					}
				default: break
				}

				filterableAttribute.value.selected = value

				return .searchFilter(attribute: filterableAttribute.value, selectedValue: value)
			}
		case .episode(let episodeFilter):
			itemKind = self.filterableAttributes.map { filterableAttribute in
				var value: AnyHashable?

				switch filterableAttribute.key {
				case .duration:
					if let duration = episodeFilter.duration, duration != 0 {
						value = duration / 60 // We get it in seconds, but present to the user in minutes
					}
				case .tvRating:
					if let tvRating = episodeFilter.tvRating {
						value = TVRating(rawValue: tvRating)?.name
					}
				case .isFiller:
					if let isFiller = episodeFilter.isFiller {
						value = isFiller ? "Shown" : "Hidden"
					}
				case .isPremiere:
					if let isPremiere = episodeFilter.isPremiere {
						value = isPremiere ? "Shown" : "Hidden"
					}
				case .isFinale:
					if let isFinale = episodeFilter.isFinale {
						value = isFinale ? "Shown" : "Hidden"
					}
				case .isSpecial:
					if let isSpecial = episodeFilter.isSpecial {
						value = isSpecial ? "Shown" : "Hidden"
					}
				case .isNSFW:
					if let isNSFW = episodeFilter.isNSFW {
						value = isNSFW ? "Shown" : "Hidden"
					}
				case .number:
					value = episodeFilter.number
				case .numberTotal:
					value = episodeFilter.numberTotal
				case .startedAt:
					if let startedAt = episodeFilter.startedAt {
						value = Date(timeIntervalSince1970: startedAt)
					}
				case .endedAt:
					if let endedAt = episodeFilter.endedAt {
						value = Date(timeIntervalSince1970: endedAt)
					}
				default: break
				}

				filterableAttribute.value.selected = value

				return .searchFilter(attribute: filterableAttribute.value, selectedValue: value)
			}
		case .game(let gameFilter):
			itemKind = self.filterableAttributes.map { filterableAttribute in
				var value: AnyHashable?

				switch filterableAttribute.key {
				case .mediaType:
					if let mediaType = gameFilter.mediaType {
						value = GameType(rawValue: mediaType)?.name
					}
				case .status:
					if let status = gameFilter.status {
						value = GameStatus(rawValue: status)?.name
					}
				case .source:
					if let source = gameFilter.source {
						value = SourceType(rawValue: source)?.name
					}
				case .tvRating:
					if let tvRating = gameFilter.tvRating {
						value = TVRating(rawValue: tvRating)?.name
					}
				case .countryOfOrigin:
					if let countryOfOrigin = gameFilter.countryOfOrigin {
						value = CountryOfOrigin.allCases.first { countryOfOriginCase in
							countryOfOriginCase.name == countryOfOrigin
						}?.name
					}
				case .editionCount:
					value = gameFilter.editionCount
				case .publicationSeason:
					if let publicationSeason = gameFilter.publicationSeason {
						value = SeasonOfYear(rawValue: publicationSeason)?.name
					}
				case .publicationDay:
					if let publicationDay = gameFilter.publicationDay {
						value = DayOfWeek(rawValue: publicationDay)?.name
					}
				case .duration:
					if let duration = gameFilter.duration, duration != 0 {
						value = duration / 60 // We get it in seconds, but present to the user in minutes
					}
				case .publishedAt:
					if let publishedAt = gameFilter.publishedAt {
						value = Date(timeIntervalSince1970: publishedAt)
					}
				case .isNSFW:
					if let isNSFW = gameFilter.isNSFW {
						value = isNSFW ? "Shown" : "Hidden"
					}
				default: break
				}

				filterableAttribute.value.selected = value

				return .searchFilter(attribute: filterableAttribute.value, selectedValue: value)
			}
		case .literature(let literatureFilter):
			itemKind = self.filterableAttributes.map { filterableAttribute in
				var value: AnyHashable?

				switch filterableAttribute.key {
				case .mediaType:
					if let mediaType = literatureFilter.mediaType {
						value = LiteratureType(rawValue: mediaType)?.name
					}
				case .status:
					if let status = literatureFilter.status {
						value = LiteratureStatus(rawValue: status)?.name
					}
				case .source:
					if let source = literatureFilter.source {
						value = SourceType(rawValue: source)?.name
					}
				case .tvRating:
					if let tvRating = literatureFilter.tvRating {
						value = TVRating(rawValue: tvRating)?.name
					}
				case .countryOfOrigin:
					if let countryOfOrigin = literatureFilter.countryOfOrigin {
						value = CountryOfOrigin.allCases.first { countryOfOriginCase in
							countryOfOriginCase.name == countryOfOrigin
						}?.name
					}
				case .volumeCount:
					value = literatureFilter.volumeCount
				case .chapterCount:
					value = literatureFilter.chapterCount
				case .pageCount:
					value = literatureFilter.pageCount
				case .duration:
					if let duration = literatureFilter.duration, duration != 0 {
						value = duration / 60 // We get it in seconds, but present to the user in minutes
					}
				case .publicationSeason:
					if let publicationSeason = literatureFilter.publicationSeason {
						value = SeasonOfYear(rawValue: publicationSeason)?.name
					}
				case .publicationDay:
					if let publicationDay = literatureFilter.publicationDay {
						value = DayOfWeek(rawValue: publicationDay)?.name
					}
				case .publicationTime:
					if let publicationTime = literatureFilter.publicationTime {
						value = publicationTime.toDate(format: "HH:mm:ss")
					}
				case .startedAt:
					if let startedAt = literatureFilter.startedAt {
						value = Date(timeIntervalSince1970: startedAt)
					}
				case .endedAt:
					if let endedAt = literatureFilter.endedAt {
						value = Date(timeIntervalSince1970: endedAt)
					}
				case .isNSFW:
					if let isNSFW = literatureFilter.isNSFW {
						value = isNSFW ? "Shown" : "Hidden"
					}
				default: break
				}

				filterableAttribute.value.selected = value

				return .searchFilter(attribute: filterableAttribute.value, selectedValue: value)
			}
		case .person(let personFilter):
			itemKind = self.filterableAttributes.map { filterableAttribute in
				var value: AnyHashable?

				switch filterableAttribute.key {
				case .birthDate:
					if let birthDate = personFilter.birthDate {
						value = Date(timeIntervalSince1970: birthDate)
					}
				case .deceasedDate:
					if let deceasedDate = personFilter.deceasedDate {
						value = Date(timeIntervalSince1970: deceasedDate)
					}
				case .astrologicalSign:
					if let astrologicalSignValue = personFilter.astrologicalSign, let astrologicalSign = AstrologicalSign(rawValue: astrologicalSignValue) {
						value = "\(astrologicalSign.title) \(astrologicalSign.emoji)"
					}
				default: break
				}

				filterableAttribute.value.selected = value

				return .searchFilter(attribute: filterableAttribute.value, selectedValue: value)
			}
		case .show(let showFilter):
			itemKind = self.filterableAttributes.map { filterableAttribute in
				var value: AnyHashable?

				switch filterableAttribute.key {
				case .mediaType:
					if let mediaType = showFilter.mediaType {
						value = ShowType(rawValue: mediaType)?.name
					}
				case .status:
					if let status = showFilter.status {
						value = ShowStatus(rawValue: status)?.name
					}
				case .tvRating:
					if let tvRating = showFilter.tvRating {
						value = TVRating(rawValue: tvRating)?.name
					}
				case .countryOfOrigin:
					if let countryOfOrigin = showFilter.countryOfOrigin {
						value = CountryOfOrigin.allCases.first { countryOfOriginCase in
							countryOfOriginCase.name == countryOfOrigin
						}?.name
					}
				case .seasonCount:
					value = showFilter.seasonCount
				case .episodeCount:
					value = showFilter.episodeCount
				case .airDay:
					if let airDay = showFilter.airDay {
						value = DayOfWeek(rawValue: airDay)?.name
					}
				case .airTime:
					if let airTime = showFilter.airTime {
						value = airTime.toDate(format: "HH:mm:ss")
					}
				case .airSeason:
					if let airSeason = showFilter.airSeason {
						value = SeasonOfYear(rawValue: airSeason)?.name
					}
				case .duration:
					if let duration = showFilter.duration, duration != 0 {
						value = duration / 60 // We get it in seconds, but present to the user in minutes
					}
				case .startedAt:
					if let startedAt = showFilter.startedAt {
						value = Date(timeIntervalSince1970: startedAt)
					}
				case .endedAt:
					if let endedAt = showFilter.endedAt {
						value = Date(timeIntervalSince1970: endedAt)
					}
				case .source:
					if let source = showFilter.source {
						value = SourceType(rawValue: source)?.name
					}
				case .isNSFW:
					if let isNSFW = showFilter.isNSFW {
						value = isNSFW ? "Shown" : "Hidden"
					}
				default: break
				}

				filterableAttribute.value.selected = value

				return .searchFilter(attribute: filterableAttribute.value, selectedValue: value)
			}
		case .studio(let studioFilter):
			itemKind = self.filterableAttributes.map { filterableAttribute in
				var value: AnyHashable?

				switch filterableAttribute.key {
				case .type:
					if let type = studioFilter.type {
						value = StudioType(rawValue: type)?.name
					}
				case .tvRating:
					if let tvRating = studioFilter.tvRating {
						value = TVRating(rawValue: tvRating)?.name
					}
				case .address:
					value = studioFilter.address
				case .foundedAt:
					if let foundedAt = studioFilter.foundedAt {
						value = Date(timeIntervalSince1970: foundedAt)
					}
				case .defunctAt:
					if let defunctAt = studioFilter.defunctAt {
						value = Date(timeIntervalSince1970: defunctAt)
					}
				case .isNSFW:
					if let isNSFW = studioFilter.isNSFW {
						value = isNSFW ? "Shown" : "Hidden"
					}
				default: break
				}

				filterableAttribute.value.selected = value

				return .searchFilter(attribute: filterableAttribute.value, selectedValue: value)
			}
		default:
			itemKind = self.filterableAttributes.map { filterableAttribute in
				filterableAttribute.value.selected = nil

				return .searchFilter(attribute: filterableAttribute.value, selectedValue: nil)
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
		return UICollectionView.CellRegistration<SearchFilterDateCollectionViewCell, SearchFilter.ItemKind>(cellNib: SearchFilterDateCollectionViewCell.nib) { searchFilterDateCollectionViewCell, _, item in
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
		return UICollectionView.CellRegistration<SearchFilterSelectCollectionViewCell, SearchFilter.ItemKind>(cellNib: SearchFilterSelectCollectionViewCell.nib) { searchFilterSelectCollectionViewCell, _, item in
			switch item {
			case .searchFilter(let attribute, _):
				guard let options = attribute.options?.map({ key, _ in
					return key
				}) else { return }
				let selectedOption = attribute.options?.first { key, _ in
					return key == attribute.selected as? String
				}

				searchFilterSelectCollectionViewCell.delegate = self
				searchFilterSelectCollectionViewCell.configureCell(title: attribute.name, options: options, selected: selectedOption?.key)
			}
		}
	}

	func switchCellRegistration() ->
	UICollectionView.CellRegistration<SearchFilterSwitchCollectionViewCell, SearchFilter.ItemKind> {
		return UICollectionView.CellRegistration<SearchFilterSwitchCollectionViewCell, SearchFilter.ItemKind>(cellNib: SearchFilterSwitchCollectionViewCell.nib) { searchFilterSwitchCollectionViewCell, _, item in
			switch item {
			case .searchFilter(let attribute, _):
				searchFilterSwitchCollectionViewCell.delegate = self
				searchFilterSwitchCollectionViewCell.configureCell(title: attribute.name, selected: attribute.selected as? Bool)
			}
		}
	}

	func textCellRegistration() ->
	UICollectionView.CellRegistration<SearchFilterTextCollectionViewCell, SearchFilter.ItemKind> {
		return UICollectionView.CellRegistration<SearchFilterTextCollectionViewCell, SearchFilter.ItemKind>(cellNib: SearchFilterTextCollectionViewCell.nib) { searchFilterTextCollectionViewCell, _, item in
			switch item {
			case .searchFilter(let attribute, _):
				searchFilterTextCollectionViewCell.delegate = self
				searchFilterTextCollectionViewCell.configureCell(title: attribute.name, placeholder: nil, selected: attribute.selected as? String)
			}
		}
	}

	func stepperCellRegistration() ->
	UICollectionView.CellRegistration<SearchFilterStepperCollectionViewCell, SearchFilter.ItemKind> {
		return UICollectionView.CellRegistration<SearchFilterStepperCollectionViewCell, SearchFilter.ItemKind>(cellNib: SearchFilterStepperCollectionViewCell.nib) { searchFilterStepperCollectionViewCell, _, item in
			switch item {
			case .searchFilter(let attribute, _):
				searchFilterStepperCollectionViewCell.delegate = self
				searchFilterStepperCollectionViewCell.configureCell(title: attribute.name, selected: attribute.selected as? Double)
			}
		}
	}
}
