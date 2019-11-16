//
//  Tabman+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/11/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Tabman

extension TMBar {
	/// Kurozora style bar, very reminiscent of the iOS 13 Photos app bottom tab bar. It consists
	/// of a horizontal layout containing label bar buttons, and a line indicator at the bottom.
	typealias KBar = TMBarView<TMHorizontalBarLayout, TMLabelBarButton, KFillBarIndicator>
}
