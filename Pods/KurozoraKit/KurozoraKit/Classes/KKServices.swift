//
//  KKServices.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 06/04/2020.
//

import KeychainAccess

/// `KKServices` is the object that serves as a provider for ``KurozoraKit/KurozoraKit`` services.
///
/// `KKServices` is used together with ``KurozoraKit/KurozoraKit`` to provide extra functionality such as storing sensetive information in `Keychain` and showing success/error alerts.
/// For further control over the information saved in `Keychain`, you can provide your own `Keychain` object with your specified properties.
///
/// - Tag: KKServices
public class KKServices {
	/// Provides access to the `Keychain` service used by ``KurozoraKit/KurozoraKit``.
	internal var _keychainDefaults: Keychain!
	/// Provides access to the `Keychain` service used by ``KurozoraKit/KurozoraKit``.
	var keychainDefaults: Keychain {
		get {
			return _keychainDefaults
		}
	}

	// MARK: - Initializers
	/// ``KKServices`` is a root object, that serves as a provider for KurozoraKit services.
	///
	/// - Parameter keychain: The main `Keychain` service used for managing secrets.
	public init(keychain: Keychain = Keychain()) {
		self._keychainDefaults = keychain
	}

	// MARK: - Functions
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
