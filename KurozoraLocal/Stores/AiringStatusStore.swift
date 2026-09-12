//
//  AiringStatusStore.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreData
import Foundation

/// Manages the colors the server assigns to airing and publishing statuses.
@MainActor
final class AiringStatusStore {
	// MARK: - Properties
	/// Returns the singleton `AiringStatusStore` instance.
	static let shared = AiringStatusStore()

	private var viewContext: NSManagedObjectContext {
		return PersistenceController.shared.viewContext
	}

	/// The recorded color of every status name.
	private var colorHexes: [String: String] = [:]

	private var hasLoaded = false

	// MARK: - Initializers
	private init() {}

	// MARK: - Functions
	/// Returns the color of the status with the given name.
	///
	/// - Parameter name: The name of the status.
	///
	/// - Returns: The color as a hex string.
	func colorHex(forStatusName name: String?) -> String? {
		guard let name = name, !name.isEmpty else { return nil }

		self.loadIfNeeded()

		return self.colorHexes[name]
	}

	/// Records the color of the given status.
	///
	/// - Parameters:
	///    - name: The name of the status.
	///    - colorHex: The color of the status as a hex string.
	func record(name: String, colorHex: String) {
		self.loadIfNeeded()
		guard self.colorHexes[name] != colorHex else { return }

		self.colorHexes[name] = colorHex

		LocalAiringStatus.record(name: name, colorHex: colorHex, in: self.viewContext)
		PersistenceController.shared.save(self.viewContext)
	}

	/// Reads the recorded colors into memory on first use.
	private func loadIfNeeded() {
		guard !self.hasLoaded else { return }
		self.hasLoaded = true

		let request = LocalAiringStatus.fetchRequest()
		let statuses = (try? self.viewContext.fetch(request)) ?? []

		for status in statuses {
			self.colorHexes[status.name] = status.colorHex
		}
	}
}
