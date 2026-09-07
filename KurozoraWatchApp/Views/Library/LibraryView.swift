//
//  LibraryView.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 31/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import SwiftUI

/// Lists the library statuses of one kind with the number of entries each holds.
struct LibraryView: View {
	// MARK: - Properties
	let viewModel: LibraryViewModel

	@Environment(WatchTheme.self) private var theme

	@State private var isChoosingKind = false

	// MARK: - Body
	var body: some View {
		List(LibraryStatus.all, id: \.rawValue) { status in
			NavigationLink {
				LibraryStatusListView(status: status, viewModel: self.viewModel)
			} label: {
				HStack {
					Text(status.watchTitle(for: self.viewModel.selectedKind))

					Spacer()

					Text(self.viewModel.items(for: status).count, format: .number)
						.foregroundStyle(.secondary)
				}
			}
		}
		.themedNavigationTitle(WatchDestination.library.title)
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button {
					self.isChoosingKind = true
				} label: {
					Image(systemName: self.viewModel.selectedKind.symbolName)
						.foregroundStyle(self.theme.tintedButtonText)
				}
				.accessibilityLabel(self.viewModel.selectedKind.watchTitle)
			}
		}
		.confirmationDialog(L10n.library, isPresented: self.$isChoosingKind) {
			ForEach(LibraryKind.allCases, id: \.rawValue) { kind in
				Button(kind.watchTitle) {
					self.viewModel.selectKind(kind)
				}
			}
		}
		.task {
			self.viewModel.start()
		}
	}
}
