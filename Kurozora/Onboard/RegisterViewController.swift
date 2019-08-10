//
//  RegisterViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import SCLAlertView
import SwiftTheme

class RegisterViewController: UIViewController {
	@IBOutlet weak var profileView: UIView!
	@IBOutlet weak var usernameTextField: UITextField! {
		didSet {
			usernameTextField.theme_textColor = KThemePicker.textFieldTextColor.rawValue
			usernameTextField.theme_backgroundColor = KThemePicker.textFieldBackgroundColor.rawValue
			usernameTextField.theme_placeholderAttributes = ThemeDictionaryPicker(keyPath: KThemePicker.textFieldPlaceholderTextColor.stringValue) { value -> [NSAttributedString.Key : AnyObject]? in
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
			emailTextField.theme_placeholderAttributes = ThemeDictionaryPicker(keyPath: KThemePicker.textFieldPlaceholderTextColor.stringValue) { value -> [NSAttributedString.Key : AnyObject]? in
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
			passwordTextField.theme_placeholderAttributes = ThemeDictionaryPicker(keyPath: KThemePicker.textFieldPlaceholderTextColor.stringValue) { value -> [NSAttributedString.Key : AnyObject]? in
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
    @IBOutlet weak var profileImage: UIImageView!
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		self.profileView.applyShadow(cornerRadius: profileView.height / 2)

		registerButton.isEnabled = false
		registerButton.alpha = 0.5
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		usernameTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
		emailTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
		passwordTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
	}

	// MARK: - Functions
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

    //MARK: - IBActions
    @IBAction func registerPressed(sender: AnyObject) {
        registerButton.isEnabled = false
		registerButton.alpha = 0.5
        
        let username = usernameTextField.trimmedText!
        let email = emailTextField.trimmedText!
        let password = passwordTextField.text!
        let image = profileImage.image

		Service.shared.register(withUsername: username, email: email, password: password, profileImage: image) { (success) in
			if success {
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
    }

	// Image picker
    @IBAction func btnChooseImageOnClick(_ sender: UIButton) {
        let alert = UIAlertController(title: "Profile Picture 🖼", message: "Choose an awesome picture 😉", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take a photo 📷", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Choose from Photo Library 🏛", style: .default, handler: { _ in
            self.openPhotoLibrary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        // If you want work actionsheet on ipad then you have to use popoverPresentationController to present the actionsheet, otherwise app will crash in iPad
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
            case usernameTextField:
                emailTextField.becomeFirstResponder()
            case emailTextField:
                passwordTextField.becomeFirstResponder()
            case passwordTextField:
                registerPressed(sender: passwordTextField)
            default:
                usernameTextField.resignFirstResponder()
        }
        
        return true
    }
}

//MARK: - UIImagePickerControllerDelegate
extension RegisterViewController:  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            self.profileImage.image = editedImage
        }
        
        // Dismiss the UIImagePicker after selection
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
