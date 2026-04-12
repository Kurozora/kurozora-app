//
//  KurozoraWatchApp.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 31/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import SwiftUI
#if DEBUG
import Pulse
#endif

@main
struct KurozoraWatchApp: App {
	// MARK: - Properties
	@State private var authManager = AuthenticationManager()
	@State private var hasRestoredSession = false
	@Environment(\.scenePhase) private var scenePhase

	// MARK: - Body
	var body: some Scene {
		WindowGroup {
			Group {
				if self.authManager.isLoading {
					LoadingView()
				} else if self.authManager.isSignedIn {
					ContentView()
				} else {
					SignedOutView {
						Task { await self.authManager.restoreSession() }
					}
				}
			}
			.environment(self.authManager)
			.task {
				WatchSessionManager.shared.activate(authManager: self.authManager)
				await self.authManager.restoreSession()
				self.hasRestoredSession = true
			}
			.onChange(of: self.scenePhase) { _, newPhase in
				if newPhase == .active, self.hasRestoredSession {
					Task { await self.authManager.revalidateSessionIfNeeded() }
				}
			}
		}
	}
}
