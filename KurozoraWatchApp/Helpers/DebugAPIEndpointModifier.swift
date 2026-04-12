//
//  DebugAPIEndpointModifier.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 11/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

#if DEBUG
import KurozoraKit
import SwiftUI

// MARK: - Button
struct DebugAPIEndpointButton: View {
	// MARK: - Properties
	@State private var isPresented = false
	@State private var selectedEndpoint = KService.apiEndpoint.baseURL

	// MARK: - Body
	var body: some View {
		Button {
			self.isPresented = true
		} label: {
			Image(systemName: "globe")
		}
		.sheet(isPresented: self.$isPresented) {
			NavigationStack {
				List {
					ForEach(Array(APIEndpoints.enumerated()), id: \.offset) { _, endpoint in
						Button {
							self.selectedEndpoint = endpoint.baseURL
							KService.apiEndpoint(endpoint)
							self.isPresented = false
						} label: {
							HStack {
								Text(endpoint.baseURL)
									.font(.caption2)
								Spacer()
								if endpoint.baseURL == self.selectedEndpoint {
									Image(systemName: "checkmark")
										.foregroundStyle(.tint)
								}
							}
						}
					}
				}
				.navigationTitle("API Endpoint")
				.toolbar {
					ToolbarItem(placement: .cancellationAction) {
						Button("Close") {
							self.isPresented = false
						}
					}
				}
			}
		}
	}
}

// MARK: - ViewModifier
struct DebugAPIEndpointModifier: ViewModifier {
	func body(content: Content) -> some View {
		content
			.overlay(alignment: .bottomLeading) {
				DebugAPIEndpointButton()
					.font(.caption)
					.buttonStyle(.plain)
					.padding(8)
					.background(.ultraThinMaterial, in: Circle())
					.padding(4)
			}
	}
}

extension View {
	func debugAPIEndpoint() -> some View {
		modifier(DebugAPIEndpointModifier())
	}
}
#endif
