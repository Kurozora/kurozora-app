//
//  RedeemTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import StoreKit
import Vision
import VisionKit

class RedeemTableViewController: ServiceTableViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var rightNavigationBarButton: UIBarButtonItem!

	// MARK: - Properties
	var textFieldArray: [UITextField?] = []
	var textRecognitionRequest = VNRecognizeTextRequest()
	lazy var imagePicker = UIImagePickerController()

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		// Configure properties
		self.previewImage = R.image.promotional.redeemCode()
		self.serviceType = .redeem

		rightNavigationBarButton.isEnabled = false

		// Prepare Vision
		textRecognitionRequest = VNRecognizeTextRequest(completionHandler: { (request, _) in
			if let results = request.results, !results.isEmpty {
				if let requestResults = request.results as? [VNRecognizedTextObservation] {
					DispatchQueue.main.async {
						self.processRecognizedText(requestResults)
					}
				}
			}
		})
		textRecognitionRequest.revision = VNRecognizeTextRequestRevision1
		textRecognitionRequest.recognitionLevel = .fast
		textRecognitionRequest.usesLanguageCorrection = false
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
			self.presentAlertController(title: "Well, this is awkward.", message: "You don't seem to have a camera 😓")
		}
	}

	/**
		Processes the specified image with VNImageRequestHandler.

		- Parameter image: The image specified to be processed
	*/
	func processImage(image: UIImage) {
		guard let cgImage = image.cgImage else {
			print("Failed to get cgimage from input image")
			return
		}

		let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
		do {
			try handler.perform([textRecognitionRequest])
		} catch {
			print(error)
		}
	}

	/**
		Shows a string on an alert view controller.

		- Parameter redeemCode: The string to show on the alert view.
	*/
	func showSuccess(for redeemCode: String?) {
		guard let redeemCode = redeemCode else {
			self.presentAlertController(title: "Error Redeeming Code", message: "The code entered is not valid.")
			return
		}

		self.presentAlertController(title: "Zoop, badoop, fruitloop!", message: "\(redeemCode) was successfully redeemed 🤩")
	}

	/**
		Processes the specified array of recognized text observation by creating a full transcript to run analysis on.

		- Parameter recognizedtext: An array of recognized text observation.
	*/
	fileprivate func processRecognizedText(_ recognizedText: [Any]) {
		if let recognizedText = recognizedText as? [VNRecognizedTextObservation] {
			let maximumCandidates = 1
			for observation in recognizedText {
				guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
				if candidate.string.starts(with: "XXX") && candidate.string.count == 13 {
					showSuccess(for: candidate.string)
				}
			}
		}
	}

	// MARK: - IBActions
	@IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}

	@IBAction func rightNavigationBarButtonPressed(sender: AnyObject) {
		view.endEditing(true)

		let redeemCode = textFieldArray.first??.trimmedText
		showSuccess(for: redeemCode)
//		KurozoraKit.shared.redeem(code, withSuccess: { (success) in
//			if success {
//				DispatchQueue.main.async {
//
//				}
//			}
//			self.rightNavigationBarButton.isEnabled = false
//		})
	}
}

// MARK: - UITableViewDataSource
extension RedeemTableViewController {
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch Section(rawValue: indexPath.section) {
		case .body:
			guard let productActionTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.productActionTableViewCell, for: indexPath) else {
				fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.productActionTableViewCell.identifier)")
			}
			return productActionTableViewCell
		default:
			return super.tableView(tableView, cellForRowAt: indexPath)
		}
	}
}

// MARK: - UITableViewDelegate
extension RedeemTableViewController {
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		switch Section(rawValue: indexPath.section) {
		case .body:
			if let productActionTableViewCell = cell as? ProductActionTableViewCell {
				productActionTableViewCell.delegate = self
				productActionTableViewCell.actionTextField.tag = indexPath.row
				productActionTableViewCell.actionTextField.delegate = self
				productActionTableViewCell.actionTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
				productActionTableViewCell.actionTextField.placeholder = "Or enter your code manually"
				productActionTableViewCell.actionButton.isHidden = false
				textFieldArray.append(productActionTableViewCell.actionTextField)
			}
		default: break
		}
	}
}

// MARK: - UITextFieldDelegate
extension RedeemTableViewController: UITextFieldDelegate {
	@objc func editingChanged(_ textField: UITextField) {
		if textField.text?.count == 1, textField.text?.first == " " {
			textField.text = ""
			return
		}

		var rightNavigationBarButtonIsEnabled = false
		textFieldArray.forEach({
			if let textField = $0?.text, !textField.isEmpty {
				rightNavigationBarButtonIsEnabled = true
				return
			}
			rightNavigationBarButtonIsEnabled = false
		})

		rightNavigationBarButton.isEnabled = rightNavigationBarButtonIsEnabled
	}

	func textFieldDidBeginEditing(_ textField: UITextField) {
		textField.returnKeyType = textField.tag == textFieldArray.count - 1 ? .send : .next
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField.tag == textFieldArray.count - 1 {
			rightNavigationBarButtonPressed(sender: textField)
		} else {
			textFieldArray[textField.tag + 1]?.becomeFirstResponder()
		}

		return true
	}
}

// MARK: - ProductActionTableViewCellDelegate
extension RedeemTableViewController: ProductActionTableViewCellDelegate {
	func actionButtonPressed(_ sender: UIButton) {
		if VNDocumentCameraViewController.isSupported {
			let documentCameraViewController = VNDocumentCameraViewController()
			documentCameraViewController.delegate = self
			present(documentCameraViewController, animated: true)
			return
		}

		openCamera()
	}
}

// MARK: - VNDocumentCameraViewControllerDelegate
extension RedeemTableViewController: VNDocumentCameraViewControllerDelegate {
	func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
		let alertController = self.presentActivityAlertController(title: "Processing redeem code.", message: nil)

		controller.dismiss(animated: true) {
			DispatchQueue.global(qos: .userInitiated).async {
				for pageNumber in 0 ..< scan.pageCount {
					let image = scan.imageOfPage(at: pageNumber)
					self.processImage(image: image)
				}
				DispatchQueue.main.async {
					alertController.dismiss(animated: true, completion: nil)
				}
			}
		}
	}

	func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
		controller.dismiss(animated: true, completion: nil)
	}
}

//MARK: - UIImagePickerControllerDelegate
extension RedeemTableViewController: UIImagePickerControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		let alertController = self.presentActivityAlertController(title: "Processing redeem code.", message: nil)

		picker.dismiss(animated: true) {
			DispatchQueue.global(qos: .userInitiated).async {
				if let image = info[.editedImage] as? UIImage {
					self.processImage(image: image)
				}
				DispatchQueue.main.async {
					alertController.dismiss(animated: true, completion: nil)
				}
			}
		}
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}
}
