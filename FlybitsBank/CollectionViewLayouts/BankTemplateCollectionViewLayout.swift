//
//  BankTemplateCollectionViewLayout.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-07-19.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import UIKit
/*
class BankTemplateCollectionViewLayout: UICollectionViewFlowLayout {

    // MARK: - Constants
    struct Constants {
        static let Cell = "CollectionViewCell"
        static let SupplementaryView = "SupplementaryView"
        static let DecorationView = "DecorationView"
        static let MaxServices = 4
    }

    // MARK: - Properties
    var insets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    var itemSizes: [CollectionViewSection : CGSize] = [
        .Accounts : CGSize(width: 600, height: 70),
        .Services : CGSize(width: 105, height: 105),
        .Banner : CGSize(width: 600, height: 300)
    ]

    private var totalHeight: CGFloat = 0
    private var layoutInformation = [String : [NSIndexPath : UICollectionViewLayoutAttributes]]()

    // MARK: - Lifecycle Functions
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Functions
    func headerLayoutForSection(section: Int) -> (attributes: UICollectionViewLayoutAttributes, height: CGFloat) {
        let indexPath = NSIndexPath(forItem: 0, inSection: section)
        let result = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: MainViewController.Constants.HeaderReuseIdentifier, withIndexPath: indexPath)
        guard let collectionView = collectionView else {
            return (attributes: result, height: totalHeight)
        }

        var size = CGSize(width: collectionView.frame.width, height: 0)
        switch section {
        case CollectionViewSection.Accounts.rawValue, CollectionViewSection.Services.rawValue:
            size.height = 50
        case CollectionViewSection.Banner.rawValue:
            size.height = 10

        default:
            break
        }

        let origin = CGPoint(x: 0, y: totalHeight)
        result.frame = CGRect(origin: origin, size: size)

        return (attributes: result, height: origin.y + size.height)
    }

    func layoutForSection(section: Int) -> (attributes: [NSIndexPath : UICollectionViewLayoutAttributes], height: CGFloat) {
        var result = [NSIndexPath : UICollectionViewLayoutAttributes]()
        var height: CGFloat = totalHeight
        guard let collectionView = collectionView else {
            return (attributes: result, height: height)
        }

        let itemCount = collectionView.numberOfItemsInSection(section)
        for index in 0 ..< itemCount {
            let indexPath = NSIndexPath(forItem: index, inSection: section)
            let attribute = attributeForIndexPath(indexPath, yPosition: height, itemCount: CGFloat(itemCount))
            height = attribute.frame.maxY
            result[indexPath] = attribute
        }
        return (attributes: result, height: height)
    }

    func attributeForIndexPath(indexPath: NSIndexPath, yPosition: CGFloat, itemCount: CGFloat) -> UICollectionViewLayoutAttributes {
        let attribute = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        switch indexPath.section {
        case CollectionViewSection.Accounts.rawValue:
            return accountAttributeFromBaseAttribute(attribute, yPosition: yPosition)
        case CollectionViewSection.Services.rawValue:
            return serviceAttributeFromBaseAttribute(attribute, yPosition: yPosition, itemCount: itemCount)
        case CollectionViewSection.Banner.rawValue:
            return bannerAttributeFromBaseAttribute(attribute, yPosition: yPosition)

        default:
            return attribute
        }
    }

    func accountAttributeFromBaseAttribute(attribute: UICollectionViewLayoutAttributes, yPosition: CGFloat) -> UICollectionViewLayoutAttributes {
        attribute.frame = CGRect(x: 0, y: yPosition, width: collectionView?.frame.width ?? itemSizes[.Accounts]!.width, height: itemSizes[.Accounts]!.height)
        print("ACC #\(attribute.indexPath.item): \(attribute.frame)")

        return attribute
    }

    // Attempt to evenly lay out the items from the center
    // [  0 0 0  ] = [ (|) (|) (|) ] (divide into 3 sections and center on the middle-ish area)
    // [ 0 0 0 0 ] = [ 0 | 0 | 0 | 0 ] (divide into 3 sections and center)
    func serviceAttributeFromBaseAttribute(attribute: UICollectionViewLayoutAttributes, yPosition: CGFloat, itemCount: CGFloat) -> UICollectionViewLayoutAttributes {
        guard let collectionView = collectionView else {
            return attribute // Can't adjust anything if there's no collection view
        }

        // Place items off-screen for now
        guard attribute.indexPath.item < Constants.MaxServices else {
            let origin = CGPoint(x: collectionView.frame.width + itemSizes[.Services]!.width, y: yPosition - itemSizes[.Services]!.height)
            attribute.frame = CGRect(origin: origin, size: itemSizes[.Services]!)
            return attribute
        }

        let itemCount = min(itemCount, 4) // TODO: (TL) check what state the UI is in
        let widthBetweenItems = (collectionView.frame.width - insets.left - insets.right) / itemCount
        let initialOffset = widthBetweenItems / 2
        let x = initialOffset + CGFloat(attribute.indexPath.item) * widthBetweenItems - itemSizes[.Services]!.width / 2
        let y = attribute.indexPath.item == 0 ? yPosition : yPosition - itemSizes[.Services]!.height
        attribute.frame = CGRect(x: x, y: y, width: itemSizes[.Services]!.width, height: itemSizes[.Services]!.height)
        print("SVC #\(attribute.indexPath.item): \(attribute.frame)")
        return attribute
    }

    func bannerAttributeFromBaseAttribute(attribute: UICollectionViewLayoutAttributes, yPosition: CGFloat) -> UICollectionViewLayoutAttributes {
        let origin = CGPoint(x: 0, y: yPosition)
        let size = CGSize(width: collectionView?.frame.width ?? itemSizes[.Banner]!.width, height: itemSizes[.Banner]!.height)
        attribute.frame = CGRect(origin: origin, size: size)
        print("BNR #\(attribute.indexPath.item): \(attribute.frame)")
        return attribute
    }

    // MARK: - UICollectionViewLayout Functions
    override func prepareLayout() {
        layoutInformation.removeAll()
        totalHeight = 0
        var supplementaryInformation = [NSIndexPath : UICollectionViewLayoutAttributes]()
        for section in 0 ..< CollectionViewSection.Count.rawValue {
            // Set up header for section
            let headerDetails = headerLayoutForSection(section)
            let indexPath = NSIndexPath(forItem: 0, inSection: section)
            supplementaryInformation[indexPath] = headerDetails.attributes
            totalHeight = headerDetails.height

            // Set up cells for section
            let details = layoutForSection(section)
            layoutInformation[CollectionViewSection(rawValue: section)!.reuseIdentifier] = details.attributes
            totalHeight = details.height
        }
        layoutInformation[Constants.SupplementaryView] = supplementaryInformation
    }

    override func collectionViewContentSize() -> CGSize {
        return CGSize(width: collectionView?.frame.width ?? 0, height: totalHeight)
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

    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = layoutInformation[elementKind]?[indexPath] else {
            return nil
        }
        return attributes
    }
}
*/
