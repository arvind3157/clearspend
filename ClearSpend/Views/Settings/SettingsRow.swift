//
//  SettingsRow.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftUI

@ViewBuilder
func settingsRow(
    title: String,
    subtitle: String,
    enabled: Bool
) -> some View {
    HStack {
        VStack(alignment: .leading) {
            Text(title)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        Spacer()
        if !enabled {
            Image(systemName: "lock.fill")
                .foregroundStyle(.secondary)
        }
    }
    .opacity(enabled ? 1.0 : 0.6)
}
