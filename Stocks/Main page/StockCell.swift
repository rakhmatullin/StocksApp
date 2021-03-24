//
//  StockCell.swift
//  Stocks
//
//  Created by Ренат Рахматуллин on 01.03.2021.
//

import UIKit
import SDWebImage

class StockCell: UICollectionViewCell {
    static let identifier = "StockCell"
    
    var isFavorite: Bool = false {
        didSet {
            setupSymbolNameLabels(favorite: isFavorite)
        }
    }
    
    private var stock: Stock! {
        didSet {
            setupSymbolNameLabels()
            setupImage()
        }
    }
    
    private var quote: FinnhubAPI.StockQuote! {
        didSet {
            setupCostLabels()
        }
    }
    
    private var logoView: UIImageView!
    private var symbolLabel: UILabel!
    private var companyNameLabel: UILabel!
    private var costLabel: UILabel!
    private var costChangeLabel: UILabel!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        cellInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        cellInit()
    }
    
    override func layoutSubviews() {
        setupSubviewsFrames()
    }
    
    private func cellInit() {
        self.layer.cornerRadius = 15.0
        self.layer.masksToBounds = true
        
        addImage()
        addSymbolLabel()
        addCompanyNameLabel()
        addCostLabel()
        addCostChangeLabel()
    }
    
    func setupStock(with stock: Stock, favorite: Bool) {
        self.stock = stock
        self.isFavorite = favorite
    }
    
    func setupQuote(with quote: FinnhubAPI.StockQuote) {
        self.quote = quote
    }
    
    private func addImage() {
        logoView = UIImageView()
        logoView.layer.cornerRadius = 15.0
        logoView.clipsToBounds = true
        contentView.addSubview(logoView)
    }
    
    private func addSymbolLabel() {
        symbolLabel = UILabel()
        symbolLabel.text = "AAA"
        symbolLabel.textColor = .black
        symbolLabel.font = UIFont(name: "Arial Bold", size: 20)
        contentView.addSubview(symbolLabel)
    }
    
    private func addCompanyNameLabel() {
        companyNameLabel = UILabel()
        companyNameLabel.text = "Company"
        companyNameLabel.textColor = .black
        companyNameLabel.font = UIFont(name: "Arial", size: 13)
        contentView.addSubview(companyNameLabel)
    }
    
    private func addCostLabel() {
        costLabel = UILabel()
        costLabel.text = "$$$"
        costLabel.textColor = .black
        costLabel.font = UIFont(name: "Arial Bold", size: 20)
        costLabel.textAlignment = .right
        contentView.addSubview(costLabel)
    }
    private func addCostChangeLabel() {
        costChangeLabel = UILabel()
        costChangeLabel.text = "$$$"
        costChangeLabel.font = UIFont(name: "Arial", size: 13)
        costChangeLabel.textColor = .black
        costChangeLabel.textAlignment = .right
        contentView.addSubview(costChangeLabel)
    }
    
    private func setupImage() {
        logoView.sd_setImage(with: URL(string: "https://finnhub.io/api/logo?symbol=\(stock.symbol)"),
                               completed: { (image, error, type, url) in
            if let image = self.logoView.image {
                self.logoView.contentMode = .center
                if self.logoView.bounds.size.width < image.size.width ||
                    self.logoView.bounds.size.height < image.size.height {
                    self.logoView.contentMode = .scaleAspectFit
                }
            } else {
                self.logoView.contentMode = .scaleAspectFit
                self.logoView.image = UIImage(named: "stonk")
            }
               
        })
    }
    
    private func setupSymbolNameLabels(favorite: Bool = false) {
        let symbolPart = stock.symbol
        let symbolPartAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black]
        let attributedSymbolPart = NSAttributedString(string: symbolPart, attributes: symbolPartAttributes)
        
        let starPart = " ★"
        let starPartAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: isFavorite ? #colorLiteral(red: 1, green: 0.7927889228, blue: 0.1083463505, alpha: 1) : #colorLiteral(red: 0.7293394804, green: 0.7294487357, blue: 0.7293244004, alpha: 1)]
        let attributedStarPart = NSAttributedString(string: starPart, attributes: starPartAttributes)
        symbolLabel.attributedText = attributedSymbolPart + attributedStarPart
        
        companyNameLabel.text = stock.name.capitalized
    }
    
    private func setupCostLabels() {
        let openPrice = quote.openPrice
        let currentPrice = quote.currentPrice
        let currency = "$" // get currency from company profile
        
        costLabel.text = currency + String(quote.currentPrice.rounded(toPlaces: 2))
        
        let difference = (currentPrice - openPrice).rounded(toPlaces: 2)
        let positiveDifference = abs(difference)
        let isPositive = difference >= 0 ? true : false
        let sign = isPositive ? "+" : "-"
        let percents = openPrice > 0 ? (positiveDifference / openPrice).rounded(toPlaces: 2) : 0
        let percentsString = percents > 0 ? String(percents) : "<0.01"
        
        costChangeLabel.text = sign + currency + String(positiveDifference) + " (" + percentsString + "%)"
        costChangeLabel.textColor = isPositive ? .systemGreen : .systemRed
    }
    
    private func setupSubviewsFrames() {
        let h = contentView.frame.size.height
        let w = contentView.frame.size.width
        
        let imageWidth = 3 * h / 4, imageHeight = 3 * h / 4, imageXOffset = w / 30, imageYOffset = h / 8
        logoView.frame = CGRect(x: imageXOffset, y: imageYOffset, width: imageWidth, height: imageHeight)
        
        let symbolXOffset = imageXOffset + imageWidth + w / 30, symbolYOffset = h / 4
        let symbolWidth = 20 * w / 30 - symbolXOffset, symbolHeight = h / 4
        symbolLabel.frame = CGRect(x: symbolXOffset, y: symbolYOffset,
                                        width: symbolWidth, height: symbolHeight)
            
        let nameWidth = symbolWidth, nameHeight = symbolHeight
        let nameXOffset = symbolXOffset, nameYOffset = 9 * h / 16
        companyNameLabel.frame = CGRect(x: nameXOffset, y: nameYOffset,
                                        width: nameWidth, height: nameHeight)
        
        let costWidth = 13 * w / 30, costHeight = symbolHeight
        let costXOffset = w / 2, costYOffset = symbolYOffset
        costLabel.frame = CGRect(x: costXOffset, y: costYOffset,
                                        width: costWidth, height: costHeight)
        
        let changeWidth = costWidth, changeHeight = symbolHeight
        let changeXOffset = costXOffset, changeYOffset = nameYOffset
        costChangeLabel.frame = CGRect(x: changeXOffset, y: changeYOffset,
                                        width: changeWidth, height: changeHeight)
    }
}

extension Double {
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString
{
    let result = NSMutableAttributedString()
    result.append(left)
    result.append(right)
    return result
}
