//
//  TextPropertyMapper.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-08-02.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import UIKit

struct TextPropertyMapper: PropertyMapper {
    static func map(value: String, to view: UIView) {
        if let labelView = view as? UILabel {
            labelView.text = value
        } else if let textView = view as? UITextView {
            textView.text = value
        } // TODO: (TL) other types of views
    }
}
