//
//  RegisterViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SCLAlertView
import SwiftTheme

class RegisterViewController: UIViewController {
	@IBOutlet weak var profileImageView: UIImageView!
	@IBOutlet weak var usernameTextField: UITextField! {
		didSet {
			usernameTextField.theme_textColor = KThemePicker.textFieldTextColor.rawValue
			usernameTextField.theme_backgroundColor = KThemePicker.textFieldBackgroundColor.rawValue
			usernameTextField.theme_placeholderAttributes = ThemeStringAttributesPicker(keyPath: KThemePicker.textFieldPlaceholderTextColor.stringValue) { value -> [NSAttributedString.Key: Any]? in
				guard let rgba = value as? String else { return nil }
				let color = UIColor(rgba: rgba)
				let titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]

				return titleTextAttributes
			}
		}
	}
	@IBOutlet weak var emailTextField: UITextField! {
		didSet {
			emailTextField.theme_textColor = KThemePicker.textFieldTextColor.rawValue
			emailTextField.theme_backgroundColor = KThemePicker.textFieldBackgroundColor.rawValue
			emailTextField.theme_placeholderAttributes = ThemeStringAttributesPicker(keyPath: KThemePicker.textFieldPlaceholderTextColor.stringValue) { value -> [NSAttributedString.Key: Any]? in
				guard let rgba = value as? String else { return nil }
				let color = UIColor(rgba: rgba)
				let titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]

				return titleTextAttributes
			}
		}
	}
	@IBOutlet weak var passwordTextField: UITextField! {
		didSet {
			passwordTextField.theme_textColor = KThemePicker.textFieldTextColor.rawValue
			passwordTextField.theme_backgroundColor = KThemePicker.textFieldBackgroundColor.rawValue
			passwordTextField.theme_placeholderAttributes = ThemeStringAttributesPicker(keyPath: KThemePicker.textFieldPlaceholderTextColor.stringValue) { value -> [NSAttributedString.Key: Any]? in
				guard let rgba = value as? String else { return nil }
				let color = UIColor(rgba: rgba)
				let titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]

				return titleTextAttributes
			}
		}
	}
	@IBOutlet weak var registerButton: UIButton! {
		didSet {
			registerButton.theme_backgroundColor = KThemePicker.tintColor.rawValue
			registerButton.theme_setTitleColor(KThemePicker.tintedButtonTextColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var selectButton: UIButton! {
		didSet {
			selectButton.theme_setTitleColor(KThemePicker.tintedButtonTextColor.rawValue, forState: .normal)
		}
	}

	lazy var imagePicker = UIImagePickerController()

	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		// Apply shadow
		self.profileImageView.applyShadow(cornerRadius: profileImageView.bounds.height / 2)

		// Disable register button
		registerButton.isEnabled = false
		registerButton.alpha = 0.5

		// Setup textfields
		usernameTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
		emailTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
		passwordTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
	}

	// MARK: - Functions
	/**
		Instantiates and returns a view controller from the relevant storyboard.

		- Returns: a view controller from the relevant storyboard.
	*/
	static func instantiateFromStoryboard() -> UIViewController? {
		let storyboard = UIStoryboard(name: "login", bundle: nil)
		return storyboard.instantiateViewController(withIdentifier: "RegisterViewController")
	}

	/// Open the camera if the device has one, otherwise show a warning.
	func openCamera() {
		if UIImagePickerController.isSourceTypeAvailable(.camera) {
			imagePicker.sourceType = .camera
			imagePicker.allowsEditing = true
			imagePicker.delegate = self
			self.present(imagePicker, animated: true, completion: nil)
		} else {
			SCLAlertView().showWarning("Well, this is awkward.", subTitle: "You don't seem to have a camera 😓")
		}
	}

	/// Open the Photo Library so the user can choose an image.
	func openPhotoLibrary() {
		imagePicker.sourceType = .photoLibrary
		imagePicker.allowsEditing = true
		imagePicker.delegate = self
		self.present(imagePicker, animated: true, completion: nil)
	}

	/// Registers the user using the information filled by the user.
	func registerUser() {
		let username = usernameTextField.trimmedText
		let email = emailTextField.trimmedText
		let password = passwordTextField.text
		let image = profileImageView.image

		Service.shared.register(withUsername: username, email: email, password: password, profileImage: image) { (success) in
			if success {
				let alertController = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
				alertController.showSuccess("Hooray!", subTitle: "Account created successfully! Please check your email for confirmation!")
				alertController.addButton("Done", action: {
					self.navigationController?.popViewController(animated: true)
					self.dismiss(animated: true, completion: nil)
				})
			}
		}
	}

	//MARK: - IBActions
	@IBAction func registerButtonPressed(_ sender: UIButton) {
		registerButton.isEnabled = false
		registerButton.alpha = 0.5
		registerUser()
	}

	@IBAction func chooseImageButtonPressed(_ sender: UIButton) {
		let alert = UIAlertController(title: "Profile Photo", message: "Choose an awesome photo 😉", preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: "Take a photo 📷", style: .default, handler: { _ in
			self.openCamera()
		}))

		alert.addAction(UIAlertAction(title: "Choose from Photo Library 🏛", style: .default, handler: { _ in
			self.openPhotoLibrary()
		}))

		alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

		switch UIDevice.current.userInterfaceIdiom {
		case .pad:
			alert.popoverPresentationController?.sourceView = sender
			alert.popoverPresentationController?.sourceRect = sender.bounds
			alert.popoverPresentationController?.permittedArrowDirections = .up
		default:
			break
		}

		self.present(alert, animated: true, completion: nil)
	}
}

// MARK: - UITextFieldDelegate
extension RegisterViewController: UITextFieldDelegate {
	@objc func editingChanged(_ textField: UITextField) {
		if textField.text?.count == 1 {
			if textField.text?.first == " " {
				textField.text = ""
				return
			}
		}

		guard let username = usernameTextField.text, !username.isEmpty, let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty else {
			registerButton.isEnabled = false
			registerButton.alpha = 0.5
			return
		}

		registerButton.isEnabled = true
		registerButton.alpha = 1.0
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		switch textField {
		case usernameTextField: emailTextField.becomeFirstResponder()
		case emailTextField: passwordTextField.becomeFirstResponder()
		case passwordTextField: registerUser()
		default: usernameTextField.resignFirstResponder()
		}

		return true
	}
}

//MARK: - UIImagePickerControllerDelegate
extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		if let editedImage = info[.editedImage] as? UIImage {
			self.profileImageView.image = editedImage
		}

		// Dismiss the UIImagePicker after selection
		picker.dismiss(animated: true, completion: nil)
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}
}
