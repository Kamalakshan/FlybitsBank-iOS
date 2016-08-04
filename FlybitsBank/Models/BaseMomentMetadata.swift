//
//  BaseMomentMetadata.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-08-04.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import UIKit
import FlybitsSDK

class BaseMomentMetadata: MetadataParsable {
    // MARK: - Constants
    struct Constants {
        static let True = "true"
        static let OverlayColor = "OverlayColor"
        static let TextColor = "TextColor"
        static let BackgroundImage = "BackgroundImage"
        static let Archivable = "Archivable"
    }

    // MARK: - Properties
    private(set) var overlayColor: String
    private(set) var textColor: String
    private(set) var backgroundImageURL: String
    private(set) var archivable: Bool

    // MARK: - Lifecycle Functions
    required init?(metadata: NSDictionary) {
        guard let overlayColor = metadata[Constants.OverlayColor] as? String else {
            return nil
        }
        guard let textColor = metadata[Constants.TextColor] as? String else {
            return nil
        }
        guard let backgroundImageURL = metadata[Constants.BackgroundImage] as? String else {
            return nil
        }
        guard let archivable = metadata[Constants.Archivable] as? String else {
            return nil
        }
        self.overlayColor = overlayColor
        self.textColor = textColor
        self.backgroundImageURL = backgroundImageURL
        self.archivable = (archivable.lowercaseString == Constants.True)
    }
}
