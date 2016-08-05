//
//  ZoneCollectionViewCell.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-08-05.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import UIKit

class ZoneCollectionViewCell: UICollectionViewCell {
    // MARK: - Constants
    struct Constants {
        static let AnimationDuration = 0.2
    }

    // MARK: - IBOutlets
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var disclosureLabel: UILabel!

    // MARK: - Properties
    override var selected: Bool {
        didSet {
            if selected {
                performSelectionAnimation()
            }
        }
    }

    // MARK: - Functions
    func performSelectionAnimation() {
        UIView.animateWithDuration(Constants.AnimationDuration, animations: {
            self.contentView.backgroundColor = "#DDDDDDFF".uiColor
        }) { (finished) in
            UIView.animateWithDuration(Constants.AnimationDuration) {
                self.contentView.backgroundColor = UIColor.whiteColor()
            }
        }
    }
}
