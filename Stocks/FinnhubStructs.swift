//
//  StockQuote.swift
//  Stocks
//
//  Created by Ренат Рахматуллин on 11.03.2021.
//

import Foundation

struct FinnhubAPI {
    
    struct StockQuote: Codable {
        var openPrice: Double
        var highPrice: Double
        var lowPrice: Double
        var currentPrice: Double
        var previousClosePrice: Double
        
        private enum CodingKeys: String, CodingKey {
            case openPrice = "o"
            case highPrice = "h"
            case lowPrice = "l"
            case currentPrice = "c"
            case previousClosePrice = "pc"
        }
    }

    struct StockCandles: Codable {
        let closePrices: [Double]
        let highPrices: [Double]
        let lowPrices: [Double]
        let openPrices: [Double]
        let statusResponse: String
        let timestamps: [Int]
        let volumeData: [Double]
        
        enum CodingKeys: String, CodingKey {
            case closePrices = "c"
            case highPrices = "h"
            case lowPrices = "l"
            case openPrices = "o"
            case statusResponse = "s"
            case timestamps = "t"
            case volumeData = "v"
        }
    }

    struct CompanyProfile: Decodable {
        var country: String
        var currency: String
        var exchange: String
        var ipo: String
        var marketCapitalization: Double
        var name: String
        var phone: String
        var shareOutstanding: Double
        var ticker: String
        var weburl: String
        var logo: String
        var finnhubIndustry: String
    }

    struct StockSymbol: Codable {
        let currency: String
        let description: String
        let symbol: String
        let displaySymbol: String
        let type: String
    }
}
