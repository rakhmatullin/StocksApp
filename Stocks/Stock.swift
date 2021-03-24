//
//  Stock.swift
//  Stocks
//
//  Created by Ренат Рахматуллин on 01.03.2021.
//

import Foundation

struct Stock: Hashable {
    static func == (lhs: Stock, rhs: Stock) -> Bool {
        lhs.symbol == rhs.symbol
    }
    
    let symbol: String
    var name: String = "Company name"
    
    init(symbol: String) {
        self.symbol = symbol
    }
    
    init(symbol: String, name: String) {
        self.symbol = symbol
        self.name = name
    }
    
}
