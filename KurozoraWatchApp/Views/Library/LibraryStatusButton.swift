//
//  LibraryStatusButton.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 07/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import SwiftUI

/// A tinted pill that shows the current library status and offers the rest on tap.
struct LibraryStatusButton: View {
	// MARK: - Properties
	let status: LibraryStatus?
	let onSelect: (LibraryStatus) -> Void
	let onRemove: () -> Void

	@Environment(WatchTheme.self) private var theme

	@State private var isChoosing = false

	// MARK: - Body
	var body: some View {
		Button {
			self.isChoosing = true
		} label: {
			HStack(spacing: 4) {
				Text(self.title)
					.font(.caption.bold())

				Image(systemName: "chevron.down")
					.font(.system(size: 9, weight: .bold))
			}
			.foregroundStyle(self.theme.tintedButtonText)
			.padding(.horizontal, 12)
			.padding(.vertical, 6)
			.background(self.theme.tint, in: Capsule())
		}
		.buttonStyle(.plain)
		.confirmationDialog(L10n.libraryStatus, isPresented: self.$isChoosing) {
			ForEach(LibraryStatus.all, id: \.rawValue) { status in
				Button(status.watchTitle) {
					self.onSelect(status)
				}
			}

			// The iOS menu only offers removal once the title is actually in the library.
			if self.isInLibrary {
				Button(L10n.removeFromLibrary, role: .destructive) {
					self.onRemove()
				}
			}
		}
	}

	// MARK: - Computed
	private var title: String {
		guard self.isInLibrary, let status = self.status else { return L10n.addToLibrary }

		return status.watchTitle
	}

	private var isInLibrary: Bool {
		switch self.status {
		case nil, .some(.none):
			return false
		default:
			return true
		}
	}
}
