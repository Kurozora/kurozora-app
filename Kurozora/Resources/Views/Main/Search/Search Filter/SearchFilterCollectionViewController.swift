//
//  SearchFilterCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

protocol SearchFilterCollectionViewControllerDelegate: AnyObject {
	func searchFilterCollectionViewController(_ searchFilterCollectionViewController: SearchFilterCollectionViewController, didApply filter: KKSearchFilter)
	func searchFilterCollectionViewControllerDidReset(_ searchFilterCollectionViewController: SearchFilterCollectionViewController)
	func searchFilterCollectionViewControllerDidCancel(_ searchFilterCollectionViewController: SearchFilterCollectionViewController)
}

class SearchFilterCollectionViewController: KCollectionViewController {
	// MARK: - IBOutlets
	@IBOutlet var cancelBarButtonItem: UIBarButtonItem!
	@IBOutlet var resetBarButtonItem: UIBarButtonItem!

	// MARK: - Views
	var applyButton = KTintedButton()

	// MARK: - Properties
	var searchType: KKSearchType?
	var filterableAttributes: [(key: FilterKey, value: FilterableAttribute)] = []
	var filter: KKSearchFilter?

	var dataSource: UICollectionViewDiffableDataSource<SearchFilter.Section, SearchFilter.ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SearchFilter.Section, SearchFilter.ItemKind>!

	var delegate: SearchFilterCollectionViewControllerDelegate?

	// Refresh control
	var _prefersRefreshControlDisabled = false {
		didSet {
			self.setNeedsRefreshControlAppearanceUpdate()
		}
	}
	override var prefersRefreshControlDisabled: Bool {
		return self._prefersRefreshControlDisabled
	}

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}
	override var prefersActivityIndicatorHidden: Bool {
		return self._prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.configure()

		if let searchType = self.searchType {
			self.filterableAttributes = searchType.filterableAttributes
		}

		self.configureDataSource()
		self.updateDataSource()
	}

	// MARK: - Functions
	func configure() {
		self.configureViews()
		self.configureViewHierarchy()
		self.configureViewConstraints()
	}

	func configureViews() {
		self.configureView()
		self.configureCollectionView()
		self.configureRestBarButtonItem()
		self.configureApplyButton()
	}

	func configureView() {
		// Disable Refresh Control & hide Activity Indicator
		self._prefersRefreshControlDisabled = true
		self._prefersActivityIndicatorHidden = true
		self.title = Trans.filters
	}

	func configureCollectionView() {
		self.collectionView.contentInset.bottom = 50
		self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset
	}

	func configureRestBarButtonItem() {
		self.resetBarButtonItem.title = Trans.reset
	}

	func configureApplyButton() {
		self.applyButton.translatesAutoresizingMaskIntoConstraints = false
		self.applyButton.setTitle(Trans.apply, for: .normal)
		self.applyButton.addTarget(self, action: #selector(self.handleApplyButtonPressed(_:)), for: .touchUpInside)
	}

	func configureViewHierarchy() {
		self.view.addSubview(self.applyButton)
	}

	func configureViewConstraints() {
		NSLayoutConstraint.activate([
			self.applyButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 12.0),
			self.applyButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -24.0),
			self.applyButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12.0)
		])
	}

	@objc
	func handleApplyButtonPressed(_ sender: UIButton) {
		self.applyButtonPressed()
	}

	func applyButtonPressed() {
		var newSearchFilter: KKSearchFilter?

		if let oldSearchFilter = self.filter {
			switch oldSearchFilter {
			case .appTheme(let appThemeFilter):
				newSearchFilter = self.getNewSearchFilter(merging: appThemeFilter)
			case .character(let characterFilter):
				newSearchFilter = self.getNewSearchFilter(merging: characterFilter)
			case .episode(let episodeFilter):
				newSearchFilter = self.getNewSearchFilter(merging: episodeFilter)
			case .game(let gameFilter):
				newSearchFilter = self.getNewSearchFilter(merging: gameFilter)
			case .literature(let literatureFilter):
				newSearchFilter = self.getNewSearchFilter(merging: literatureFilter)
			case .person(let personFilter):
				newSearchFilter = self.getNewSearchFilter(merging: personFilter)
			case .show(let showFilter):
				newSearchFilter = self.getNewSearchFilter(merging: showFilter)
			case .song(let songFilter):
				newSearchFilter = self.getNewSearchFilter(merging: songFilter)
			case .studio(let studioFilter):
				newSearchFilter = self.getNewSearchFilter(merging: studioFilter)
			case .user(let userFilter):
				newSearchFilter = self.getNewSearchFilter(merging: userFilter)
			}
		} else if let searchType = self.searchType {
			switch searchType {
			case .characters:
				newSearchFilter = self.getNewSearchFilter(merging: CharacterFilter())
			case .episodes:
				newSearchFilter = self.getNewSearchFilter(merging: EpisodeFilter())
			case .games:
				newSearchFilter = self.getNewSearchFilter(merging: GameFilter())
			case .literatures:
				newSearchFilter = self.getNewSearchFilter(merging: LiteratureFilter())
			case .people:
				newSearchFilter = self.getNewSearchFilter(merging: PersonFilter())
			case .shows:
				newSearchFilter = self.getNewSearchFilter(merging: ShowFilter())
			case .songs:
				newSearchFilter = self.getNewSearchFilter(merging: SongFilter())
			case .studios:
				newSearchFilter = self.getNewSearchFilter(merging: StudioFilter())
			case .users:
				newSearchFilter = self.getNewSearchFilter(merging: UserFilter())
			}
		}

		guard let newSearchFilter = newSearchFilter else { return }
		let searchFilterCollectionViewController = self

		self.dismiss(animated: true) {
			searchFilterCollectionViewController.delegate?.searchFilterCollectionViewController(searchFilterCollectionViewController, didApply: newSearchFilter)
		}
	}

	private func getNewSearchFilter(merging searchFilter: Any?) -> KKSearchFilter? {
		if let characterFilter = searchFilter as? CharacterFilter {
			var age: Int? = characterFilter.age
			var astrologicalSign: Int? = characterFilter.astrologicalSign
			var birthDay: Int? = characterFilter.birthDay
			var birthMonth: Int? = characterFilter.birthMonth
			var bust: Double? = characterFilter.bust
			var height: Double? = characterFilter.height
			var hip: Double? = characterFilter.hip
			var status: Int? = characterFilter.status
			var waist: Double? = characterFilter.waist
			var weight: Double? = characterFilter.weight

			self.filterableAttributes.forEach { key, value in
				switch key {
				case .age:
					age = value.selected as? Int
				case .astrologicalSign:
					astrologicalSign = value.options?.first { key, _ in
						key == value.selected as? String
					}?.value
				case .birthDay:
					birthDay = value.options?.first { key, _ in
						key == value.selected as? String
					}?.value
				case .birthMonth:
					birthMonth = value.options?.first { key, _ in
						key == value.selected as? String
					}?.value
				case .bust:
					bust = value.selected as? Double
				case .height:
					height = value.selected as? Double
				case .hip:
					hip = value.selected as? Double
				case .status:
					status = value.options?.first { key, _ in
						key == value.selected as? String
					}?.value
				case .waist:
					waist = value.selected as? Double
				case .weight:
					weight = value.selected as? Double
				default: break
				}
			}

			let characterFilter = CharacterFilter(age: age, astrologicalSign: astrologicalSign, birthDay: birthDay, birthMonth: birthMonth, bust: bust, height: height, hip: hip, status: status, waist: waist, weight: weight)
			return .character(characterFilter)
		} else if let episodeFilter = searchFilter as? EpisodeFilter {
			var duration: Int? = episodeFilter.duration
			var isFiller: Bool? = episodeFilter.isFiller
			var isNSFW: Bool? = episodeFilter.isNSFW
			var isSpecial: Bool? = episodeFilter.isSpecial
			var isPremiere: Bool? = episodeFilter.isPremiere
			var isFinale: Bool? = episodeFilter.isFinale
			var number: Int? = episodeFilter.number
			var numberTotal: Int? = episodeFilter.numberTotal
			var season: Int? = episodeFilter.season
			var tvRating: Int? = episodeFilter.tvRating
			var startedAt: TimeInterval? = episodeFilter.startedAt
			var endedAt: TimeInterval? = episodeFilter.endedAt

			self.filterableAttributes.forEach { key, value in
				switch key {
				case .duration:
					if let selected = (value.selected as? Double)?.int {
						duration = selected * 60
					}
				case .isFiller:
					isFiller = (value.options?.first { key, _ in
						key == value.selected as? String
					}?.value as? NSNumber)?.boolValue
				case .isNSFW:
					isNSFW = (value.options?.first { key, _ in
						key == value.selected as? String
					}?.value as? NSNumber)?.boolValue
				case .isSpecial:
					isSpecial = (value.options?.first { key, _ in
						key == value.selected as? String
					}?.value as? NSNumber)?.boolValue
				case .isPremiere:
					isPremiere = (value.options?.first { key, _ in
						key == value.selected as? String
					}?.value as? NSNumber)?.boolValue
				case .isFinale:
					isFinale = (value.options?.first { key, _ in
						key == value.selected as? String
					}?.value as? NSNumber)?.boolValue
				case .number:
					number = value.selected as? Int
				case .numberTotal:
					numberTotal = value.selected as? Int
				case .season:
					season = value.selected as? Int
				case .tvRating:
					tvRating = value.options?.first { key, _ in
						key == value.selected as? String
					}?.value
				case .startedAt:
					startedAt = (value.selected as? Date)?.timeIntervalSince1970
				case .endedAt:
					endedAt = (value.selected as? Date)?.timeIntervalSince1970
				default: break
				}
			}

			let episodeFilter = EpisodeFilter(duration: duration, isFiller: isFiller, isNSFW: isNSFW, isSpecial: isSpecial, isPremiere: isPremiere, isFinale: isFinale, number: number, numberTotal: numberTotal, season: season, tvRating: tvRating, startedAt: startedAt, endedAt: endedAt)
			return .episode(episodeFilter)
		} else if let gameFilter = searchFilter as? GameFilter {
			var publicationDay: Int? = gameFilter.publicationDay
			var publicationSeason: Int? = gameFilter.publicationSeason
			var duration: Int? = gameFilter.duration
			var publishedAt: TimeInterval? = gameFilter.publishedAt
			var isNSFW: Bool? = gameFilter.isNSFW
			var mediaType: Int? = gameFilter.mediaType
			var source: Int? = gameFilter.source
			var status: Int? = gameFilter.status
			var tvRating: Int? = gameFilter.tvRating
			var editionCount: Int? = gameFilter.editionCount

			self.filterableAttributes.forEach { key, value in
				switch key {
				case .publicationDay:
					publicationDay = value.selected as? Int
				case .publicationSeason:
					publicationSeason = value.selected as? Int
				case .duration:
					if let selected = (value.selected as? Double)?.int {
						duration = selected * 60
					}
				case .publishedAt:
					publishedAt = (value.selected as? Date)?.timeIntervalSince1970
				case .isNSFW:
					isNSFW = (value.options?.first { key, _ in
						key == value.selected as? String
					}?.value as? NSNumber)?.boolValue
				case .mediaType:
					mediaType = value.options?.first { key, _ in
						key == value.selected as? String
					}?.value
				case .source:
					source = value.options?.first { key, _ in
						key == value.selected as? String
					}?.value
				case .status:
					status = value.options?.first { key, _ in
						key == value.selected as? String
					}?.value
				case .tvRating:
					tvRating = value.options?.first { key, _ in
						key == value.selected as? String
					}?.value
				case .editionCount:
					editionCount = (value.selected as? Double)?.int
				default: break
				}
			}

			let gameFilter = GameFilter(publicationDay: publicationDay, publicationSeason: publicationSeason, duration: duration, publishedAt: publishedAt, isNSFW: isNSFW, mediaType: mediaType, source: source, status: status, tvRating: tvRating, editionCount: editionCount)
			return .game(gameFilter)
		} else if let literatureFilter = searchFilter as? LiteratureFilter {
			var publicationDay: Int? = literatureFilter.publicationDay
			var publicationSeason: Int? = literatureFilter.publicationSeason
			var publicationTime: String? = literatureFilter.publicationTime
			var duration: Int? = literatureFilter.duration
			var startedAt: TimeInterval? = literatureFilter.startedAt
			var endedAt: TimeInterval? = literatureFilter.endedAt
			var isNSFW: Bool? = literatureFilter.isNSFW
			var mediaType: Int? = literatureFilter.mediaType
			var source: Int? = literatureFilter.source
			var status: Int? = literatureFilter.status
			var tvRating: Int? = literatureFilter.tvRating
			var volumeCount: Int? = literatureFilter.volumeCount
			var chapterCount: Int? = literatureFilter.chapterCount
			var pageCount: Int? = literatureFilter.pageCount

			self.filterableAttributes.forEach { key, value in
				switch key {
				case .publicationDay:
					publicationDay = value.options?.first { key, _ in
						key == value.selected as? String
					}?.value
				case .publicationSeason:
					publicationSeason = value.options?.first { key, _ in
						key == value.selected as? String
					}?.value
				case .publicationTime:
					publicationTime = (value.selected as? Date)?.convertTo24Hour()
				case .duration:
					if let selected = (value.selected as? Double)?.int {
						duration = selected * 60
					}
				case .startedAt:
					startedAt = (value.selected as? Date)?.timeIntervalSince1970
				case .endedAt:
					endedAt = (value.selected as? Date)?.timeIntervalSince1970
				case .isNSFW:
					isNSFW = (value.options?.first { key, _ in
						key == value.selected as? String
					}?.value as? NSNumber)?.boolValue
				case .mediaType:
					mediaType = value.options?.first { key, _ in
						key == value.selected as? String
					}?.value
				case .source:
					source = value.options?.first { key, _ in
						key == value.selected as? String
					}?.value
				case .status:
					status = value.options?.first { key, _ in
						key == value.selected as? String
					}?.value
				case .tvRating:
					tvRating = value.options?.first { key, _ in
						key == value.selected as? String
					}?.value
				case .volumeCount:
					volumeCount = (value.selected as? Double)?.int
				case .chapterCount:
					chapterCount = (value.selected as? Double)?.int
				case .pageCount:
					pageCount = (value.selected as? Double)?.int
				default: break
				}
			}

			let literatureFilter = LiteratureFilter(publicationDay: publicationDay, publicationSeason: publicationSeason, publicationTime: publicationTime, duration: duration, startedAt: startedAt, endedAt: endedAt, isNSFW: isNSFW, mediaType: mediaType, source: source, status: status, tvRating: tvRating, volumeCount: volumeCount, chapterCount: chapterCount, pageCount: pageCount)
			return .literature(literatureFilter)
		} else if let personFilter = searchFilter as? PersonFilter {
			var astrologicalSign: Int? = personFilter.astrologicalSign
			var birthDate: TimeInterval? = personFilter.birthDate
			var deceasedDate: TimeInterval? = personFilter.deceasedDate

			self.filterableAttributes.forEach { key, value in
				switch key {
				case .astrologicalSign:
					astrologicalSign = value.options?.first { key, _ in
						key == value.selected as? String
					}?.value
				case .birthDate:
					birthDate = (value.selected as? Date)?.timeIntervalSince1970
				case .deceasedDate:
					deceasedDate = (value.selected as? Date)?.timeIntervalSince1970
				default: break
				}
			}

			let personFilter = PersonFilter(astrologicalSign: astrologicalSign, birthDate: birthDate, deceasedDate: deceasedDate)
			return .person(personFilter)
		} else if let showFilter = searchFilter as? ShowFilter {
			var airDay: Int? = showFilter.airDay
			var airSeason: Int? = showFilter.airSeason
			var airTime: String? = showFilter.airTime
			var duration: Int? = showFilter.duration
			var isNSFW: Bool? = showFilter.isNSFW
			var startedAt: TimeInterval? = showFilter.startedAt
			var endedAt: TimeInterval? = showFilter.endedAt
			var mediaType: Int? = showFilter.mediaType
			var source: Int? = showFilter.source
			var status: Int? = showFilter.status
			var tvRating: Int? = showFilter.tvRating
			var seasonCount: Int? = showFilter.seasonCount
			var episodeCount: Int? = showFilter.episodeCount

			self.filterableAttributes.forEach { key, value in
				switch key {
				case .airDay:
					airDay = value.options?.first { key, _ in
						key == value.selected as? String
					}?.value
				case .airSeason:
					airSeason = value.options?.first { key, _ in
						key == value.selected as? String
					}?.value
				case .airTime:
					airTime = (value.selected as? Date)?.convertTo24Hour()
				case .duration:
					if let selected = (value.selected as? Double)?.int {
						duration = selected * 60
					}
				case .isNSFW:
					isNSFW = (value.options?.first { key, _ in
						key == value.selected as? String
					}?.value as? NSNumber)?.boolValue
				case .startedAt:
					startedAt = (value.selected as? Date)?.timeIntervalSince1970
				case .endedAt:
					endedAt = (value.selected as? Date)?.timeIntervalSince1970
				case .mediaType:
					mediaType = value.options?.first { key, _ in
						key == value.selected as? String
					}?.value
				case .source:
					source = value.options?.first { key, _ in
						key == value.selected as? String
					}?.value
				case .status:
					status = value.options?.first { key, _ in
						key == value.selected as? String
					}?.value
				case .tvRating:
					tvRating = value.options?.first { key, _ in
						key == value.selected as? String
					}?.value
				case .seasonCount:
					seasonCount = (value.selected as? Double)?.int
				case .episodeCount:
					episodeCount = (value.selected as? Double)?.int
				default: break
				}
			}

			let showFilter = ShowFilter(airDay: airDay, airSeason: airSeason, airTime: airTime, duration: duration, isNSFW: isNSFW, startedAt: startedAt, endedAt: endedAt, mediaType: mediaType, source: source, status: status, tvRating: tvRating, seasonCount: seasonCount, episodeCount: episodeCount)
			return .show(showFilter)
		} else if searchFilter is SongFilter {
			self.filterableAttributes.forEach { key, _ in
				switch key {
				default: break
				}
			}

			let songFilter = SongFilter()
			return .song(songFilter)
		} else if let studioFilter = searchFilter as? StudioFilter {
			var address: String? = studioFilter.address
			var founded: String? = studioFilter.founded
			var isNSFW: Bool? = studioFilter.isNSFW
			var type: Int? = studioFilter.type

			self.filterableAttributes.forEach { key, value in
				switch key {
				case .address:
					address = value.selected as? String
				case .founded:
					founded = value.selected as? String
				case .isNSFW:
					isNSFW = (value.options?.first { key, _ in
						key == value.selected as? String
					}?.value as? NSNumber)?.boolValue
				case .type:
					type = value.options?.first { key, _ in
						key == value.selected as? String
					}?.value
				default: break
				}
			}

			let studioFilter = StudioFilter(address: address, founded: founded, isNSFW: isNSFW, type: type)
			return .studio(studioFilter)
		} else if searchFilter is UserFilter {
			self.filterableAttributes.forEach { key, _ in
				switch key {
				default: break
				}
			}

			let userFilter = UserFilter()
			return .user(userFilter)
		}

		return nil
	}

	// MARK: - IBActions
	@IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
		let searchFilterCollectionViewController = self

		self.dismiss(animated: true) {
			searchFilterCollectionViewController.delegate?.searchFilterCollectionViewControllerDidCancel(searchFilterCollectionViewController)
		}
	}

	@IBAction func resetButtonPressed(_ sender: UIBarButtonItem) {
		self.filter = nil

		self.updateDataSource()
	}
}

// MARK: - SearchFilterBaseCollectionViewCellDelegate
extension SearchFilterCollectionViewController: SearchFilterBaseCollectionViewCellDelegate {
	func searchFilterBaseCollectionViewCell(_ cell: SearchFilterBaseCollectionViewCell, didChangeValue value: Any?) {
		guard let indexPath = collectionView.indexPath(for: cell) else { return }
		guard let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { return }

		switch itemKind {
		case .searchFilter(let filterableAttribute, _):
			guard let index = self.filterableAttributes.firstIndex(where: { (_, attribute) in
				filterableAttribute.name == attribute.name
			}) else { return }

			self.filterableAttributes[index].value.selected = value
		}
	}
}
