//
//  MosaicLayout.swift
//  Stocks
//
//  Created by Ренат Рахматуллин on 01.03.2021.
//

import UIKit

class MosaicLayout: UICollectionViewLayout {
    var contentBounds = CGRect.zero
    var cachedAttributes = [UICollectionViewLayoutAttributes]()
    
    override func prepare() {
        guard  let cv = collectionView else { return }
        
        // Reset cached info
        cachedAttributes.removeAll()
        contentBounds = CGRect(origin: .zero, size: cv.bounds.size)
        
        // for every item
        //  - Prepare attributes
        //  - Store attributes in cachedAttributes array
        //  - union contentBounds with attributes.frame
        //createAttributes()
    }
    
    override var collectionViewContentSize: CGSize {
        return contentBounds.size
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        //guard let cv = collectionView else { return }
        
        //return !newBounds.size.equalTo(cv.bounds.size)
        return false
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttributes[indexPath.item]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cachedAttributes.filter { (attributes: UICollectionViewLayoutAttributes) -> Bool in
            return rect.intersects(attributes.frame)
        }
    }
}
