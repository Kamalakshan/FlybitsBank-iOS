//
//  ImagePropertyMapper.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-08-02.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import UIKit

struct ImagePropertyMapper: PropertyMapper {
    static func map(value: String, to view: UIView) {
        if let imageView = view as? UIImageView {
            if let image = UIImage(named: value) {
                Utilities.transitionImage(imageView, image: image)
            } else if let imageURL = NSURL(string: value) {
                Utilities.loadAndCrossfadeImage(imageView, imageURL: imageURL)
            }
        }
    }
}
