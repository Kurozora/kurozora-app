//
//  LiteratureType.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

enum LiteratureType: Int, CaseIterable {
	// MARK: - Cases
	case unknown = 8
	case manga = 14
	case manhwa = 10
	case manhua = 11
	case lightNovel = 15
	case novel = 13
	case oneShot = 16
	case doujinshi = 9
	case oel = 12

	// MARK: - Properties
	/// The name value of a literature type.
	var name: String {
		switch self {
		case .unknown:
			return L10n.unknown
		case .manga:
			return L10n.manga
		case .manhwa:
			return L10n.manhwa
		case .manhua:
			return L10n.manhua
		case .lightNovel:
			return L10n.lightNovel
		case .novel:
			return L10n.novel
		case .oneShot:
			return L10n.oneShot
		case .doujinshi:
			return L10n.doujinshi
		case .oel:
			return L10n.oel
		}
	}
}
