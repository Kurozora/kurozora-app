//
//  SearchIntent.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/02/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import Foundation
import AppIntents
import KurozoraKit

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct SearchIntent: AppIntent, CustomIntentMigratedAppIntent, PredictableIntent {
    static let intentClassName = "SearchIntentIntent"

    static var title: LocalizedStringResource = "Find on Kurozora"
    static var description = IntentDescription("Search for anime, manga, games, and more in Kurozora")

    @Parameter(title: "Search in", default: .kurozora)
    var scope: KKSearchScopeAppEnum

    @Parameter(title: "For", default: .shows)
    var type: KKSearchTypeAppEnum

    @Parameter(title: "Title")
    var title: String

	/// Launch your app when the system triggers this intent.
	static let openAppWhenRun: Bool = true

    static var parameterSummary: some ParameterSummary {
        Summary("Find \(\.$title) on Kurozora") {
            \.$scope
            \.$type
        }
    }

    static var predictionConfiguration: some IntentPredictionConfiguration {
        IntentPrediction(parameters: (\.$title, \.$scope, \.$type)) { title, scope, _ in
            DisplayRepresentation(
                title: "Find \(title) in \(scope)",
                subtitle: "Search for \(title) in \(scope)"
            )
        }
        IntentPrediction(parameters: (\.$title)) { title in
            DisplayRepresentation(
                title: "Find \(title)",
                subtitle: "Search for \(title) in Kurozora"
            )
        }
    }

	func perform() async throws -> some IntentResult {
		guard let url = URL(string: "kurozora://search?q=\(self.title)&scope=\(self.scope.kkSearchScopeValue.rawValue)&type=\(self.type.kkSearchTypeValue.rawValue)"),
			  let scene = await UIApplication.sharedKeyWindow?.windowScene?.session.scene
		else {
			return .result()
		}
		KurozoraDelegate.shared.schemeHandler(scene, open: url)
		return .result()
	}
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
fileprivate extension IntentDialog {
    static func titleParameterPrompt(title: String) -> Self {
        "Searching for \(title) in Kurozora..."
    }
    static func titleParameterDisambiguationIntro(count: Int, title: String) -> Self {
        "There are \(count) titles matching ‘\(title)’."
    }
    static func titleParameterConfirmation(title: String) -> Self {
        "Just to confirm, you wanted ‘\(title)’?"
    }
}
