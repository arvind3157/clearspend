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
                
                // Unlock button
                if !isAuthenticating {
                    Button {
                        isAuthenticating = true
                        Task {
                            await authService.authenticate()
                            isAuthenticating = false
                        }
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
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}
