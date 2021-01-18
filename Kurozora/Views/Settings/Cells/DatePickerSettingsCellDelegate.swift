//
//  DatePickerSettingsCellDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

protocol DatePickerSettingsCellDelegate: class {
	func datePickerSettingsCell(_ cell: DatePickerSettingsCell, didChangeDate datePicker: UIDatePicker)
}
