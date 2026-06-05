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
	case doujinshi = 9
	case manhwa = 10
	case manhua = 11
	case oel = 12
	case novel = 13
	case manga = 14
	case lightNovel = 15
	case oneShot = 16

	// MARK: - Properties
	/// The name value of a literature type.
	var name: String {
		switch self {
		case .unknown:
			return L10n.unknown
		case .doujinshi:
			return L10n.doujinshi
		case .manhwa:
			return L10n.manhwa
		case .manhua:
			return L10n.manhua
		case .oel:
			return L10n.oel
		case .novel:
			return L10n.novel
		case .manga:
			return L10n.manga
		case .lightNovel:
			return L10n.lightNovel
		case .oneShot:
			return L10n.oneShot
		}
	}
}
