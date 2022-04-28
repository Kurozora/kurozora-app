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
		if #available(iOS 14.0, macOS 11.0, *) {
			let types: [UTType] = [.xml]
			documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: types)
		} else {
			let types: [String] = [kUTTypeXML as String]
			documentPicker = UIDocumentPickerViewController(documentTypes: types, in: .import)
		}
		documentPicker.delegate = self.parentViewController as? MALImportTableViewController
		documentPicker.modalPresentationStyle = .formSheet
		self.parentViewController?.present(documentPicker, animated: true, completion: nil)
	}
}
