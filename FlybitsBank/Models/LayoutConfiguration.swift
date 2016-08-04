//
//  LayoutConfiguration.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-07-27.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import Foundation

struct LayoutConfiguration {
    // MARK: - Constants
    struct Constants {
        static let LocalizedKeyValuePairs = "localizedKeyValuePairs"
        static let Root = "root"
    }

    // MARK: - Properties
    let metadata: BaseMomentMetadata
    let components: [Component]

    // MARK: - Lifecycle Functions
    init(metadata: BaseMomentMetadata, components: [Component]) {
        self.metadata = metadata
        self.components = components
    }
}
