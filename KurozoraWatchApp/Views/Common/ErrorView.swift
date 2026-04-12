//
//  ErrorView.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 31/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import SwiftUI

struct ErrorView: View {
	// MARK: - Properties
	let systemImage: String
	let message: String
	var onRetry: (() -> Void)?

	// MARK: - Body
	var body: some View {
		VStack(spacing: 8) {
			Image(systemName: systemImage)
				.font(.title2)
				.foregroundStyle(.secondary)

			Text(message)
				.font(.caption)
				.foregroundStyle(.secondary)
				.multilineTextAlignment(.center)

			if let onRetry = onRetry {
				Button("Try Again", action: onRetry)
					.font(.caption)
			}
		}
		.padding()
	}
}
