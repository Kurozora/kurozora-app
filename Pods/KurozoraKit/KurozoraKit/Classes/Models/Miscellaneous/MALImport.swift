//
//  MALImport.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 17/02/2020.
//

/// A root object that stores information about a single import request, such as the import's message status.
public struct MALImport: Codable {
	// MARK: - Properties
	/// The status message of an import request.
	public var message: String?
}

// MARK: - Behavior
extension MALImport {
	/// The set of available MAL import behavior types.
	public enum Behavior: Int {
		/// The import will overwrite any existing shows in the library.
		case overwrite = 0

		/// The import will merge any existing shows in the library with the import.
		case merge = 1

		// MARK: - Properties
		/// The string value of a MALImport behavior type.
		var stringValue: String {
			switch self {
			case .overwrite:
				return "Overwrite"
			case .merge:
				return "Merge"
			}
		}
	}
}
