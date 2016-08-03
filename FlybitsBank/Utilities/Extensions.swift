//
//  Extensions.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-07-20.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import UIKit

extension UIImage {
    static func image(with color: UIColor) -> UIImage {
        let size = CGSize(width: 1, height: 1)
        let rect = CGRect(origin: CGPoint.zero, size: size)

        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
}

extension UICollectionView {
    func reloadAllSections() {
        let range = NSRange(location: 0, length: numberOfSections())
        let sections = NSIndexSet(indexesInRange: range)

        reloadSections(sections)
    }
}

extension String {
    var uiColor: UIColor? {
        let scanner = NSScanner(string: self)
        if self.hasPrefix("#") {
            scanner.scanLocation = 1 // Skip the #
        }
        var hexColor: UInt32 = 0
        if scanner.scanHexInt(&hexColor) {
            let red = CGFloat((hexColor & 0xFF000000) >> 24)/255.0
            let green = CGFloat((hexColor & 0xFF0000) >> 16)/255.0
            let blue = CGFloat((hexColor & 0xFF00) >> 8)/255.0
            let alpha = CGFloat((hexColor & 0xFF) >> 0)/255.0

            return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
        return nil
    }
}

extension NSLocale {
    var iso639String: String {
        guard let value = objectForKey(NSLocaleLanguageCode) as? String else {
            return "en"
        }
        return value
    }
}
