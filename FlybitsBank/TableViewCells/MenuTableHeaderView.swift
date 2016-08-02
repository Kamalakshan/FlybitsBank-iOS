//
//  MenuTableHeaderView.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-07-20.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import UIKit

class MenuTableHeaderView: UIView {
    // MARK: - Constants
    struct Constants {
        static let MemberSince = "Member Since"
        static let DateOfBirth = "Date of Birth"
        static let CreditRating = "Credit Rating"
        static let MortgageRemaining = "Mortgage Remaining"
        static let MortgageExpires = "Mortgage Expires"
        static let MortgageType = "Mortgage Type"
        static let Persona = "Persona"
    }

    // MARK: - IBOutlets
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var userMembershipLabel: UILabel!
    @IBOutlet var userDateOfBirthLabel: UILabel!
    @IBOutlet var userCreditRatingLabel: UILabel!
    @IBOutlet var userMortageTermLabel: UILabel!
    @IBOutlet var userMortgageExpiryLabel: UILabel!
    @IBOutlet var userMortgageTypeLabel: UILabel!
    @IBOutlet var userPersonaLabel: UILabel!

    // MARK: - Functions
    func configure(user: User) {
        // userImageView.image = UIImage.image(with: UIColor.purpleColor())
        userNameLabel.text = user.name
        userMembershipLabel.text = "\(Constants.MemberSince): "
        userDateOfBirthLabel.text = "\(Constants.DateOfBirth): "
        userCreditRatingLabel.text = "\(Constants.CreditRating): "
        userMortageTermLabel.text = "\(Constants.MortgageRemaining): "
        userMortgageExpiryLabel.text = "\(Constants.MortgageExpires): "
        userMortgageTypeLabel.text = "\(Constants.MortgageType): "
        userPersonaLabel.text = "\(Constants.Persona): \(user.persona)"
    }
}
