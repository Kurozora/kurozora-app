//
//  MALImportActionTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/05/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class MALImportActionTableViewCell: ProductActionTableViewCell {
	// MARK: - Functions
	override func actionButtonPressed(_ sender: UIButton) {
		let documentPicker: UIDocumentPickerViewController
		let types: [UTType] = [.xml]
		documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: types)
		documentPicker.delegate = self.parentViewController as? MALImportTableViewController
		documentPicker.modalPresentationStyle = .formSheet
		self.parentViewController?.present(documentPicker, animated: true, completion: nil)
	}
}
