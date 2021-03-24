//
//  StockObserverVC.swift
//  Stocks
//
//  Created by Ренат Рахматуллин on 01.03.2021.
//

import UIKit
import LZViewPager

class StockObserverVC: UIViewController {
    var stock: Stock!
    var stockQuote: FinnhubAPI.StockQuote!
    
    @IBOutlet var viewPager: LZViewPager!
    private var subControllers: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMainView()
        addFavoriteBarButton()
        addViewPager()
    }
    
    private func setupMainView() {
        view.backgroundColor = .white
        navigationItem.title = stock.symbol
    }
    
    private func addFavoriteBarButton() {
        let defaults = UserDefaults.standard
        let favoriteArray = defaults.object(forKey: UserDefaultsKey.favoritesKey) as? [String] ?? [String]()
        let isFavorite = favoriteArray.contains(stock.symbol)
        
        let starAttributes: [NSAttributedString.Key: Any] =
            [.foregroundColor: isFavorite ? #colorLiteral(red: 1, green: 0.7927889228, blue: 0.1083463505, alpha: 1) : #colorLiteral(red: 0.7293394804, green: 0.7294487357, blue: 0.7293244004, alpha: 1), .font: UIFont.boldSystemFont(ofSize: 20)]
        let item = UIBarButtonItem(title: "★", style: .plain, target: self, action: #selector(toggleFavoriteBarButton))
        item.setTitleTextAttributes(starAttributes, for: .normal)
        
        navigationItem.rightBarButtonItem = item
    }
    
    @objc private func toggleFavoriteBarButton() {
        let defaults = UserDefaults.standard
        var favoriteArray = defaults.object(forKey: UserDefaultsKey.favoritesKey) as? [String] ?? [String]()
        let wasFavorite = favoriteArray.contains(stock.symbol)
        
        if wasFavorite {
            favoriteArray.removeAll { $0 == stock.symbol }
        } else {
            favoriteArray.append(stock.symbol)
        }
        
        defaults.setValue(favoriteArray, forKey: UserDefaultsKey.favoritesKey)
        
        
        let starAttributes: [NSAttributedString.Key: Any] =
            [.foregroundColor: wasFavorite ? #colorLiteral(red: 0.7293394804, green: 0.7294487357, blue: 0.7293244004, alpha: 1) : #colorLiteral(red: 1, green: 0.7927889228, blue: 0.1083463505, alpha: 1) , .font: UIFont.boldSystemFont(ofSize: 20)]
        
        let item = UIBarButtonItem(title: "★", style: .plain, target: self, action: #selector(toggleFavoriteBarButton))
        item.setTitleTextAttributes(starAttributes, for: .normal)
        
        navigationItem.rightBarButtonItem = item
        
        NotificationCenter.default.post(name: Notification.Name(NotificationCenterName.FavoriteStocksChange),
                                        object: nil)
    }
    
    private func addViewPager() {
        viewPager.dataSource = self
        viewPager.delegate = self
        viewPager.hostController = self
        
        let board = UIStoryboard(name: "Main", bundle: nil)
        
        let chartVC = board.instantiateViewController(withIdentifier: "ChartVC") as! ChartVC
        chartVC.stock = stock
        chartVC.stockQuote = stockQuote
        chartVC.title = "Chart"
        
        let summaryVC = board.instantiateViewController(withIdentifier: "SummaryVC") as! SummaryVC
        summaryVC.stock = stock
        summaryVC.title = "Summary"
        
        subControllers = [chartVC, summaryVC]
        viewPager.reload()
    }
}


extension StockObserverVC: LZViewPagerDataSource, LZViewPagerDelegate {
    
    // LZViewPagerDataSource
    
    func numberOfItems() -> Int { self.subControllers.count }
    
    func controller(at index: Int) -> UIViewController { subControllers[index] }
    
    func button(at index: Int) -> UIButton {
        let button = UIButton()
        let title = self.subControllers[index].title ?? "Title"
        
        let attributesNormal    =   [NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                                     NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]
        let attributesSelected  =   [NSAttributedString.Key.foregroundColor: UIColor.black,
                                     NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)]
        
        let stringNormal   = NSAttributedString(string: title, attributes: attributesNormal)
        let stringSelected = NSAttributedString(string: title, attributes: attributesSelected)
        
        button.setAttributedTitle(stringNormal, for: .normal)
        button.setAttributedTitle(stringSelected, for: .selected)
        return button
    }
    
    
    // LZViewPagerDelegate
    
    func backgroundColorForHeader() -> UIColor { .white }
    
    func shouldShowSeparator() -> Bool { true }
    func topMarginForSeparator() -> CGFloat { 0 }
    func heightForSeparator() -> CGFloat { 2 }
    func colorForSeparator() -> UIColor { #colorLiteral(red: 0.9528481364, green: 0.952988565, blue: 0.9528290629, alpha: 1) }
    
    func shouldShowIndicator() -> Bool { false }
    
    func shouldEnableSwipeable() -> Bool { false }

}
