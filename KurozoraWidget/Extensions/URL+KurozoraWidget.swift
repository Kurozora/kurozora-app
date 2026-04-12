//
//  URL+KurozoraWidget.swift
//  KurozoraWidgetExtension
//
//  Created by Khoren Katklian on 13/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit

extension URL {
	private static let deeplinkScheme = "kurozora"

	private static func deeplink(host: String, path: String? = nil) -> URL {
		var components = URLComponents()
		components.scheme = self.deeplinkScheme
		components.host = host
		if let path = path {
			components.path = "/\(path)"
		}
		guard let url = components.url else {
			preconditionFailure("Invalid deeplink: \(host)/\(path ?? "")")
		}
		return url
	}

	static var home: URL { self.deeplink(host: "home") }
	static var library: URL { self.deeplink(host: "library") }

	static func episode(_ id: EpisodeIdentity) -> URL {
		return self.deeplink(host: "episodes", path: "\(id.id)")
	}
}
