//
//  Operators.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-08-05.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import CoreGraphics

func /(lhs: CGSize, rhs: CGFloat) -> CGSize {
    return CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
}
