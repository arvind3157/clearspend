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
    @Published var authenticationError: String?
    @Published var isAppLockEnabled = false
    
    private var context: ModelContext?
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    func setup(with modelContext: ModelContext) {
        self.context = modelContext
        
        // Ensure we're on main thread for UI updates
        DispatchQueue.main.async {
            self.checkInitialLockStatus()
        }
    }
    
    private func checkInitialLockStatus() {
        guard let context = context else { 
            print("❌ ModelContext not available")
            return 
        }
        
        do {
            let descriptor = FetchDescriptor<UserProfile>()
            let userProfiles = try context.fetch(descriptor)
            let userProfile = userProfiles.first
            
            if let userProfile = userProfile, userProfile.isAppLockEnabled {
                DispatchQueue.main.async {
                    self.isAppLockEnabled = true
                    self.isUnlocked = false
                    self.isShowingLockScreen = true
                    print("🔒 App lock is enabled, showing lock screen")
                }
            } else {
                DispatchQueue.main.async {
                    self.isAppLockEnabled = false
                    self.isUnlocked = true
                    self.isShowingLockScreen = false
                    print("🔓 App lock is disabled or no profile found")
                }
            }
        } catch {
            DispatchQueue.main.async {
                print("❌ Failed to check lock status: \(error)")
                self.authenticationError = "Failed to check app lock status"
                // Default to unlocked on error to prevent app from being stuck
                self.isUnlocked = true
                self.isShowingLockScreen = false
            }
        }
    }
    
    func authenticate() async {
        print("🔐 Starting biometric authentication")
        
        await MainActor.run {
            authenticationError = nil
        }
        
        let context = LAContext()
        var error: NSError?
        
        // Check if biometrics are available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            print("👤 Face ID/Touch ID available, attempting biometric authentication")
            await performBiometricAuthentication(with: context)
        } else {
            print("🔢 Biometrics not available, using passcode authentication")
            await authenticateWithPasscode()
        }
    }
    
    private func performBiometricAuthentication(with context: LAContext) async {
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Authenticate to access ClearSpend"
            )
            
            await handleAuthenticationResult(success, method: "Biometric")
        } catch {
            print("❌ Biometric authentication failed: \(error.localizedDescription)")
            
            await MainActor.run {
                // Handle different types of biometric failures
                if error.localizedDescription.contains("user fallback") || 
                   error.localizedDescription.contains("canceled") ||
                   error.localizedDescription.contains("not available") ||
                   error.localizedDescription.contains("not enrolled") {
                    // User chose to use passcode or biometrics not available/enrolled
                    print("🔄 Falling back to passcode authentication")
                    Task {
                        await authenticateWithPasscode()
                    }
                } else if error.localizedDescription.contains("policy") {
                    // Policy evaluation failed - try passcode
                    print("🔄 Biometric policy failed, trying passcode")
                    Task {
                        await authenticateWithPasscode()
                    }
                } else {
                    // Other biometric errors
                    authenticationError = "Biometric authentication failed. Please try again."
                }
            }
        }
    }
    
    @MainActor
    private func authenticateWithPasscode() async {
        print("🔢 Starting passcode authentication")
        let context = LAContext()
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: "Authenticate to access ClearSpend"
            )
            
            await handleAuthenticationResult(success, method: "Passcode")
        } catch {
            print("❌ Passcode authentication failed: \(error.localizedDescription)")
            authenticationError = "Authentication failed. Please try again."
        }
    }
    
    @MainActor
    private func handleAuthenticationResult(_ success: Bool, method: String) {
        print("🔐 \(method) authentication result: \(success)")
        
        if success {
            isUnlocked = true
            isShowingLockScreen = false
            authenticationError = nil
            print("✅ \(method) authentication successful! App unlocked.")
        } else {
            authenticationError = "\(method) authentication failed"
        }
    }
    
    func toggleAppLock() {
        guard let context = context else { 
            print("❌ ModelContext not available for toggle")
            return 
        }
        
        do {
            let descriptor = FetchDescriptor<UserProfile>()
            var userProfile = try context.fetch(descriptor).first
            
            if userProfile == nil {
                // Create new profile if none exists
                let newProfile = UserProfile()
                context.insert(newProfile)
                userProfile = newProfile
                print("👤 Created new user profile")
            }
            
            guard let currentProfile = userProfile else {
                print("❌ Failed to create or retrieve user profile")
                return
            }
            
            currentProfile.isAppLockEnabled.toggle()
            currentProfile.updatedAt = Date()
            
            try context.save()
            
            let isEnabled = currentProfile.isAppLockEnabled
            print("🔄 App lock toggled to: \(isEnabled)")
            
            // Update UI state immediately
            if isEnabled {
                isAppLockEnabled = true
                isUnlocked = false
                isShowingLockScreen = true
                print("🔒 App lock enabled - showing lock screen")
            } else {
                isAppLockEnabled = false
                isUnlocked = true
                isShowingLockScreen = false
                print("🔓 App lock disabled - app unlocked")
            }
        } catch {
            print("❌ Failed to toggle app lock: \(error)")
            authenticationError = "Failed to update app lock setting"
        }
    }
    
    func resetAuthentication() {
        authenticationError = nil
    }
}
