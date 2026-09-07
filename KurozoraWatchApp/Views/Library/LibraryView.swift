//
//  LibraryView.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 31/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import SwiftUI

/// Lists the library statuses with the number of shows each holds.
struct LibraryView: View {
	// MARK: - Properties
	let viewModel: LibraryViewModel

	// MARK: - Body
	var body: some View {
		List(LibraryStatus.all, id: \.rawValue) { status in
			NavigationLink {
				LibraryStatusListView(status: status, viewModel: self.viewModel)
			} label: {
				HStack {
					Text(status.watchTitle)

					Spacer()

					Text(self.viewModel.items(for: status).count, format: .number)
						.foregroundStyle(.secondary)
				}
			}
		}
		.themedNavigationTitle(WatchDestination.library.title)
		.task {
			self.viewModel.start()
		}
	}
}
