//
//  View+KurozoraWidget.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/07/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import SwiftUI

extension View {
	func widgetBackground(_ backgroundView: some View) -> some View {
		if #available(iOS 17.0, *) {
			return self.containerBackground(for: .widget) {
				backgroundView
			}
		} else {
			return self.background(backgroundView)
		}
	}
}
