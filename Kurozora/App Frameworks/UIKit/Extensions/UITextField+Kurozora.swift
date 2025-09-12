//
//  TextType.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/09/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit

extension UITextField {
	/// UITextField text type.
	///
	/// - emailAddress: UITextField is used to enter email addresses.
	/// - password: UITextField is used to enter passwords.
	/// - generic: UITextField is used to enter generic text.
	enum TextType {
		/// UITextField is used to enter email addresses.
		case emailAddress

		/// UITextField is used to enter usernames.
		case username

		/// UITextField is used to enter passwords.
		case password

		/// UITextField is used to enter generic text.
		case generic
	}

	/// The text type of the UITextField.
	var textType: TextType {
		get {
			if keyboardType == .emailAddress {
				return .emailAddress
			} else if isSecureTextEntry {
				return .password
			}
			return .generic
		}
		set {
			switch newValue {
			case .emailAddress:
				keyboardType = .emailAddress
				autocorrectionType = .no
				autocapitalizationType = .none
				isSecureTextEntry = false
				placeholder = "Email Address"
			case .username:
				keyboardType = .default
				autocorrectionType = .no
				autocapitalizationType = .none
				isSecureTextEntry = false
				placeholder = "Username"
			case .password:
				keyboardType = .asciiCapable
				autocorrectionType = .no
				autocapitalizationType = .none
				isSecureTextEntry = true
				placeholder = "Password"
			case .generic:
				isSecureTextEntry = false
			}
		}
	}
}
