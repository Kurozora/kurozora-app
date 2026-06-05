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
			return L10n.unknown
		case .original:
			return L10n.original
		case .book:
			return L10n.book
		case .pictureBook:
			return L10n.pictureBook
		case .manga:
			return L10n.manga
		case .digitalManga:
			return L10n.digitalManga
		case .fourKomaManga:
			return L10n.fourKomaManga
		case .webManga:
			return L10n.webManga
		case .novel:
			return L10n.novel
		case .lightNovel:
			return L10n.lightNovel
		case .visualNovel:
			return L10n.visualNovel
		case .game:
			return L10n.game
		case .cardGame:
			return L10n.cardGame
		case .music:
			return L10n.music
		case .radio:
			return L10n.radio
		case .webNovel:
			return L10n.webNovel
		case .mixedMedia:
			return L10n.mixedMedia
		case .other:
			return L10n.other
		}
	}
}
