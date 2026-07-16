//
//  PersistenceController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreData
import os.log

private let persistenceLogger = Logger(subsystem: "app.kurozora.Kurozora", category: "PersistenceController")

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
		let container = NSPersistentContainer(name: "KurozoraLocal")
		container.loadPersistentStores { storeDescription, error in
			guard error != nil else { return }

			// The store is a resyncable cache; rebuild it instead of blocking on migration.
			guard let storeURL = storeDescription.url else { return }
			do {
				try container.persistentStoreCoordinator.destroyPersistentStore(at: storeURL, type: .sqlite)
				_ = try container.persistentStoreCoordinator.addPersistentStore(type: .sqlite, at: storeURL)
				persistenceLogger.notice("Store was incompatible and has been rebuilt; the next sync repopulates it.")
			} catch {
				persistenceLogger.error("Store recovery failed: \(error.localizedDescription)")
			}
		}
		self.container = container
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
			persistenceLogger.error("Save failed: \(error.localizedDescription)")
		}
	}

	/// Runs the given block on a private background context and awaits its completion.
	///
	/// - Parameter block: The work to perform with a background `NSManagedObjectContext`.
	func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) async {
		await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
			self.container.performBackgroundTask { context in
				context.automaticallyMergesChangesFromParent = true
				block(context)
				continuation.resume()
			}
		}
	}
}
