//
//  LockScreenView.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftUI

struct LockScreenView: View {
    
    @ObservedObject var authService: AuthenticationService
    @State private var isAnimating = false
    @State private var isAuthenticating = false
    @State private var hasAttemptedAutoAuth = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    DesignSystem.Colors.primary,
                    DesignSystem.Colors.primaryDark
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: DesignSystem.Spacing.xl) {
                // App icon and name
                VStack(spacing: DesignSystem.Spacing.lg) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "wallet.pass")
                            .font(.system(size: 48))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    
                    Text("ClearSpend")
                        .font(DesignSystem.Typography.displaySmall)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Secure Financial Tracker")
                        .font(DesignSystem.Typography.bodyMedium)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Authentication error display
                if let error = authService.authenticationError {
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        Text(error)
                            .font(DesignSystem.Typography.bodySmall)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Try Again") {
                            authService.resetAuthentication()
                            performAuthentication()
                        }
                        .font(DesignSystem.Typography.bodyMedium)
                        .foregroundColor(.white)
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        .padding(.vertical, DesignSystem.Spacing.sm)
                        .background(.white.opacity(0.2))
                        .cornerRadius(DesignSystem.CornerRadius.medium)
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
                
                // Unlock button
                if !isAuthenticating {
                    Button {
                        performAuthentication()
                    } label: {
                        HStack(spacing: DesignSystem.Spacing.md) {
                            Image(systemName: "faceid")
                                .font(DesignSystem.Typography.titleMedium)
                            
                            Text("Unlock")
                                .font(DesignSystem.Typography.headlineSmall)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(DesignSystem.Colors.primary)
                        .padding(.horizontal, DesignSystem.Spacing.xl)
                        .padding(.vertical, DesignSystem.Spacing.lg)
                        .background(.white)
                        .cornerRadius(DesignSystem.CornerRadius.large)
                    }
                    .disabled(isAuthenticating)
                    .scaleEffect(isAnimating ? 1.0 : 0.95)
                } else {
                    HStack(spacing: DesignSystem.Spacing.md) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        Text("Authenticating...")
                            .font(DesignSystem.Typography.bodyMedium)
                            .foregroundColor(.white)
                    }
                    .padding(DesignSystem.Spacing.lg)
                    .background(.white.opacity(0.2))
                    .cornerRadius(DesignSystem.CornerRadius.medium)
                }
                
                Spacer()
            }
            .padding(DesignSystem.Spacing.xl)
        }
        .onAppear {
            startAnimation()
            // Automatically attempt biometric authentication when lock screen appears
            if !hasAttemptedAutoAuth {
                hasAttemptedAutoAuth = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    performAuthentication()
                }
            }
        }
        .onChange(of: authService.authenticationError) { oldValue, newValue in
            if newValue != nil {
                // Reset authentication state when error occurs
                isAuthenticating = false
            }
        }
        .onChange(of: authService.isShowingLockScreen) { oldValue, newValue in
            // Reset auto-auth flag when lock screen is shown again
            if newValue && !oldValue {
                hasAttemptedAutoAuth = false
            }
        }
    }
    
    private func startAnimation() {
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            isAnimating = true
        }
    }
    
    private func performAuthentication() {
        guard !isAuthenticating else { return }
        
        isAuthenticating = true
        authService.resetAuthentication()
        
        Task {
            await authService.authenticate()
            // Reset authentication state when done
            await MainActor.run {
                isAuthenticating = false
            }
        }
    }
}
