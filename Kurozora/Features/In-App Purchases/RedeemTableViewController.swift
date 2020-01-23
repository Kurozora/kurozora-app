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

class RedeemTableViewController: KTableViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var rightNavigationBarButton: UIBarButtonItem!

	// MARK: - Properties
	var textFieldArray: [UITextField?] = []

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

		// Stop activity indicator as it's not needed for now.
		_prefersActivityIndicatorHidden = true

		rightNavigationBarButton.isEnabled = false
	}

	// MARK: - IBActions
	@IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}

	@IBAction func rightNavigationBarButtonPressed(sender: AnyObject) {
		view.endEditing(true)

		SCLAlertView().showInfo("Bleep bloop...", subTitle: "This feature is a work in progress. It will be available in the upcoming feature.")
//		let redeemCode = textFieldArray[0]?.trimmedText
//		KService.shared.redeem(code, withSuccess: { (success) in
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
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 4
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let subscriptionPreviewTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PurchasePreviewTableViewCell", for: indexPath) as! PurchasePreviewTableViewCell
			return subscriptionPreviewTableViewCell
		} else if indexPath.section == 1 {
			let purchaseHeaderTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PurchaseHeaderTableViewCell", for: indexPath) as! PurchaseHeaderTableViewCell
			return purchaseHeaderTableViewCell
		} else if indexPath.section == 2 {
			let purchaseRedeemTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PurchaseRedeemTableViewCell", for: indexPath) as! PurchaseRedeemTableViewCell
			purchaseRedeemTableViewCell.redeemTextField.tag = indexPath.row
			purchaseRedeemTableViewCell.redeemTextField.delegate = self
			purchaseRedeemTableViewCell.redeemTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
			textFieldArray.append(purchaseRedeemTableViewCell.redeemTextField)
			return purchaseRedeemTableViewCell
		}

		let purchaseInfoTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PurchaseInfoTableViewCell", for: indexPath) as! PurchaseInfoTableViewCell
		return purchaseInfoTableViewCell
	}
}

// MARK: - UITableViewDelegate
extension RedeemTableViewController {
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.section == 0 {
			let cellRatio: CGFloat = UIDevice.isLandscape ? 1.5 : 3
			return view.frame.height / cellRatio
		}

		return UITableView.automaticDimension
	}

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return CGFloat.leastNormalMagnitude
	}

	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 22
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
