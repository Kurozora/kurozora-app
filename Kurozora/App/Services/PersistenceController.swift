//
//  PersistenceController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreData

/// Manages the Core Data stack for local persistence.
///
/// Initialize early in the app lifecycle via `PersistenceController.shared`.
final class PersistenceController {
	// MARK: - Properties
	/// Returns the singleton `PersistenceController` instance.
	static let shared = PersistenceController()

	/// The persistent container backing all local storage.
	let container: NSPersistentContainer

	/// The main-thread context for reads and lightweight writes.
	var viewContext: NSManagedObjectContext {
		return self.container.viewContext
	}

	// MARK: - Initializers
	private init() {
		self.container = NSPersistentContainer(name: "KurozoraLocal")
		self.container.loadPersistentStores { _, error in
			if let error = error {
				print("----- [PersistenceController] Failed to load store:", error.localizedDescription)
			}
		}
		self.container.viewContext.automaticallyMergesChangesFromParent = true
		self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
	}

	// MARK: - Functions
	/// Saves the given context if it has uncommitted changes.
	///
	/// - Parameter context: The managed object context to save.
	func save(_ context: NSManagedObjectContext) {
		guard context.hasChanges else { return }
		do {
			try context.save()
		} catch {
			print("----- [PersistenceController] Save failed:", error.localizedDescription)
		}
	}
}
