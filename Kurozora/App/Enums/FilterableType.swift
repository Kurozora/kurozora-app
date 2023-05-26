//
//  FilterableType.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

struct FilterableAttribute {
	// MARK: - Properties
	let name: String
	let type: FilterableType
	let options: [(key: String, value: Int)]?
	var selected: Any? = nil
}

enum FilterableType {
	// MARK: - Cases
	case text
	case stepper
	case singleSelection
	case date
	case time
	case dateTime
	case range
	case `switch`
}

enum FilterKey {
	case age
	case astrologicalSign
	case birthDay
	case birthMonth
	case bust
	case height
	case hip
	case status
	case waist
	case weight

	case duration
	case isFiller
	case isNSFW
	case isSpecial
	case isPremiere
	case isFinale
	case isVerified
	case number
	case numberTotal
	case season
	case tvRating
	case startedAt
	case endedAt

	case publicationDay
	case publicationSeason
	case publishedAt
	case mediaType
	case source
	case editionCount

	case publicationTime
	case volumeCount
	case chapterCount
	case pageCount

	case birthDate
	case deceasedDate

	case airDay
	case airSeason
	case airTime
	case seasonCount
	case episodeCount

	case address
	case founded
	case type
}
