//
//  KurozoraWidgetBundle.swift
//  KurozoraWidget
//
//  Created by Khoren Katklian on 05/04/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import WidgetKit
import SwiftUI
import SwifterSwift

@main
struct KurozoraWidgetBundle: WidgetBundle {
    var body: some Widget {
        DateWidget()

		self.launchAppControl()
    }

	@WidgetBundleBuilder @MainActor
	func launchAppControl() -> some Widget {
		if #available(iOS 18.0, *) {
			LaunchAppControl()
		}
	}
}
