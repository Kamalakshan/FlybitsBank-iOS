//
//  Branch.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-07-26.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import Foundation

struct Branch: Equatable, Hashable {
    // MARK: - Properties
    let identifier: String
    let name: String

    // MARK: - Hashable Properties
    var hashValue: Int {
        return 0 // TODO: (TL) Finish
    }

    // MARK: - Lifecycle Functions
    init(identifier: String, name: String) {
        self.identifier = identifier
        self.name = name
    }
}

func ==(lhs: Branch, rhs: Branch) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
