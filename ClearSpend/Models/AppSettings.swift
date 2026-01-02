//
//  AppSettings.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftData

@Model
final class AppSettings {

    var isAppLockEnabled: Bool

    init(isAppLockEnabled: Bool = false) {
        self.isAppLockEnabled = isAppLockEnabled
    }
}

