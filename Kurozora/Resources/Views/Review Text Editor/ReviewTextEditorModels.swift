//
//  ReviewTextEditorModels.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/07/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

enum ReviewTextEditor {
	enum Configure {
		struct Request {}

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
		case character(_ character: Character)
		case episode(_ episode: Episode)
		case game(_ game: Game)
		case literature(_ literature: Literature)
		case person(_ person: Person)
		case show(_ show: Show)
		case song(_ song: Song)
		case studio(_ studio: Studio)

		/// Delete the user's rating and review for the wrapped model.
		///
		/// - Returns: `true` when the deletion succeeds.
		func deleteRating() async throws(APIError) -> Bool {
			switch self {
			case .character(let character): return try await character.deleteRating()
			case .episode(let episode): return try await episode.deleteRating()
			case .game(let game): return try await game.deleteRating()
			case .literature(let literature): return try await literature.deleteRating()
			case .person(let person): return try await person.deleteRating()
			case .show(let show): return try await show.deleteRating()
			case .song(let song): return try await song.deleteRating()
			case .studio(let studio): return try await studio.deleteRating()
			}
		}
	}
}
