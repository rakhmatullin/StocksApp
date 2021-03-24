//
//  ColumnFlowLayout.swift
//  Stocks
//
//  Created by Ренат Рахматуллин on 01.03.2021.
//

import UIKit

class ColumnFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        guard let cv = collectionView else { return }
        
        self.itemSize = CGSize(width: cv.bounds.inset(by: cv.layoutMargins).size.width - 20, height: 78.0)
        
        self.sectionInset = UIEdgeInsets(top: self.minimumInteritemSpacing, left: 10.0, bottom: 0.0, right: 10.0)
        self.sectionInsetReference = .fromSafeArea

        self.headerReferenceSize = CGSize(width: cv.frame.width, height: 50)
    }
}
