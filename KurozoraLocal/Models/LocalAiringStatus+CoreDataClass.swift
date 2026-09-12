//
//  LocalAiringStatus+CoreDataClass.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreData

@objc(LocalAiringStatus)
class LocalAiringStatus: NSManagedObject {
	// MARK: - Functions
	/// Records the color of the given status.
	///
	/// - Parameters:
	///    - name: The name of the status.
	///    - colorHex: The color of the status as a hex string.
	///    - context: The managed object context.
	static func record(name: String, colorHex: String, in context: NSManagedObjectContext) {
		guard !name.isEmpty, !colorHex.isEmpty else { return }

		let status = Self.fetch(name: name, in: context) ?? LocalAiringStatus(context: context)
		guard status.name != name || status.colorHex != colorHex else { return }

		status.name = name
		status.colorHex = colorHex
	}

	/// Returns the status with the given name.
	///
	/// - Parameters:
	///    - name: The name of the status.
	///    - context: The managed object context.
	///
	/// - Returns: The matching `LocalAiringStatus`.
	static func fetch(name: String, in context: NSManagedObjectContext) -> LocalAiringStatus? {
		let request = LocalAiringStatus.fetchRequest()
		request.predicate = NSPredicate(format: "name == %@", name)
		request.fetchLimit = 1

		return (try? context.fetch(request))?.first
	}
}
