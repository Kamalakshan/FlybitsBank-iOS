//
//  HeaderCollectionReusableView.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-07-19.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import UIKit

class HeaderCollectionReusableView: UICollectionReusableView {
    // MARK: - Constants
    struct Constants {
        static let Inset = CGSize(width: 15, height: 0)
    }

    // MARK: - Properties
    var contentView: UIView
    var titleLabel: UILabel

    // MARK: - Lifecycle Functions
    override init(frame: CGRect) {
        titleLabel = UILabel(frame: frame)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView = UIView(frame: frame)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        contentView.addConstraints(Utilities.fullContainerConstraints(titleLabel, withInset: Constants.Inset))

        super.init(frame: frame)
        addSubview(contentView)
        addConstraints(Utilities.fullContainerConstraints(contentView))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        contentView.backgroundColor = UIColor.clearColor()
        titleLabel.text = ""
        titleLabel.textColor = UIColor.blackColor()
    }
}
