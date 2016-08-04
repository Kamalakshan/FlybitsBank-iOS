//
//  DynamicView.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-08-02.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import UIKit

protocol DynamicViewActionDelegate {
    func dynamicView(dynamicView: DynamicView, gestureRecognized gestureRecognizer: UIGestureRecognizer)
}

class DynamicView: UIView {
    // MARK: - Properties
    var delegate: DynamicViewActionDelegate?

    // MARK: - Functions
    func updateFromProperties(properties: [Component.Property : String], mappings: [Component.Property : Int]) {
        for (property, value) in properties {
            guard let tag = mappings[property], view = viewWithTag(tag) else {
                continue
            }
            property.map(value, to: view)
        }
    }

    // MARK: - UIActions
    func onGestureRecognized(sender: AnyObject) {
        guard let gestureRecognizer = sender as? UIGestureRecognizer else {
            return // Nothing we can do for now [TODO: (TL) ?]
        }
        delegate?.dynamicView(self, gestureRecognized: gestureRecognizer)
    }
}
