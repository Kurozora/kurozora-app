//
//  DebugConsoleModifier.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 01/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

#if DEBUG
import PulseUI
import SwiftUI

// MARK: - Button
struct DebugConsoleButton: View {
	// MARK: - Properties
	@State private var isPresented = false

	// MARK: - Body
	var body: some View {
		Button {
			self.isPresented = true
		} label: {
			Image(systemName: "ant.fill")
		}
		.sheet(isPresented: self.$isPresented) {
			NavigationStack {
				ConsoleView()
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
struct DebugConsoleModifier: ViewModifier {
	func body(content: Content) -> some View {
		content
			.overlay(alignment: .bottomTrailing) {
				DebugConsoleButton()
					.font(.caption)
					.buttonStyle(.plain)
					.padding(8)
					.background(.ultraThinMaterial, in: Circle())
					.padding(4)
			}
	}
}

extension View {
	func debugConsole() -> some View {
		modifier(DebugConsoleModifier())
	}
}
#endif
