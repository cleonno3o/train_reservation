//
//  Item.swift
//  train_reservation
//
//  Created by 주수민 on 8/3/25.
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
