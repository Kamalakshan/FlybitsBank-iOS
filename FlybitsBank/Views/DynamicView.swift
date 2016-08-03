//
//  DynamicView.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-08-02.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import UIKit

protocol ComponentMapper {
    func map(value: String, to view: UIView)
}

class DynamicView: UIView {

}

// MARK: - ComponentConfigurable Functions
extension DynamicView: ComponentConfigurable {
    func updateFromProperties(properties: [Component.Property : String], mappings: [Component.Property : Int]) {
        for (property, value) in properties {
            guard let tag = mappings[property], view = viewWithTag(tag) else {
                continue
            }
            property.componentMapper.map(value, to: view)
        }
    }
}
