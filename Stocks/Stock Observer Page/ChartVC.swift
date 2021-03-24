//
//  ChartVC.swift
//  Stocks
//
//  Created by Ренат Рахматуллин on 06.03.2021.
//

import UIKit
import Charts

class ChartVC: UIViewController, ChartViewDelegate {
    var stock: Stock!
    var stockQuote: FinnhubAPI.StockQuote!

    private var costLabel: UILabel!
    private var dateLabel: UILabel!
    
    private var chart: LineChartView!
    private var dataSet: LineChartDataSet!
    private var allChartEntries: [ChartDataEntry]!
    private var finnhubResolution: FinnhubResolutionOption!
    
    private var intervalButtons: [UIButton]!
    private var intervalButtonsStackView: UIStackView!
    
    private enum ChartInterval: String, CaseIterable {
        case day            = "D"
        case week           = "W"
        case month          = "M"
        case sixMonths      = "6M"
        case year           = "1Y"
        case all            = "All"
    }
    
    private enum FinnhubResolutionOption: String {
        case minute         = "1"
        case fiveMinutes    = "5"
        case fifteenMinutes = "15"
        case thirtyMinutes  = "30"
        case sixtyMinutes   = "60"
        case day            = "D"
        case week           = "W"
        case month          = "M"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        addChartView()
        addCostLabel()
        addDateLabel()
        addIntervalButtons()
        
        fetchStockCandles()
    }
    
    override func viewDidLayoutSubviews() {
        setCostLabelConstraints()
        setDateLabelConstraints()
        setChartConstraints()
        setIntervalButtonsConstraints()
    }
    
    private func addChartView() {
        chart = LineChartView()
        chart.backgroundColor = .white
        chart.tintColor = .systemGreen
        
        chart.noDataTextColor = .black
        chart.noDataText = "Loading chart for \"\(stock.name.capitalized)\""
        chart.noDataFont = .boldSystemFont(ofSize: 10)
        
        chart.xAxis.enabled = false
        chart.leftAxis.enabled = false
        chart.rightAxis.enabled = false
        
        chart.scaleYEnabled = false
        chart.doubleTapToZoomEnabled = false
        
        chart.delegate = self
        view.addSubview(chart)
    }
    
    private func addCostLabel() {
        costLabel = UILabel()
        costLabel.font = UIFont(name: "Arial Bold", size: 32.0)
        costLabel.textColor = .black
        costLabel.textAlignment = .center
        costLabel.text = (stockQuote != nil) ? ("$" + String(stockQuote.currentPrice)) : "No cost"
        view.addSubview(costLabel)
    }
    
    private func addDateLabel() {
        dateLabel = UILabel()
        dateLabel.font = UIFont(name: "Arial", size: 20.0)
        dateLabel.textColor = .black
        dateLabel.textAlignment = .center
        view.addSubview(dateLabel)
    }
    
    private func addIntervalButtons() {
        intervalButtons = []
        
        for interval in ChartInterval.allCases {
            let button = UIButton()
            button.backgroundColor = .clear
            button.setTitleColor(.black, for: .normal)
            button.setTitle(interval.rawValue, for: .normal)
            button.layer.cornerRadius = 10
            button.layer.borderWidth = 0
            button.layer.borderColor = UIColor.black.cgColor
            // button.addTarget(self, action: #selector(intervalButtonTouchUpInside), for: .touchUpInside)
            
            intervalButtons.append(button)
        }
        
        // -- First 3 buttons are available but last 3 buttons are API limits alerts.
        intervalButtons[0].addTarget(self, action: #selector(intervalButtonTouchUpInside), for: .touchUpInside)
        intervalButtons[1].addTarget(self, action: #selector(intervalButtonTouchUpInside), for: .touchUpInside)
        intervalButtons[2].addTarget(self, action: #selector(intervalButtonTouchUpInside), for: .touchUpInside)
        
        intervalButtons[2].backgroundColor = #colorLiteral(red: 0.8864082694, green: 0.8902869821, blue: 0.8942552209, alpha: 1)
        
        intervalButtons[3].addTarget(self, action: #selector(showLimitsAlerts), for: .touchUpInside)
        intervalButtons[4].addTarget(self, action: #selector(showLimitsAlerts), for: .touchUpInside)
        intervalButtons[5].addTarget(self, action: #selector(showLimitsAlerts), for: .touchUpInside)
        // --
        
        intervalButtonsStackView = UIStackView(arrangedSubviews: intervalButtons)
        intervalButtonsStackView.axis = .horizontal
        intervalButtonsStackView.distribution = .fillEqually
        intervalButtonsStackView.alignment = .fill
        
        view.addSubview(intervalButtonsStackView)
    }
    
    @objc private func showLimitsAlerts() {
        let alert = UIAlertController(title: "API limits",
                                      message: "Maximum time interval due to free API limits: 1 month",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func intervalButtonTouchUpInside(sender: UIButton!) {
        guard allChartEntries != nil, !allChartEntries.isEmpty else { return }
        
        intervalButtons.forEach { $0.backgroundColor = .clear }
        sender.backgroundColor = #colorLiteral(red: 0.8864082694, green: 0.8902869821, blue: 0.8942552209, alpha: 1)
        
        guard let title = sender.currentTitle, let interval = ChartInterval(rawValue: title)
        else { fatalError("Non existing interval")}
        
        setupShownDataSet(for: interval)
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        costLabel.text = "$" + String(entry.y)
        if let date = entry.data as? Double {
            dateLabel.text = date.convertUnixTimestampToDate()
        }
    }
    
    private func setupShownDataSet(for interval: ChartInterval) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let pointsNumberToDraw = 40
            
            var dateFrom: Date!
            switch interval {
            case .day:       dateFrom = Calendar.current.date(byAdding: .day,           value: -1,  to: Date())
            case .week:      dateFrom = Calendar.current.date(byAdding: .weekOfYear,    value: -1,  to: Date())
            case .month:     dateFrom = Calendar.current.date(byAdding: .month,         value: -1,  to: Date())
            case .sixMonths: dateFrom = Calendar.current.date(byAdding: .month,         value: -6,  to: Date())
            case .year:      dateFrom = Calendar.current.date(byAdding: .year,          value: -1,  to: Date())
            case .all:       dateFrom = Calendar.current.date(byAdding: .year,          value: -10, to: Date())
            }
            let TimestampFrom = Int(dateFrom.timeIntervalSince1970)
            
            let firstAppropriateIndex: Int = self.allChartEntries.firstIndex { TimestampFrom <= Int($0.x) } ?? 0
            let endAppropriateIndex: Int = self.allChartEntries.endIndex
            
            let entriesInInterval = self.allChartEntries[firstAppropriateIndex..<endAppropriateIndex]
            
            let resolution = entriesInInterval.count > pointsNumberToDraw ?
                entriesInInterval.count / pointsNumberToDraw : 1
            
            let entriesToShow = entriesInInterval.enumerated().compactMap
                { $0.offset.isMultiple(of: resolution) ? $0.element : nil }
            
            let evenlyDistributedEntries = entriesToShow.enumerated().map
                { ChartDataEntry(x: Double($0.offset), y: $0.element.y, data: $0.element.x) }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.dataSet.replaceEntries(evenlyDistributedEntries)
                self.chart.data = LineChartData(dataSet: self.dataSet)
            }
        }
    }
    
    func setupDataSet(xValues: [Int], yValues: [Double]) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            guard xValues.count == yValues.count else { fatalError() }
            
            var entries: [ChartDataEntry] = []
            
            for (i, value) in yValues.enumerated() {
                entries.append(ChartDataEntry(x: Double(xValues[i]), y: value))
            }
            
            self.allChartEntries = entries
            
            self.dataSet = LineChartDataSet()
            self.dataSet.drawCirclesEnabled = false
            self.dataSet.mode = .cubicBezier
            self.dataSet.setColor(NSUIColor.black)
            self.dataSet.label = self.stock.name.capitalized
            self.dataSet.drawValuesEnabled = false
            self.dataSet.highlightColor = .lightGray
            self.dataSet.drawHorizontalHighlightIndicatorEnabled = false
            self.dataSet.fillColor = .black
            self.dataSet.lineWidth = 1.5
            self.dataSet.fillAlpha = 0.1
            self.dataSet.drawFilledEnabled = true
            let gradient: CGGradient! = CGGradient(
                colorsSpace: nil,
                colors: [UIColor.white.cgColor, UIColor.black.cgColor] as CFArray,
                locations: [0.0, 1]
            )
            self.dataSet.fill = Fill.fillWithLinearGradient(gradient, angle: 90)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                let interval = ChartInterval.month
                
                self.setupShownDataSet(for: interval)
            }
        }
    }
    
    func fetchStockCandles() {
        let symbol = stock.symbol
        
        let TimestampFrom = Int(Calendar.current.date(byAdding: .month, value: -1, to: Date())!.timeIntervalSince1970)
        let TimestampTo = Int(Date().timeIntervalSince1970)
        
        finnhubResolution = FinnhubResolutionOption.fifteenMinutes
        
        // https://finnhub.io/api/v1/stock/candle?symbol=AAPL&resolution=15&from=1605543327&to=1605629727&token=TOKEN
        guard let url = URL.buildWithComponents(scheme: "https",
                                                host: "finnhub.io",
                                                path: "/api/v1/stock/candle",
                                                queryItems: ["symbol": symbol,
                                                             "resolution": finnhubResolution.rawValue,
                                                             "from": String(TimestampFrom),
                                                             "to": String(TimestampTo),
                                                             "token": Config.finnhubToken])
        else { fatalError("URL is constructed unsuccessfully") }
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else {
                DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 5) {
                    self.fetchStockCandles()
                }
                return
            }
            
            var candleJSON: FinnhubAPI.StockCandles
            do {
                candleJSON = try JSONDecoder().decode(FinnhubAPI.StockCandles.self, from: data)
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
                DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 5) {
                    self.fetchStockCandles()
                }
                return
            }
            
            DispatchQueue.main.async {
                self.setupDataSet(xValues: candleJSON.timestamps, yValues: candleJSON.closePrices)
            }
        }
        
        task.resume()
    }
}

extension ChartVC {
    func setCostLabelConstraints() {
        guard let navigationController = navigationController else { return }
        
        costLabel.translatesAutoresizingMaskIntoConstraints = false
        costLabel.topAnchor.constraint(equalTo: navigationController.navigationBar.bottomAnchor,
                                       constant: 80).isActive = true
        costLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        costLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        costLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
    }
    
    func setDateLabelConstraints() {
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.topAnchor.constraint(equalTo: costLabel.bottomAnchor, constant: 10).isActive = true
        dateLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
    }
    
    func setChartConstraints() {
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 0).isActive = true
        chart.heightAnchor.constraint(equalToConstant: 300).isActive = true
        chart.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        chart.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
    }
    
    func setIntervalButtonsConstraints() {
        intervalButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        intervalButtonsStackView.topAnchor.constraint(equalTo: chart.bottomAnchor, constant: 10).isActive = true
        intervalButtonsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        intervalButtonsStackView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true
        intervalButtonsStackView.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
}
