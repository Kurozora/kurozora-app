//
//  SignedOutView.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 31/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import SwiftUI

struct SignedOutView: View {
	// MARK: - Properties
	var onRetry: () -> Void

	// MARK: - Body
	var body: some View {
		VStack(spacing: 12) {
			Image(.kurozora)
				.resizable()
				.frame(width: 48, height: 48)
				.clipShape(RoundedRectangle(cornerRadius: 12))

			Text(L10n.kurozora)
				.font(.headline)

			Text(L10n.signInOnIPhone)
				.font(.caption)
				.foregroundStyle(.secondary)
				.multilineTextAlignment(.center)

			Button(action: onRetry) {
				Label(L10n.retry, systemImage: "arrow.clockwise")
			}
		}
		.padding()
		#if DEBUG
		.debugAPIEndpoint()
		.debugConsole()
		#endif
	}
}
