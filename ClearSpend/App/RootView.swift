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
                        Label("Dashboard", systemImage: "house")
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

            // Dimmed background when menu is open
            if showMenu {
                Color.black.opacity(0.15)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showMenu = false
                        }
                    }
            }

            // FAB + Menu
            VStack {
                Spacer()
                HStack {
                    Spacer()

                    VStack(spacing: 12) {

                        if showMenu {
                            fabMenu
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }

                        fabButton
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 32) // 👈 moved up from tab bar
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
            withAnimation {
                showMenu.toggle()
            }
        } label: {
            Image(systemName: "plus")
                .font(.title2.bold())
                .foregroundStyle(.white)
                .rotationEffect(.degrees(showMenu ? 45 : 0))
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(Color.accentColor)
                )
                .shadow(radius: 6)
        }
    }
    
    private var fabMenu: some View {
        VStack(alignment: .trailing, spacing: 12) {

            fabMenuButton(
                title: "Scan Bill",
                icon: "camera.fill"
            ) {
                showScanBill = true
                showMenu = false
            }

            fabMenuButton(
                title: "Add Expense",
                icon: "arrow.up.circle.fill"
            ) {
                showAddExpense = true
                showMenu = false
            }

            fabMenuButton(
                title: "Add Income",
                icon: "arrow.down.circle.fill"
            ) {
                showAddIncome = true
                showMenu = false
            }
        }
    }
    
    private func fabMenuButton(
        title: String,
        icon: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.primary)

                Image(systemName: icon)
                    .foregroundStyle(.primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemBackground))
            )
            .shadow(radius: 2)
        }
    }
}
