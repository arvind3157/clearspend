//
//  ExpenseFilter.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//


import Foundation

enum ExpenseFilter: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    case year = "Year"

    var id: String { rawValue }
}