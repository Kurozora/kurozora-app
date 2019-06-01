//
//  RegisterViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import Alamofire
import SwiftyJSON
import SCLAlertView

class RegisterViewController: UIViewController {
	@IBOutlet weak var usernameTextField: UITextField! {
		didSet {
			usernameTextField.theme_textColor = KThemePicker.textColor.rawValue
			usernameTextField.theme_backgroundColor = KThemePicker.textFieldBackgroundColor.rawValue
		}
	}
	@IBOutlet weak var emailTextField: UITextField! {
		didSet {
			emailTextField.theme_textColor = KThemePicker.textColor.rawValue
			emailTextField.theme_backgroundColor = KThemePicker.textFieldBackgroundColor.rawValue
		}
	}
	@IBOutlet weak var passwordTextField: UITextField! {
		didSet {
			passwordTextField.theme_textColor = KThemePicker.textColor.rawValue
			passwordTextField.theme_backgroundColor = KThemePicker.textFieldBackgroundColor.rawValue
		}
	}
	@IBOutlet weak var registerButton: UIButton! {
		didSet {
			registerButton.theme_backgroundColor = KThemePicker.tintColor.rawValue
			registerButton.theme_setTitleColor(KThemePicker.tintedButtonTextColor.rawValue, forState: .normal)
		}
	}
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		registerButton.isEnabled = false
		registerButton.alpha = 0.5
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		usernameTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
		emailTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
		passwordTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
	}

    //MARK: - IBActions
    @IBAction func dismissPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func registerPressed(sender: AnyObject) {
        registerButton.isEnabled = false
		registerButton.alpha = 0.5
        
        let username = usernameTextField.trimmedText!
        let email = emailTextField.trimmedText!
        let password = passwordTextField.text!
        let image = profileImage.image
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let parameters:Parameters = [
            "username": username,
            "email": email,
            "password": password
        ]
        
        let endpoint = GlobalVariables().baseUrlString + "users"
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            if image != nil {
                if let imageData = image?.jpegData(compressionQuality: 0.1) {
                    multipartFormData.append(imageData, withName: "profileImage", fileName: "ProfilePicture.png", mimeType: "image/png")
                }
            }
            
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
            }
        }, to: endpoint, method: .post, headers: headers) { response in
            switch response {
            case .success(let upload, _,  _):
            upload.responseJSON { response in
                switch response.result {
                case .success:
                if response.result.value != nil {
                    let swiftyJsonVar = JSON(response.result.value!)

                    let responseSuccess = swiftyJsonVar["success"]
                    let errorMessage = swiftyJsonVar["error_message"].stringValue

                    if responseSuccess.boolValue {
                        let alertController = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
						alertController.showSuccess("Hooray!", subTitle: "Account created successfully! Please check your email for confirmation!")
						alertController.addButton("Done", action: {
							self.dismiss(animated: true, completion: nil)
						})
                    }else{
						self.view.endEditing(true)
                        SCLAlertView().showError("Error registering", subTitle: errorMessage)
                    }
                }
                case .failure:
					self.view.endEditing(true)
                    SCLAlertView().showError("Error registering", subTitle: "There was an error while creating your account. If this error persists, check out our Twitter account @KurozoraApp for more information!" )
                }
            }
            case .failure:
				self.view.endEditing(true)
				 SCLAlertView().showError("Error registering", subTitle: "There was an error while creating your account. If this error persists, check out our Twitter account @KurozoraApp for more information!" )
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

	// MARK: - Functions
    // Open the camera
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            
            self.present(imagePicker, animated: true, completion: nil)
        }
        else{
            let alert  = UIAlertController(title: "⚠️ Warning ⚠️", message: "You don't seem to have a camera 😢", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // Choose image from camera roll
    func openPhotoLibrary() {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        self.present(imagePicker, animated: true, completion: nil)
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
        if let editedImage = info[.editedImage] as? UIImage{
            self.profileImage.image = editedImage
        }
        
        // Dismiss the UIImagePicker after selection
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
