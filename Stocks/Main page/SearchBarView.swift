//
//  SearchBarView.swift
//  Stocks
//
//  Created by Ренат Рахматуллин on 17.03.2021.
//

import UIKit

class SearchBarView: UICollectionReusableView {
    static let identifier = "SearchBarView"
    
    var searchBar: UISearchBar!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.searchBarViewInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.searchBarViewInit()
    }
    
    private func searchBarViewInit() {
        searchBar = UISearchBar(frame: self.frame)
        searchBar.placeholder = "Find company or ticker"
        searchBar.barTintColor = .white
        searchBar.layoutMargins = .init(top: 0, left: 20, bottom: 0, right: 20)
        self.addSubview(searchBar)
    }
}
