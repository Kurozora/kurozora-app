//
//  LaunchAppControl.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/06/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import SwiftUI
import WidgetKit

@available(iOS 18.0, *)
struct LaunchAppControl: ControlWidget {
	static let kind: String = "app.kurozora.tracker.launchAppControl"

	var body: some ControlWidgetConfiguration {
		AppIntentControlConfiguration(
			kind: Self.kind,
			intent: LaunchAppIntent.self
		) { configuration in
			ControlWidgetButton(action: configuration) {
				Image("Symbols/kurozora")

				Text(configuration.target.name)
					.frame(maxWidth: .infinity)
			}
		}
		.displayName("Kurozora")
		.description("Quikly launch the Kurozora app")
	}
}
