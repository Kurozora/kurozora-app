//
//  ReviewTextEditorModels.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/07/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

enum ReviewTextEditor {
	enum Configure {
		struct Request { }

		struct Response {
			let rating: Double
			let review: String?
		}

		struct ViewModel {
			let rating: Double
			let review: String?
		}
	}

	enum UnsavedChanges {
		struct Request {}

		struct Response {
			let isEdited: Bool
		}

		struct ViewModel {
			let isEdited: Bool
		}
	}

	enum SaveRating {
		struct Request {
			let rating: Double
		}

		struct Response {}

		struct ViewModel {}
	}

	enum SaveReview {
		struct Request {
			let review: String
		}

		struct Response {}

		struct ViewModel {}
	}

	enum Cancel {
		struct Request {
			let forceCancel: Bool
		}

		struct Response {
			let forceCancel: Bool
			let hasChanges: Bool
		}

		struct ViewModel {
			let forceCancel: Bool
			let hasChanges: Bool
		}
	}

	enum ConfirmCancel {
		struct Request {
			let showingSend: Bool
		}

		struct Response {
			let showingSend: Bool
		}

		struct ViewModel {
			let showingSend: Bool
		}
	}

	enum Submit {
		struct Request {}

		struct Response {}

		struct ViewModel {}
	}

	enum Alert {
		struct Request {}

		struct Response {
			let message: String?
		}

		struct ViewModel {
			let message: String?
		}
	}
}

// MARK: - Models
extension ReviewTextEditor {
	enum Kind {
		case episode(_ episode: Episode)
		case game(_ game: Game)
		case literature(_ literature: Literature)
		case show(_ show: Show)
		case song(_ song: Song)
		case studio(_ studio: Studio)
	}
}
