//
//  RedeemTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import StoreKit
import SCLAlertView
import Vision
import VisionKit

class RedeemTableViewController: ServiceTableViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var rightNavigationBarButton: UIBarButtonItem!

	// MARK: - Properties
	var textFieldArray: [UITextField?] = []
	var textRecognitionRequest: VNImageBasedRequest = {
		var textRecognitionRequest: VNImageBasedRequest
		if #available(iOS 13.0, macCatalyst 13.0, *) {
			textRecognitionRequest = VNRecognizeTextRequest()
		} else {
			textRecognitionRequest = VNDetectTextRectanglesRequest()
		}
		return textRecognitionRequest
	}()
	lazy var imagePicker = UIImagePickerController()

	static let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
	let sclAlertView = SCLAlertView(appearance: appearance)

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}
	override var prefersActivityIndicatorHidden: Bool {
		return _prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		// Configure properties
		self.previewImage = R.image.promotional.redeemCode()
		self.serviceType = .redeem

		// Stop activity indicator as it's not needed for now.
		_prefersActivityIndicatorHidden = true

		rightNavigationBarButton.isEnabled = false

		// Prepare Vision
		if #available(iOS 13.0, macCatalyst 13.0, *) {
			textRecognitionRequest = VNRecognizeTextRequest(completionHandler: { (request, _) in
				if let results = request.results, !results.isEmpty {
					if let requestResults = request.results as? [VNRecognizedTextObservation] {
						DispatchQueue.main.async {
							self.processRecognizedText(requestResults)
						}
					}
				}
			})
			(textRecognitionRequest as? VNRecognizeTextRequest)?.revision = VNRecognizeTextRequestRevision1
			(textRecognitionRequest as? VNRecognizeTextRequest)?.recognitionLevel = .fast
			(textRecognitionRequest as? VNRecognizeTextRequest)?.usesLanguageCorrection = false
		}
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
			SCLAlertView().showError("Error redeeming code", subTitle: "Please specify a valid redeem code")
			return
		}

		SCLAlertView().showSuccess("Zoop, badoop, fruitloop!", subTitle: "\(redeemCode) has been redeemed successfully 🤩")
	}

	/**
		Processes the specified array of recognized text observation by creating a full transcript to run analysis on.

		- Parameter recognizedtext: An array of recognized text observation.
	*/
	@available(iOS 13.0, macCatalyst 13.0, *)
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
				textFieldArray.append(productActionTableViewCell.actionTextField)

				if #available(iOS 13.0, macCatalyst 13.0, *) {
					productActionTableViewCell.actionButton.isHidden = false
					productActionTableViewCell.actionTextField.placeholder = "Or enter your code manually"
				} else {
					productActionTableViewCell.actionButton.isHidden = true
					productActionTableViewCell.actionTextField.placeholder = "Please enter your code"
				}
			}
		default: break
		}
	}

//	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//		switch Section(rawValue: indexPath.section) {
//		case .preview:
//			let cellRatio: CGFloat = UIDevice.isLandscape ? 1.5 : 3
//			return view.frame.height / cellRatio
//		default:
//			return UITableView.automaticDimension
//		}
//	}
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
		if #available(iOS 13.0, *) {
			if VNDocumentCameraViewController.isSupported {
				let documentCameraViewController = VNDocumentCameraViewController()
				documentCameraViewController.delegate = self
				present(documentCameraViewController, animated: true)
				return
			}
		}

		openCamera()
	}
}

// MARK: - VNDocumentCameraViewControllerDelegate
@available(iOS 13.0, *)
extension RedeemTableViewController: VNDocumentCameraViewControllerDelegate {
	func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
		let sclAlertViewShow = sclAlertView.showWait("Processing redeem code.")

		controller.dismiss(animated: true) {
			DispatchQueue.global(qos: .userInitiated).async {
				for pageNumber in 0 ..< scan.pageCount {
					let image = scan.imageOfPage(at: pageNumber)
					self.processImage(image: image)
				}
				DispatchQueue.main.async {
					sclAlertViewShow.close()
				}
			}
		}
	}

	func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
		controller.dismiss(animated: true, completion: nil)
	}
}

//MARK: - UIImagePickerControllerDelegate
extension RedeemTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		let sclAlertViewShow = sclAlertView.showWait("Processing redeem code.")

		picker.dismiss(animated: true) {
			DispatchQueue.global(qos: .userInitiated).async {
				if let image = info[.editedImage] as? UIImage {
					self.processImage(image: image)
				}
				DispatchQueue.main.async {
					sclAlertViewShow.close()
				}
			}
		}
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}
}
