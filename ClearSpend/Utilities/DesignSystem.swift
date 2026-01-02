//
//  DesignSystem.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftUI

// MARK: - Design System
struct DesignSystem {
    
    // MARK: - Colors
    struct Colors {
        // Primary Brand Colors
        static let primary = Color(hex: "#4F46E5") // Indigo
        static let primaryDark = Color(hex: "#4338CA")
        static let primaryLight = Color(hex: "#818CF8")
        
        // Semantic Colors
        static let success = Color(hex: "#10B981") // Emerald
        static let successLight = Color(hex: "#D1FAE5")
        static let danger = Color(hex: "#EF4444") // Red
        static let dangerLight = Color(hex: "#FEE2E2")
        static let warning = Color(hex: "#F59E0B") // Amber
        static let warningLight = Color(hex: "#FEF3C7")
        static let info = Color(hex: "#3B82F6") // Blue
        static let infoLight = Color(hex: "#DBEAFE")
        
        // Neutral Colors
        static let gray50 = Color(hex: "#F9FAFB")
        static let gray100 = Color(hex: "#F3F4F6")
        static let gray200 = Color(hex: "#E5E7EB")
        static let gray300 = Color(hex: "#D1D5DB")
        static let gray400 = Color(hex: "#9CA3AF")
        static let gray500 = Color(hex: "#6B7280")
        static let gray600 = Color(hex: "#4B5563")
        static let gray700 = Color(hex: "#374151")
        static let gray800 = Color(hex: "#1F2937")
        static let gray900 = Color(hex: "#111827")
        
        // Background Colors
        static let background = Color(hex: "#FFFFFF")
        static let surface = Color(hex: "#FFFFFF")
        static let surfaceVariant = gray50
        static let cardBackground = Color(hex: "#FFFFFF")
        
        // Text Colors
        static let textPrimary = gray900
        static let textSecondary = gray600
        static let textTertiary = gray500
        static let textOnPrimary = Color.white
    }
    
    // MARK: - Typography
    struct Typography {
        // Display
        static let displayLarge = Font.system(size: 32, weight: .bold, design: .rounded)
        static let displayMedium = Font.system(size: 28, weight: .bold, design: .rounded)
        static let displaySmall = Font.system(size: 24, weight: .bold, design: .rounded)
        
        // Headlines
        static let headlineLarge = Font.system(size: 22, weight: .semibold, design: .rounded)
        static let headlineMedium = Font.system(size: 20, weight: .semibold, design: .rounded)
        static let headlineSmall = Font.system(size: 18, weight: .semibold, design: .rounded)
        
        // Title
        static let titleLarge = Font.system(size: 16, weight: .medium, design: .rounded)
        static let titleMedium = Font.system(size: 14, weight: .medium, design: .rounded)
        static let titleSmall = Font.system(size: 12, weight: .medium, design: .rounded)
        
        // Body
        static let bodyLarge = Font.system(size: 16, weight: .regular, design: .rounded)
        static let bodyMedium = Font.system(size: 14, weight: .regular, design: .rounded)
        static let bodySmall = Font.system(size: 12, weight: .regular, design: .rounded)
        
        // Label
        static let labelLarge = Font.system(size: 14, weight: .medium, design: .rounded)
        static let labelMedium = Font.system(size: 12, weight: .medium, design: .rounded)
        static let labelSmall = Font.system(size: 10, weight: .medium, design: .rounded)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xlarge: CGFloat = 20
        static let round: CGFloat = 1000
    }
    
    // MARK: - Shadows
    struct Shadows {
        static let small = Shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        static let medium = Shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        static let large = Shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        static let xlarge = Shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)
    }
    
    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}


// MARK: - View Modifiers
extension View {
    func cardStyle() -> some View {
        self
            .background(DesignSystem.Colors.cardBackground)
            .cornerRadius(DesignSystem.CornerRadius.medium)
            .shadow(color: DesignSystem.Shadows.medium.color, radius: DesignSystem.Shadows.medium.radius, x: DesignSystem.Shadows.medium.x, y: DesignSystem.Shadows.medium.y)
    }
    
    func primaryButtonStyle() -> some View {
        self
            .font(DesignSystem.Typography.labelLarge)
            .foregroundColor(DesignSystem.Colors.textOnPrimary)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.primary)
            .cornerRadius(DesignSystem.CornerRadius.medium)
    }
    
    func secondaryButtonStyle() -> some View {
        self
            .font(DesignSystem.Typography.labelLarge)
            .foregroundColor(DesignSystem.Colors.primary)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.primaryLight.opacity(0.1))
            .cornerRadius(DesignSystem.CornerRadius.medium)
    }
}
