//
//  ModernSettingsRow.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftUI

struct ModernSettingsRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let enabled: Bool
    let showChevron: Bool
    let isDestructive: Bool
    
    init(
        title: String,
        subtitle: String,
        icon: String,
        enabled: Bool,
        showChevron: Bool = false,
        isDestructive: Bool = false
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.enabled = enabled
        self.showChevron = showChevron
        self.isDestructive = isDestructive
    }
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconBackgroundColor)
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(DesignSystem.Typography.titleSmall)
                    .foregroundColor(iconColor)
            }
            
            // Text Content
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(title)
                    .font(DesignSystem.Typography.bodyMedium)
                    .fontWeight(.medium)
                    .foregroundColor(textColor)
                
                Text(subtitle)
                    .font(DesignSystem.Typography.bodySmall)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Status/Navigation
            HStack(spacing: DesignSystem.Spacing.sm) {
                if !enabled {
                    Image(systemName: "lock.fill")
                        .font(DesignSystem.Typography.bodySmall)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(DesignSystem.Typography.bodySmall)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .fill(DesignSystem.Colors.surfaceVariant)
        )
        .opacity(enabled ? 1.0 : 0.6)
        .contentShape(Rectangle())
    }
    
    private var iconBackgroundColor: Color {
        if isDestructive {
            return DesignSystem.Colors.dangerLight
        } else if !enabled {
            return DesignSystem.Colors.gray200
        } else {
            return DesignSystem.Colors.primaryLight.opacity(0.2)
        }
    }
    
    private var iconColor: Color {
        if isDestructive {
            return DesignSystem.Colors.danger
        } else if !enabled {
            return DesignSystem.Colors.textTertiary
        } else {
            return DesignSystem.Colors.primary
        }
    }
    
    private var textColor: Color {
        if isDestructive {
            return DesignSystem.Colors.danger
        } else {
            return DesignSystem.Colors.textPrimary
        }
    }
}
