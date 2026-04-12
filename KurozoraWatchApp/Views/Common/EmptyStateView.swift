//
//  EmptyStateView.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 31/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import SwiftUI

struct EmptyStateView: View {
	// MARK: - Properties
	let systemImage: String
	let message: String

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
		}
		.padding()
	}
}
