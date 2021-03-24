//
//  SummaryVC.swift
//  Stocks
//
//  Created by Ренат Рахматуллин on 09.03.2021.
//

import UIKit

class SummaryVC: UIViewController {
    var stock: Stock!
    
    private struct InfoSection {
        var label: String
        var field: String
    }
    
    private var infoSections: [InfoSection] = []
    private let sectionsTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange
        
        setupSectionsTableView()
        fetchInfo()
    }
    
    private func setupSectionsTableView() {
        sectionsTableView.backgroundColor = .white
        
        sectionsTableView.delegate = self
        sectionsTableView.dataSource = self
        sectionsTableView.register(SectionTableViewCell.self, forCellReuseIdentifier: SectionTableViewCell.identifier)
        sectionsTableView.tableFooterView = UIView()
        
        view.addSubview(sectionsTableView)
        
        sectionsTableView.translatesAutoresizingMaskIntoConstraints = false
        sectionsTableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        sectionsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        sectionsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        sectionsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    private func addSection(name: String, description: String) {
        infoSections.append(InfoSection(label: name, field: description))
    }
    
    private func fetchInfo() {
        let symbol = stock.symbol
        
        // https://finnhub.io/api/v1/stock/profile2?symbol=AAPL&token=TOKEN
        guard let url = URL.buildWithComponents(scheme: "https",
                                                host: "finnhub.io",
                                                path: "/api/v1/stock/profile2",
                                                queryItems: ["symbol": symbol,
                                                             "token": Config.finnhubToken])
        else { fatalError("URL is constructed unsuccessfully") }
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else {
                DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 5) {
                    self.fetchInfo()
                }
                return
            }
            
            var companyInfo: FinnhubAPI.CompanyProfile!
            do {
                companyInfo = try JSONDecoder().decode(FinnhubAPI.CompanyProfile.self, from: data)
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
                DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 5) {
                    self.fetchInfo()
                }
                return
            }
            
            self.addSection(name: "Name", description: companyInfo.name)
            self.addSection(name: "Country", description: companyInfo.country)
            self.addSection(name: "IPO date", description: companyInfo.ipo)
            self.addSection(name: "Market Capitalization", description: String(companyInfo.marketCapitalization))
            var phone = companyInfo.phone; phone = phone.hasSuffix(".0") ? String(phone.dropLast(2)) : phone
            self.addSection(name: "Phone", description: phone)
            
            DispatchQueue.main.async {
                self.sectionsTableView.reloadData()
            }
        }
        
        task.resume()
    }
}

extension SummaryVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        infoSections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: SectionTableViewCell.identifier)
        if let sectionCell = cell as? SectionTableViewCell {
            sectionCell.nameLabel.text = infoSections[indexPath.row].label
            sectionCell.descriptionLabel.text = infoSections[indexPath.row].field
        }
        return cell
    }
}
