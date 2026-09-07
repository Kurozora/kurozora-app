//
//  LocalOutboxOperation+CoreDataClass.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import CoreData
import KurozoraKit

@objc(LocalOutboxOperation)
class LocalOutboxOperation: NSManagedObject {
	// MARK: - Properties
	/// The library kind this operation targets.
	var kind: LibraryKind {
		get { LibraryKind(rawValue: Int(self.kindRaw)) ?? .shows }
		set { self.kindRaw = Int64(newValue.rawValue) }
	}

	/// The mutation type this operation represents.
	var operationType: LibraryOutboxOperationType {
		get { LibraryOutboxOperationType(rawValue: self.operationTypeRaw) ?? .setStatus }
		set { self.operationTypeRaw = newValue.rawValue }
	}

	/// The decoded mutation-specific payload.
	var decodedPayload: LibraryOutboxPayload? {
		guard let payload = self.payload else { return nil }
		return try? JSONDecoder().decode(LibraryOutboxPayload.self, from: payload)
	}

	/// The decoded offline-add seed snapshot.
	var decodedSeed: LibraryOutboxSeed? {
		guard let seed = self.seed else { return nil }
		return try? JSONDecoder().decode(LibraryOutboxSeed.self, from: seed)
	}
}
