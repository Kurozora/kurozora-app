//
//  SelfLabelViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/11/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit

enum SelfLabel: String, CaseIterable {
	case nsfw
	case spoiler
	case both
}

protocol SelfLabelViewDelegate: AnyObject {
	func selectedOptionChanged(_ option: SelfLabel)
}

class SelfLabelViewController: KViewController {
	// MARK: - Views
	@IBOutlet weak var segmentedControl: UISegmentedControl!
	@IBOutlet weak var primaryButton: KTintedButton!
	@IBOutlet weak var viewWidthConstraint: NSLayoutConstraint!

	// MARK: - Properties
	let options: [SelfLabel] = SelfLabel.allCases
	var selectedOption: SelfLabel?

	weak var delegate: SelfLabelViewDelegate?

	override var modalPresentationStyle: UIModalPresentationStyle {
		get {
			return UIDevice.isPhone ? .pageSheet : .popover
		}
		set {
			super.modalPresentationStyle = newValue
		}
	}

	override var preferredContentSize: CGSize {
		get {
			return self.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
		}
		set {
			super.preferredContentSize = newValue
		}
	}

	// MARK: - View
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if UIDevice.isPhone {
			if #available(iOS 16.0, *) {
				self.sheetPresentationController?.detents = [
					.custom { [weak self] _ in
						guard let self = self else { return nil }
						return self.preferredContentSize.height - self.view.safeAreaInsets.bottom
					}
				]
			} else {
				self.sheetPresentationController?.detents = [.medium()]
			}

			self.sheetPresentationController?.prefersGrabberVisible = true
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		if let selectedOption = self.selectedOption,
		   let selectedIndex = self.options.firstIndex(of: selectedOption) {
			self.segmentedControl.selectedSegmentIndex = selectedIndex
		} else {
			self.segmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
		}
		self.segmentedControl.theme_tintColor = KThemePicker.tintColor.rawValue

		if UIDevice.isPhone {
			self.viewWidthConstraint.constant = self.view.width
		} else if UIDevice.isPad {
			// iPad seems to subtract 60 points from the specified width.
			// By adding 60 points before we calculate the width,
			// the total width ends up being 300 points just like on
			// Macs.
			self.viewWidthConstraint.constant = 360.0
		} else {
			self.viewWidthConstraint.constant = 300.0
		}
	}

	// MARK: Functions
	@IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
		guard let selectedOption = self.options[safe: sender.selectedSegmentIndex] else { return }
		self.delegate?.selectedOptionChanged(selectedOption)
	}

	@objc func cancelButtonPressed(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}

	@IBAction func primaryButtonPressed(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}
}
