//
//  ListsObeserverVC.swift
//  Stocks
//
//  Created by Ренат Рахматуллин on 18.03.2021.
//

import UIKit
import LZViewPager

class ListsObeserverVC: UIViewController {
    
    private var viewPager = LZViewPager()
    private var subControllers: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMainView()
        setupViewPager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupMainView() {
        view.backgroundColor = .white
    }
    
    private func setupViewPager() {
        view.addSubview(viewPager)
        setupViewPagerConstraints()
        
        viewPager.dataSource = self
        viewPager.delegate = self
        viewPager.hostController = self
        
        let board = UIStoryboard(name: "Main", bundle: nil)
        
        let allStocksVC = board.instantiateViewController(withIdentifier: "AllStocksVC")
        allStocksVC.title = "Stocks"
        
        let favoriteStocksVC = board.instantiateViewController(withIdentifier: "AllStocksVC") as! StocksListVC
        favoriteStocksVC.showFavoritesOnly = true
        favoriteStocksVC.title = "Favorite"
        
        subControllers = [allStocksVC, favoriteStocksVC]
        viewPager.reload()
    }
    
    private func setupViewPagerConstraints() {
        viewPager.translatesAutoresizingMaskIntoConstraints = false
        viewPager.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        viewPager.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        viewPager.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        viewPager.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    }

}


extension ListsObeserverVC: LZViewPagerDataSource, LZViewPagerDelegate {
    
    // LZViewPagerDataSource
    
    func numberOfItems() -> Int { self.subControllers.count }
    
    func controller(at index: Int) -> UIViewController { subControllers[index] }
    
    func button(at index: Int) -> UIButton {
        let button = UIButton()
        let title = self.subControllers[index].title ?? "Title"
        let norAttrStr = NSAttributedString(string: title, attributes:
                                                [NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                                                 NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)])
        let selAttrStr = NSAttributedString(string: title, attributes:
                                                [NSAttributedString.Key.foregroundColor: UIColor.black,
                                                 NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)])
        button.setAttributedTitle(norAttrStr, for: .normal)
        button.setAttributedTitle(selAttrStr, for: .selected)
        return button
    }
    
    // LZViewPagerDelegate
    
    func backgroundColorForHeader() -> UIColor { .white }
    
    func shouldShowSeparator() -> Bool { false }
    // func topMarginForSeparator() -> CGFloat { 0 }
    // func heightForSeparator() -> CGFloat { 10 }
    // func colorForSeparator() -> UIColor { .white }
    
    func shouldShowIndicator() -> Bool { false }
    
    func shouldEnableSwipeable() -> Bool { true }
}
