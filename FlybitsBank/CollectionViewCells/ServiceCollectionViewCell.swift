//
//  ServiceCollectionViewCell.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-07-20.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import UIKit

class ServiceCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    @IBOutlet var serviceImageView: UIImageView!
    @IBOutlet var serviceLabel: UILabel!

    // MARK: - Lifecycle Functions
    override func awakeFromNib() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
    }
}
