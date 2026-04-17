//
//  L10n.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/04/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import Foundation

/// Namespace for all localized user-facing strings in Kurozora.
///
/// Strings are organized across five domains, each backed by its own
/// `.xcstrings` catalog for independent translation workflows:
///
/// - ``Account`` domain → `Account.xcstrings`
/// - ``Content`` domain → `Content.xcstrings`
/// - ``Settings`` domain → `Settings.xcstrings`
/// - ``Alerts`` domain → `Alerts.xcstrings`
/// - `Common` domain → `Localizable.xcstrings` *(default, unscoped strings)*
///
/// - Tag: L10n
struct L10n {}
