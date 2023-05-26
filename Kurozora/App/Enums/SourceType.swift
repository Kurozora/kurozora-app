//
//  SourceType.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import Foundation

enum SourceType: Int, CaseIterable {
	// MARK: - Cases
	case unknown = 1
	case original = 2
	case book = 3
	case pictureBook = 4
	case manga = 5
	case digitalManga = 6
	case fourKomaManga = 7
	case webManga = 8
	case novel = 9
	case lightNovel = 10
	case visualNovel = 11
	case game = 12
	case cardGame = 13
	case music = 14
	case radio = 15
	case webNovel = 16
	case mixedMedia = 17
	case other = 18

	// MARK: - Properties
	/// The name value of a source type.
	var name: String {
		switch self {
		case .unknown:
			return "Unknown"
		case .original:
			return "Original"
		case .book:
			return "Book"
		case .pictureBook:
			return "Picture Book"
		case .manga:
			return "Manga"
		case .digitalManga:
			return "Digital Manga"
		case .fourKomaManga:
			return "4-Koma Manga"
		case .webManga:
			return "Web Manga"
		case .novel:
			return "Novel"
		case .lightNovel:
			return "Light Novel"
		case .visualNovel:
			return "Visual Novel"
		case .game:
			return "Game"
		case .cardGame:
			return "Card Game"
		case .music:
			return "Music"
		case .radio:
			return "Radio"
		case .webNovel:
			return "Web novel"
		case .mixedMedia:
			return "Mixed media"
		case .other:
			return "Other"
		}
	}
}
