//
//  KKServices.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 06/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KeychainAccess

/// `KKServices` is the object that serves as a provider for [KurozoraKit](x-source-tag://KurozoraKit) services.
///
/// `KKServices` is used together with [KurozoraKit](x-source-tag://KurozoraKit) to provide extra functionality such as storing sensetive information in `Keychain` and showing success/error alerts.
/// For further control over the information saved in `Keychain`, you can provide your own `Keychain` object with your specified properties.
///
/// - Tag: KKServices
public class KKServices {
	/// Provides access to the `Keychain` service used by [KurozoraKit](x-source-tag://KurozoraKit).
	internal var _keychainDefaults: Keychain!
	/// Provides access to the `Keychain` service used by [KurozoraKit](x-source-tag://KurozoraKit).
	var keychainDefaults: Keychain {
		get {
			return _keychainDefaults
		}
	}

	/// Show or hide expressive success/error alerts to users.
	///
	/// If set to `true`, whenever the API request encounters an error or receives an informational message, an expressive alert is shown to the users.
	var showAlerts: Bool = true

	// MARK: - Initializers
	/// [KKServices](x-source-tag://KKServices) is a root object, that serves as a provider for KurozoraKit services.
	///
	/// - Parameter keychain: The main `Keychain` service used for managing secrets.
	/// - Parameter showAlerts: Show or hide expressive success/error alerts to users.
	public init(keychain: Keychain = Keychain(), showAlerts: Bool = true) {
		self._keychainDefaults = keychain
		self.showAlerts = showAlerts
	}

	// MARK: - Functions
	/// Sets the `showAlert` property with the given boolean value.
	///
	/// - Parameter bool: A boolean value indicating whether to show or hide expressive success/error alerts.
	///
	/// - Returns: Reference to `self`.
	func showAlerts(_ bool: Bool) -> Self {
		self.showAlerts = bool
		return self
	}

	/// Sets the `keychainDefaults` property with the given `Keychain` object.
	///
	/// - Parameter keychain: An object representing the desired Keychain properties to use.
	///
	/// - Returns: Reference to `self`.
	func keychainDefaults(_ keychain: Keychain) -> Self {
		self._keychainDefaults = keychain
		return self
	}
}
