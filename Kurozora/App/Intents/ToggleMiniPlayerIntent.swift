//
//  ToggleMiniPlayerIntent.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import AppIntents
import UIKit

/// Opens or closes the MiniPlayer.
///
/// The intent surfaces in Shortcuts and Spotlight, where a keyboard shortcut can be attached.
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
struct ToggleMiniPlayerIntent: AppIntent {
	static let title: LocalizedStringResource = "Toggle MiniPlayer"
	static let description = IntentDescription("Opens the MiniPlayer, or closes it when it is already open.")

	// The MiniPlayer needs a foreground scene to attach to.
	static let openAppWhenRun: Bool = true

	@MainActor
	func perform() async throws -> some IntentResult {
		guard
			UIApplication.shared.supportsMultipleScenes,
			let appDelegate = UIApplication.shared.delegate as? AppDelegate
		else {
			return .result()
		}

		appDelegate.handleMiniPlayer(self as AnyObject)

		return .result()
	}
}
