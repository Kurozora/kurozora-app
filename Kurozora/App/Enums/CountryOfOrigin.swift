//
//  CountryOfOrigin.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/10/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

enum CountryOfOrigin: Int, CaseIterable {
	// MARK: - Cases
	case china
	case japan
	case korea
	case unitedStates

	// MARK: - Properties
	/// The name of a Country of Origin.
	var name: String {
		switch self {
		case .china: return "China"
		case .japan: return "Japan"
		case .korea: return "Korea"
		case .unitedStates: return "United States"
		}
	}

	/// The value of a Country of Origin.
	var value: String {
		switch self {
		case .china: return "cn"
		case .japan: return "jp"
		case .korea: return "kr"
		case .unitedStates: return "us"
		}
	}
}
