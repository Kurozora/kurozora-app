//
//  KFeedMessageTextEditorViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

protocol KFeedMessageTextEditorViewDelegate: class {
	func kFeedMessageTextEditorView(updateMessagesWith feedMessages: [FeedMessage])
	func segueToOPFeedDetails(_ feedMessage: FeedMessage)
}
