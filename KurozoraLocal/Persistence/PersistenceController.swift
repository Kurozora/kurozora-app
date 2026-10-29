//
//  PersistenceController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreData
import os.log

private nonisolated let persistenceLogger = Logger(subsystem: "app.kurozora.Kurozora", category: "PersistenceController")

/// Manages the Core Data stack for local persistence.
nonisolated final class PersistenceController: Sendable {
	// MARK: - Properties
	/// Returns the singleton `PersistenceController` instance.
	static let shared = PersistenceController()

	/// The load error codes that mean the store no longer matches the model.
	private static let incompatibleStoreErrorCodes: Set<CocoaError.Code> = [
		.persistentStoreIncompatibleVersionHash,
		.migration,
		.migrationMissingSourceModel,
		.migrationMissingMappingModel,
		.inferredMappingModel
	]

	/// The persistent container backing all local storage.
	let container: NSPersistentContainer

	/// The main-thread context for reads and lightweight writes.
	var viewContext: NSManagedObjectContext {
		return self.container.viewContext
	}

	/// Whether the store is open.
	var isStoreLoaded: Bool {
		return !self.container.persistentStoreCoordinator.persistentStores.isEmpty
	}

	/// The lock serializing store loads.
	private let loadLock = NSLock()

	// MARK: - Initializers
	private init() {
		let container = NSPersistentContainer(name: "KurozoraLocal")
		self.container = container
		self.container.viewContext.automaticallyMergesChangesFromParent = true
		self.container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

		self.loadStoreIfNeeded()
	}

	// MARK: - Functions
	/// Opens the store if it is not open yet.
	///
	/// - Returns: Whether the store is open.
	@discardableResult
	func loadStoreIfNeeded() -> Bool {
		self.loadLock.lock()
		defer { self.loadLock.unlock() }

		guard !self.isStoreLoaded else { return true }

		self.container.loadPersistentStores { storeDescription, error in
			guard let error else { return }

			guard let cocoaError = error as? CocoaError, Self.incompatibleStoreErrorCodes.contains(cocoaError.code), let storeURL = storeDescription.url else {
				persistenceLogger.error("Store load failed: \(error.localizedDescription)")
				return
			}

			// The store is a resyncable cache.
			do {
				try self.container.persistentStoreCoordinator.destroyPersistentStore(at: storeURL, type: .sqlite)
				_ = try self.container.persistentStoreCoordinator.addPersistentStore(type: .sqlite, at: storeURL, options: storeDescription.options)
				persistenceLogger.notice("Store was incompatible and has been rebuilt. The next sync repopulates it.")
			} catch {
				persistenceLogger.error("Store recovery failed: \(error.localizedDescription)")
			}
		}

		return self.isStoreLoaded
	}

	/// Saves the given context if it has uncommitted changes.
	///
	/// - Parameter context: The managed object context to save.
	func save(_ context: NSManagedObjectContext) {
		guard context.hasChanges, self.loadStoreIfNeeded() else { return }
		do {
			try context.save()
		} catch {
			persistenceLogger.error("Save failed: \(error.localizedDescription)")
		}
	}
}
