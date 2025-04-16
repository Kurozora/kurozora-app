//
//  ImagePickerManager.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/04/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit
import ImagePlayground

@MainActor
protocol ImagePickerManagerDelegate: UIViewController, UINavigationControllerDelegate {
	func imagePickerManager(didFinishPicking imageURL: URL, image: UIImage)
	func imagePickerManagerDidRemovePickedImage()
}

protocol ImagePickerManagerDataSource: AnyObject {
	func imagePickerManagerTitle() -> String
	func imagePickerManagerSubtitle() -> String
}

@MainActor
final class ImagePickerManager: NSObject {
	// MARK: Properties
	/// The view controller that will present the image picker.
	private weak var delegate: ImagePickerManagerDelegate?

	/// The view controller that will provide data for the image picker.
	private weak var dataSource: ImagePickerManagerDataSource?

	/// The image picker controller used to select images.
	lazy var imagePicker = UIImagePickerController()

	// MARK: Initializers
	/// Initializes a new instance of `ImagePickerManager`.
	///
	/// - Parameter presenter: The view controller that will present the image picker.
	init(presenter: ImagePickerManagerDelegate & ImagePickerManagerDataSource) {
		self.delegate = presenter
		self.dataSource = presenter
		super.init()
	}

	// MARK: Functions
	/// Open the camera if the device has one, otherwise show a warning.
	private func openCamera() {
		if UIImagePickerController.isSourceTypeAvailable(.camera) {
			self.imagePicker.sourceType = .camera
			self.imagePicker.delegate = self
			self.delegate?.present(self.imagePicker, animated: true, completion: nil)
		} else {
			self.delegate?.presentAlertController(title: "Well, this is awkward.", message: "You don't seem to have a camera 😓")
		}
	}

	/// Open Photo Library, so the user can choose an image.
	private func openPhotoLibrary() {
		self.imagePicker.sourceType = .photoLibrary
		self.imagePicker.delegate = self
		self.delegate?.present(self.imagePicker, animated: true, completion: nil)
	}

	func chooseImageButtonPressed(_ sender: UIButton, showingRemoveAction: Bool) {
		let title = self.dataSource?.imagePickerManagerTitle()
		let subtitle = self.dataSource?.imagePickerManagerSubtitle()
		let actionSheetAlertController = UIAlertController.actionSheet(title: title, message: subtitle) { [weak self] actionSheetAlertController in
			guard let self = self else { return }
			actionSheetAlertController.addAction(UIAlertAction(title: "Take Photo 📷", style: .default, handler: { _ in
				self.openCamera()
			}))

			actionSheetAlertController.addAction(UIAlertAction(title: "Photo Library 🏛", style: .default, handler: { _ in
				self.openPhotoLibrary()
			}))

			if #available(iOS 18.1, macOS 15.1, visionOS 2.4, *) {
				if ImagePlaygroundViewController.isAvailable {
					actionSheetAlertController.addAction(UIAlertAction(title: "Image Playground ✨", style: .default, handler: { _ in
						self.openImagePlayground()
					}))
				}
			}

			if showingRemoveAction {
				actionSheetAlertController.addAction(UIAlertAction(title: Trans.remove, style: .destructive, handler: { _ in
					self.delegate?.imagePickerManagerDidRemovePickedImage()
				}))
			}

			if let popoverController = actionSheetAlertController.popoverPresentationController {
				popoverController.sourceView = sender
				popoverController.sourceRect = sender.bounds
				popoverController.permittedArrowDirections = .up
			}
		}

		self.delegate?.present(actionSheetAlertController, animated: true, completion: nil)
	}
}

// MARK: - UIImagePickerControllerDelegate
extension ImagePickerManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		if let originalImage = info[.originalImage] as? UIImage {
			if let imageURL = info[.imageURL] as? URL {
				self.delegate?.imagePickerManager(didFinishPicking: imageURL, image: originalImage)
			} else {
				// Create a temporary image path
				let imageName = UUID().uuidString
				let imageURL = FileManager.default.temporaryDirectory.appendingPathComponent(imageName, conformingTo: .image)

				// Save the image into the temporary path
				let data = originalImage.jpegData(compressionQuality: 0.1)
				try? data?.write(to: imageURL, options: [.atomic])

				self.delegate?.imagePickerManager(didFinishPicking: imageURL, image: originalImage)
			}
		} else {
			print("Error loading image from image picker.")
		}

		// Dismiss the UIImagePicker after selection
		picker.dismiss(animated: true, completion: nil)
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}
}

// MARK: - ImagePlaygroundViewController.Delegate
@available(iOS 18.1, macOS 15.1, visionOS 2.4, *)
extension ImagePickerManager: ImagePlaygroundViewController.Delegate {
	/// Open Image Playground, so the user can generate an image.
	private func openImagePlayground() {
		let imagePlaygroundViewController = ImagePlaygroundViewController()
		imagePlaygroundViewController.delegate = self
		imagePlaygroundViewController.concepts = [.text("anime"), .text("manga"), .text("game"), .text("character")]
		if #available(iOS 18.4, macOS 15.4, visionOS 2.4, *) {
			imagePlaygroundViewController.allowedGenerationStyles = [.illustration]
		}

		self.delegate?.present(imagePlaygroundViewController, animated: true)
	}

	func imagePlaygroundViewController(_ imagePlaygroundViewController: ImagePlaygroundViewController, didCreateImageAt imageURL: URL) {
		if let image = UIImage(contentsOfFile: imageURL.path) {
			self.delegate?.imagePickerManager(didFinishPicking: imageURL, image: image)
		} else {
			print("Error loading image from URL: \(imageURL)")
		}

		imagePlaygroundViewController.dismiss(animated: true, completion: nil)
	}
}
