//
//  MediaItemV2.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/09/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import Foundation

protocol MediaRepresentableV2 {
	var url: URL { get }
	var type: MediaTypeV2 { get }
	var title: String? { get }
	var description: String? { get }
	var author: String? { get }
	var provider: String? { get }
	var embedHTML: String? { get }

	// Optional info for viewer
	var extraInfo: [String: Any]? { get }
}

struct MediaItemV2: MediaRepresentableV2 {
	let url: URL
	let type: MediaTypeV2
	let title: String?
	let description: String?
	let author: String?
	let provider: String?
	let embedHTML: String?

	let extraInfo: [String: Any]?
}

enum MediaTypeV2 {
	case image
	case video
	case audio
	case pdf
	case link
	case embed
}
