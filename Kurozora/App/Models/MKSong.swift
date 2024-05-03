//
//  MKSong.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/05/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import MusicKit
import SwiftyJSON

struct MKLibrary: Codable, Identifiable {
	let id: String
	let href: String
	let type: String
}

struct MKLibraryResponse: Codable {
	let data: [MKLibrary]
}

struct MKSong: Equatable {
	// MARK: - Properties
	/// The song object.
	let song: MusicKit.Song

	/// Whether the song is in the user's library.
	let isInLibrary: Bool

	/// The relationship of the song.
	let relationship: Relationship?

	// MARK: - Equatable
	static func == (lhs: MKSong, rhs: MKSong) -> Bool {
		lhs.song == rhs.song
	}
}

extension MKSong {
	struct Relationship: Codable {
		let library: MKLibraryResponse?
	}
}
