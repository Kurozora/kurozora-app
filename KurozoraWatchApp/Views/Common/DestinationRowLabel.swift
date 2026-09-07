//
//  DestinationRowLabel.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 08/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import SwiftUI

/// The tinted symbol and title of a row on the root list.
struct DestinationRowLabel: View {
	// MARK: - Properties
	let title: String

	let symbolName: String

	@Environment(WatchTheme.self) private var theme

	// MARK: - Initializers
	/// Labels a row with the given title and symbol.
	///
	/// - Parameters:
	///    - title: The row title.
	///    - symbolName: The SF Symbol shown before the title.
	init(title: String, symbolName: String) {
		self.title = title
		self.symbolName = symbolName
	}

	/// Labels a row that pushes the given destination.
	///
	/// - Parameter destination: The destination the row opens.
	init(destination: WatchDestination) {
		self.init(title: destination.title, symbolName: destination.symbolName)
	}

	// MARK: - Body
	var body: some View {
		Label {
			Text(self.title)
		} icon: {
			Image(systemName: self.symbolName)
				.foregroundStyle(self.theme.tint)
		}
	}
}
