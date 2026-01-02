//
//  RootView.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftUI
import SwiftData

struct RootView: View {

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house")
                }

            AddPlaceholderView()
                .tabItem {
                    Label("Add", systemImage: "plus.circle.fill")
                }

            AnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.pie.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .onAppear {
            CategorySeeder.seedIfNeeded(context: modelContext)
        }
    }
}
