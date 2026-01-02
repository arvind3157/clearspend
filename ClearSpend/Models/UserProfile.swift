//
//  UserProfile.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftData
import Foundation

@Model
final class UserProfile {
    
    var id: UUID
    var name: String
    var profileImageData: Data?
    var isAppLockEnabled: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(name: String = "ClearSpend User", profileImageData: Data? = nil, isAppLockEnabled: Bool = false) {
        self.id = UUID()
        self.name = name
        self.profileImageData = profileImageData
        self.isAppLockEnabled = isAppLockEnabled
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    func updateProfile(name: String? = nil, profileImageData: Data? = nil, isAppLockEnabled: Bool? = nil) {
        if let name = name {
            self.name = name
        }
        if let profileImageData = profileImageData {
            self.profileImageData = profileImageData
        }
        if let isAppLockEnabled = isAppLockEnabled {
            self.isAppLockEnabled = isAppLockEnabled
        }
        self.updatedAt = Date()
    }
}
