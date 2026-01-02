//
//  SpendPieChartView.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftUI
import Charts

struct SpendPieChartView: View {

    let categorySpends: [CategorySpend]

    var body: some View {
        Chart(categorySpends) { item in
            SectorMark(
                angle: .value("Amount", item.amount)
            )
            .foregroundStyle(
                Color(hex: item.category.colorHex)
            )
            .annotation(position: .overlay) {
                if item.amount / totalSpend > 0.1 {
                    Text(item.category.name)
                        .font(.caption2)
                        .foregroundStyle(.white)
                }
            }
        }
        .frame(height: 260)
    }

    private var totalSpend: Double {
        categorySpends.reduce(0) { $0 + $1.amount }
    }
}
