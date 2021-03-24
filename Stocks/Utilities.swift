//
//  Utilities.swift
//  Stocks
//
//  Created by Ренат Рахматуллин on 22.03.2021.
//

import Foundation

extension URL {
    static func buildWithComponents(scheme: String, host: String, path: String,
                                        queryItems: [String: String]) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = queryItems.map { URLQueryItem(name: $0.key, value: $0.value) }
        return components.url
    }
}

func checkFavoriteSymbol(symbol: String) -> Bool {
    let defaults = UserDefaults.standard
    let favoriteArray = defaults.object(forKey: UserDefaultsKey.favoritesKey) as? [String] ?? [String]()
    return favoriteArray.contains(symbol)
}

extension Double {
    func convertUnixTimestampToDate() -> String {
        let date = Date(timeIntervalSince1970: self)
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeZone = .current
        
        return dateFormatter.string(from: date)
    }
}
