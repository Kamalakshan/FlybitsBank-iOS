//
//  InsetFlowLayout.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-08-05.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import UIKit

class InsetFlowLayout: UICollectionViewFlowLayout {
    // MARK: - Properties
    var cellInsets = CGSize.zero
    private var layoutInformation = [String : [NSIndexPath : UICollectionViewLayoutAttributes]]()

    // MARK: - UICollectionViewLayout Functions
    override func prepareLayout() {
        layoutInformation.removeAll()

        let sectionCount = collectionView?.numberOfSections() ?? 0
        for section in 0 ..< sectionCount {
            layoutInformation[CollectionViewSection(rawValue: section)!.reuseIdentifier] = layoutForSection(section)
        }
    }

    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = [UICollectionViewLayoutAttributes]()
        for (_, layouts) in layoutInformation {
            for (_, attribute) in layouts {
                if rect.intersects(attribute.frame) {
                    attributes.append(attribute)
                }
            }
        }
        return attributes
    }

    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        guard let section = CollectionViewSection(rawValue: indexPath.section) else {
            return nil
        }
        return layoutInformation[section.reuseIdentifier]?[indexPath]
    }

    // MARK: - Helper Functions
    private func layoutForSection(section: Int) -> [NSIndexPath : UICollectionViewLayoutAttributes] {
        var result = [NSIndexPath : UICollectionViewLayoutAttributes]()
        guard let collectionView = collectionView else {
            return result
        }

        let itemCount = collectionView.numberOfItemsInSection(section)
        for index in 0 ..< itemCount {
            let indexPath = NSIndexPath(forItem: index, inSection: section)
            guard let attributes = super.layoutAttributesForItemAtIndexPath(indexPath) else {
                continue // TODO: (TL) ...
            }
            attributes.frame = attributes.frame.insetBy(dx: cellInsets.width, dy: cellInsets.height)
            result[indexPath] = attributes
        }
        return result
    }
}
