//
//  RootView.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import SwiftUI

struct RootView: View {

    @State private var showMenu = false
    @State private var showAddIncome = false
    @State private var showAddExpense = false
    @State private var showScanBill = false

    var body: some View {
        ZStack {

            TabView {
                DashboardView()
                    .tabItem {
                        Label("Dashboard", systemImage: "house.fill")
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
            .tint(DesignSystem.Colors.primary)

            // Dimmed background when menu is open
            if showMenu {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showMenu = false
                        }
                    }
            }

            // FAB + Menu
            VStack {
                Spacer()
                HStack {
                    Spacer()

                    VStack(spacing: DesignSystem.Spacing.md) {

                        if showMenu {
                            fabMenu
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }

                        fabButton
                    }
                    .padding(.trailing, DesignSystem.Spacing.lg)
                    .padding(.bottom, DesignSystem.Spacing.xl) // Safe area from tab bar
                }
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: showMenu)
        .sheet(isPresented: $showAddIncome) {
            AddIncomeView()
        }
        .sheet(isPresented: $showAddExpense) {
            AddExpenseView()
        }
        .sheet(isPresented: $showScanBill) {
            ScanBillView()
        }
    }
    
    private var fabButton: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                showMenu.toggle()
            }
        } label: {
            ZStack {
                Circle()
                    .fill(DesignSystem.Colors.primary)
                    .frame(width: 56, height: 56)
                    .shadow(color: DesignSystem.Shadows.large.color, radius: DesignSystem.Shadows.large.radius, x: DesignSystem.Shadows.large.x, y: DesignSystem.Shadows.large.y)
                
                Image(systemName: "plus")
                    .font(DesignSystem.Typography.headlineSmall)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.textOnPrimary)
                    .rotationEffect(.degrees(showMenu ? 45 : 0))
            }
        }
        .scaleEffect(showMenu ? 1.1 : 1.0)
    }
    
    private var fabMenu: some View {
        VStack(alignment: .trailing, spacing: DesignSystem.Spacing.sm) {

            fabMenuButton(
                title: "Scan Bill",
                icon: "camera.fill",
                color: DesignSystem.Colors.info
            ) {
                showScanBill = true
                showMenu = false
            }

            fabMenuButton(
                title: "Add Expense",
                icon: "arrow.up.circle.fill",
                color: DesignSystem.Colors.danger
            ) {
                showAddExpense = true
                showMenu = false
            }

            fabMenuButton(
                title: "Add Income",
                icon: "arrow.down.circle.fill",
                color: DesignSystem.Colors.success
            ) {
                showAddIncome = true
                showMenu = false
            }
        }
    }
    
    private func fabMenuButton(
        title: String,
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.md) {
                Text(title)
                    .font(DesignSystem.Typography.bodyMedium)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                ZStack {
                    Circle()
                        .fill(color)
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .font(DesignSystem.Typography.bodySmall)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.textOnPrimary)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                    .fill(DesignSystem.Colors.cardBackground)
                    .shadow(color: DesignSystem.Shadows.medium.color, radius: DesignSystem.Shadows.medium.radius, x: DesignSystem.Shadows.medium.x, y: DesignSystem.Shadows.medium.y)
            )
        }
        .transition(.move(edge: .trailing).combined(with: .opacity))
    }
}
