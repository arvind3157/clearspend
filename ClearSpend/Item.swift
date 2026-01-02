//
//  Item.swift
//  ClearSpend
//
//  Created by Arvind Pandey on 02/01/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
