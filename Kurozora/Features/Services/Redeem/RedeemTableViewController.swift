//
//  RedeemTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import StoreKit
import UIKit
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
        self.previewImage = .Promotional.redeemCode
		self.serviceType = .redeem

		self.rightNavigationBarButton.isEnabled = false

		// Prepare Vision
		self.textRecognitionRequest = VNRecognizeTextRequest(completionHandler: { [weak self] request, _ in
			guard let self = self else { return }
			if let results = request.results, !results.isEmpty {
				if let requestResults = request.results as? [VNRecognizedTextObservation] {
					DispatchQueue.main.async {
						self.processRecognizedText(requestResults)
					}
				}
			}
		})
		self.textRecognitionRequest.revision = VNRecognizeTextRequestRevision1
		self.textRecognitionRequest.recognitionLevel = .fast
		self.textRecognitionRequest.usesLanguageCorrection = false
	}

	// MARK: - Functions
	/// Open the camera if the device has one, otherwise show a warning.
	func openCamera() {
		if UIImagePickerController.isSourceTypeAvailable(.camera) {
			self.imagePicker.sourceType = .camera
			self.imagePicker.delegate = self
			self.present(self.imagePicker, animated: true, completion: nil)
		} else {
			self.presentAlertController(title: "Well, this is awkward.", message: "You don't seem to have a camera 😓")
		}
	}

	/// Processes the specified image with VNImageRequestHandler.
	///
	/// - Parameter image: The image specified to be processed
	func processImage(image: UIImage) {
		guard let cgImage = image.cgImage else {
			print("Failed to get cgimage from input image")
			return
		}

		let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
		do {
			try handler.perform([self.textRecognitionRequest])
		} catch {
			print(error)
		}
	}

	/// Shows a string on an alert view controller.
	///
	/// - Parameter redeemCode: The string to show on the alert view.
	func showSuccess(for redeemCode: String?) {
		guard let redeemCode = redeemCode else {
			self.presentAlertController(title: Trans.redeemErrorHeadline, message: Trans.redeemErrorSubheadline)
			return
		}

		self.presentAlertController(title: Trans.redeemSuccessHeadline, message: "\(redeemCode) was successfully redeemed 🤩")
	}

	/// Processes the specified array of recognized text observation by creating a full transcript to run analysis on.
	///
	/// - Parameter recognizedText: An array of recognized text observation.
	fileprivate func processRecognizedText(_ recognizedText: [Any]) {
		if let recognizedText = recognizedText as? [VNRecognizedTextObservation] {
			let maximumCandidates = 1
			for observation in recognizedText {
				guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
				if candidate.string.starts(with: "XXX"), candidate.string.count == 13 {
					self.showSuccess(for: candidate.string)
				}
			}
		}
	}

	// MARK: - IBActions
	@IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}

	@IBAction func rightNavigationBarButtonPressed(sender: AnyObject) {
		self.view.endEditing(true)

		let redeemCode = self.textFieldArray.first??.text?.trimmingCharacters(in: .whitespacesAndNewlines)
		self.showSuccess(for: redeemCode)

		// TODO: Implement redeeming codes
//		KurozoraKit.shared.redeem(code, withSuccess: { [weak self] success in
//			guard let self = self else { return }
//
//			if success {
//				DispatchQueue.main.async {
//
//				}
//			}
//
//			self.rightNavigationBarButton.isEnabled = false
//		})
	}
}

// MARK: - UITableViewDataSource
extension RedeemTableViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [
			ActionButtonTableViewCell.self,
			ServicePreviewTableViewCell.self,
			ServiceHeaderTableViewCell.self,
			ServiceFooterTableViewCell.self,
		]
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch Section(rawValue: indexPath.section) {
		case .body:
			guard let actionButtonTableViewCell = tableView.dequeueReusableCell(withIdentifier: ActionButtonTableViewCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(ActionButtonTableViewCell.reuseID)")
			}
			actionButtonTableViewCell.delegate = self
			actionButtonTableViewCell.actionTextField.tag = indexPath.row
			actionButtonTableViewCell.actionTextField.delegate = self
			actionButtonTableViewCell.actionTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
			actionButtonTableViewCell.actionTextField.placeholder = "Or enter your code manually"
			actionButtonTableViewCell.actionButton.isHidden = false
			self.textFieldArray.append(actionButtonTableViewCell.actionTextField)
			return actionButtonTableViewCell
		default:
			return super.tableView(tableView, cellForRowAt: indexPath)
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
		for item in self.textFieldArray {
			if let textField = item?.text, !textField.isEmpty {
				rightNavigationBarButtonIsEnabled = true
				continue
			}
			rightNavigationBarButtonIsEnabled = false
		}

		self.rightNavigationBarButton.isEnabled = rightNavigationBarButtonIsEnabled
	}

	func textFieldDidBeginEditing(_ textField: UITextField) {
		textField.returnKeyType = textField.tag == self.textFieldArray.count - 1 ? .send : .next
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField.tag == self.textFieldArray.count - 1 {
			self.rightNavigationBarButtonPressed(sender: textField)
		} else {
			self.textFieldArray[textField.tag + 1]?.becomeFirstResponder()
		}

		return true
	}
}

// MARK: - ActionButtonTableViewCellDelegate
extension RedeemTableViewController: ActionButtonTableViewCellDelegate {
	func actionButtonTableViewCell(_ cell: ActionButtonTableViewCell, didPressButton button: UIButton) {
		if VNDocumentCameraViewController.isSupported {
			let documentCameraViewController = VNDocumentCameraViewController()
			documentCameraViewController.delegate = self
			self.present(documentCameraViewController, animated: true)
		} else {
			self.openCamera()
		}
	}
}

// MARK: - VNDocumentCameraViewControllerDelegate
extension RedeemTableViewController: VNDocumentCameraViewControllerDelegate {
	func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
		let alertController = self.presentActivityAlertController(title: Trans.redeemProcessingHeadline, message: nil)

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

// MARK: - UIImagePickerControllerDelegate
extension RedeemTableViewController: UIImagePickerControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		let alertController = self.presentActivityAlertController(title: Trans.redeemProcessingHeadline, message: nil)

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
