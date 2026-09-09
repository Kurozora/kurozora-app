//
//  LibrarySyncScenarioReport.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

#if DEBUG
import Foundation
import os.log

private nonisolated let reportLogger = Logger(subsystem: "app.kurozora.Kurozora", category: "LibrarySyncScenario")

struct LibrarySyncScenarioReport {
	// MARK: - Types
	/// One step of a scenario.
	struct Step {
		/// The step's name.
		let name: String

		/// Whether the step passed.
		let passed: Bool

		/// The step's detail.
		let detail: String
	}

	// MARK: - Properties
	/// The scenario the report belongs to.
	let scenario: String

	/// The recorded steps.
	private(set) var steps: [Step] = []

	/// Whether every step passed.
	var passed: Bool {
		return self.steps.allSatisfy(\.passed)
	}

	/// The tally of passed steps.
	var summary: String {
		let passedCount = self.steps.filter(\.passed).count
		return "\(passedCount)/\(self.steps.count) steps passed"
	}

	/// The steps as alert text.
	var stepLines: String {
		return self.steps
			.map { "\($0.passed ? "PASS" : "FAIL") \($0.name): \($0.detail)" }
			.joined(separator: "\n")
	}

	// MARK: - Initializers
	init(scenario: String) {
		self.scenario = scenario
	}

	// MARK: - Functions
	/// Records a step.
	///
	/// - Parameters:
	///    - name: The step's name.
	///    - passed: Whether the step passed.
	///    - detail: The step's detail.
	mutating func record(_ name: String, passed: Bool, detail: String) {
		self.steps.append(Step(name: name, passed: passed, detail: detail))

		let scenario = self.scenario
		let result = passed ? "PASS" : "FAIL"
		reportLogger.notice("STEP \(scenario, privacy: .public) \(name, privacy: .public) \(result, privacy: .public) \(detail, privacy: .public)")
	}
}
#endif
