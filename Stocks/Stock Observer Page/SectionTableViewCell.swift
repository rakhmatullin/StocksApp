//
//  SectionTableViewCell.swift
//  Stocks
//
//  Created by Ренат Рахматуллин on 09.03.2021.
//

import UIKit

class SectionTableViewCell: UITableViewCell {
    static let identifier = "SectionCell"
    
    var nameLabel = UILabel()
    var descriptionLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        cellInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        cellInit()
    }
    
    private func cellInit() {
        contentView.backgroundColor = .white
        
        setupNameLabel()
        setupDescriptionLabel()
    }
    
    private func setupNameLabel() {
        contentView.addSubview(nameLabel)
        
        nameLabel.font = .boldSystemFont(ofSize: 24)
        nameLabel.textColor = .black
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }
    
    private func setupDescriptionLabel() {
        contentView.addSubview(descriptionLabel)
        
        descriptionLabel.font = .systemFont(ofSize: 20)
        descriptionLabel.textColor = .black
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 15).isActive = true
        descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
    }
}
