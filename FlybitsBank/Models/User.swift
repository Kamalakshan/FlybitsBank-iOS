//
//  User.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-07-21.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import Foundation

struct User: Equatable, Hashable {

    // MARK: - Properties
    var name: String
    var persona: String

    var hashValue: Int {
        return 0 // TODO: (TL) finish
    }

    // MARK: - Lifecycle Functions
    init(name: String, persona: String) { // TODO: (TL) create persona struct
        self.name = name
        self.persona = persona
    }
}

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
