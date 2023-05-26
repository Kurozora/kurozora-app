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
			return "Unknown"
		case .doujinshi:
			return "Doujinshi"
		case .manhwa:
			return "Manhwa"
		case .manhua:
			return "Manhua"
		case .oel:
			return "OEL"
		case .novel:
			return "Novel"
		case .manga:
			return "Manga"
		case .lightNovel:
			return "Light Novel"
		case .oneShot:
			return "One-shot"
		}
	}
}
