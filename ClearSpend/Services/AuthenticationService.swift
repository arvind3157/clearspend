//
//  AuthenticationService.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import Foundation
import LocalAuthentication
import SwiftData
import Combine

class AuthenticationService: ObservableObject {
    
    static let shared = AuthenticationService()
    
    @Published var isUnlocked = true
    @Published var isShowingLockScreen = false
    
    private var context: ModelContext?
    
    private init() {}
    
    func setup(with modelContext: ModelContext) {
        self.context = modelContext
        checkInitialLockStatus()
    }
    
    private func checkInitialLockStatus() {
        guard let context = context else { return }
        
        let descriptor = FetchDescriptor<UserProfile>()
        let userProfile = try? context.fetch(descriptor).first
        
        if let userProfile = userProfile, userProfile.isAppLockEnabled {
            isUnlocked = false
            isShowingLockScreen = true
            print("App lock is enabled, showing lock screen")
        } else {
            isUnlocked = true
            isShowingLockScreen = false
            print("App lock is disabled or no profile found")
        }
    }
    
    func authenticate() async {
        print("Starting biometric authentication")
        
        let context = LAContext()
        var error: NSError?
        
        // Try Face ID first
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            print("Face ID available, attempting biometric authentication")
            do {
                let success = try await context.evaluatePolicy(
                    .deviceOwnerAuthenticationWithBiometrics,
                    localizedReason: "Authenticate to access ClearSpend"
                )
                
                print("Face ID authentication result: \(success)")
                
                if success {
                    await MainActor.run {
                        self.isUnlocked = true
                        self.isShowingLockScreen = false
                        print("✅ Face ID authentication successful! App unlocked.")
                    }
                }
                
                return
            } catch {
                print("Face ID authentication failed: \(error.localizedDescription)")
                // Fall back to passcode
                await authenticateWithPasscode()
            }
        } else {
            print("Face ID not available, using passcode")
            await authenticateWithPasscode()
        }
    }
    
    @MainActor
    private func authenticateWithPasscode() async {
        print("Starting passcode authentication")
        let context = LAContext()
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: "Authenticate to access ClearSpend"
            )
            
            print("Passcode authentication result: \(success)")
            
            if success {
                self.isUnlocked = true
                self.isShowingLockScreen = false
                print("✅ Passcode authentication successful! App unlocked.")
            }
        } catch {
            print("❌ Passcode authentication failed: \(error.localizedDescription)")
        }
    }
    
    func toggleAppLock() {
        guard let context = context else { return }
        
        let descriptor = FetchDescriptor<UserProfile>()
        var userProfile = try? context.fetch(descriptor).first
        
        if userProfile == nil { // Create new profile if none exists
            let newProfile = UserProfile()
            context.insert(newProfile)
            userProfile = newProfile
        }
        
        let currentProfile = userProfile!
        currentProfile.isAppLockEnabled = !currentProfile.isAppLockEnabled
        
        do {
            try context.save()
            print("🔄 App lock toggled to: \(currentProfile.isAppLockEnabled)")
            
            if currentProfile.isAppLockEnabled {
                isUnlocked = false
                isShowingLockScreen = true
            } else {
                isUnlocked = true
                isShowingLockScreen = false
            }
        } catch {
            print("Failed to save app lock setting: \(error)")
        }
    }
}
