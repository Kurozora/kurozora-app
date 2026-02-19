//
//  MediaItem.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/09/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import Foundation

protocol MediaRepresentable {
	var url: URL { get }
	var type: MediaType { get }
	var title: String? { get }
	var description: String? { get }
	var author: String? { get }
	var provider: String? { get }
	var embedHTML: String? { get }

	// Optional info for viewer
	var extraInfo: [String: Any]? { get }
}

struct MediaItem: MediaRepresentable {
	let url: URL
	let type: MediaType
	let title: String?
	let description: String?
	let author: String?
	let provider: String?
	let embedHTML: String?

	let extraInfo: [String: Any]?
}

enum MediaType {
	case image
	case video
	case audio
	case pdf
	case link
	case embed
}
