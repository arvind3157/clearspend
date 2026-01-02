//
//  CategoryCell.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftUI

struct CategoryCell: View {

    let category: Category
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: category.icon)
                .font(.title2)
                .foregroundStyle(.white)

            Text(category.name)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: category.colorHex))
                .opacity(isSelected ? 1.0 : 0.8)
        )
        .overlay {
            if isSelected {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.white, lineWidth: 2)
            }
        }
    }
}
