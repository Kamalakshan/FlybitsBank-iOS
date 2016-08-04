//
//  Component.swift
//  FlybitsBank
//
//  Created by Terry Latanville on 2016-08-04.
//  Copyright © 2016 Flybits Inc. All rights reserved.
//

import UIKit

struct Component {
    // MARK: - Enums
    enum Kind: String {
        case Title = "title"
        case Description = "description"
        case Person = "person"
        case Selection = "selection"
        case CallToAction = "cta"
        case Promo1 = "promo1"
        case Promo2 = "promo2"

        var nibName: String {
            switch self {
            case .Title:
                return "ComponentTitleView"
            case Description:
                return "ComponentDescriptionView"
            case Person:
                return "ComponentPersonView"
            case Selection:
                return "ComponentSelectionView"
            case CallToAction:
                return "ComponentCTAView"
            case Promo1:
                return "ComponentPromo1View"
            case Promo2:
                return "ComponentPromo2View"
            }
        }

        // In theory these could come from outside of the App (i.e. from a Moment)
        var mappings: [Property : Int] {
            switch self {
            case Title:
                return [
                    .Text : 1
                ]
            case Description:
                return [
                    .Text : 1
                ]
            case Person:
                return [
                    .Icon : 1,
                    .FirstName : 2,
                    .LastName : 3
                ]
            case Selection:
                return [
                    : // TODO: (TL) How do we do this one?
                ]
            case CallToAction:
                return [
                    .Icon : 1,
                    .Text : 2
                ]
            case Promo1:
                return [
                    .Icon : 1,
                    .Description1 : 2,
                    .Description2 : 3
                ]
            case Promo2:
                return [
                    .Icon : 1,
                    .Description : 2,
                    .Coupon : 3
                ]
            }
        }
    }

    // TODO: (TL) Revisit these names (description shouldn't have 3 versions, first name and last name need to be fetched not passed along
    enum Property: String {
        case Text = "text"
        case Description = "description"
        case Description1 = "description1"
        case Description2 = "description2"
        case FirstName = "firstname"
        case LastName = "lastname"
        case Identifier = "id"
        case Icon = "icon"
        case Coupon = "coupon"
        case Selection = "selection"
        case Order = "order"

        func map(value: String, to view: UIView) {
            switch self {
            case Text, Description, Description1, Description2, FirstName, LastName, Identifier, Coupon, Selection:
                TextPropertyMapper.map(value, to: view)
            case .Icon:
                ImagePropertyMapper.map(value, to: view)
            case .Order:
                break

            }
        }
    }

    // MARK: - Properties
    var kind: Kind
    var properties: [Property : String]
    var view: DynamicView

    // MARK: - Lifecycle Function
    init?(kind: Kind, properties: [Property : String]) {
        guard let view = NSBundle.mainBundle().loadNibNamed(kind.rawValue, owner: nil, options: nil).first as? DynamicView else {
            return nil
        }
        self.kind = kind
        self.properties = properties
        self.view = view
    }

    init?(kind: String, content: [String : String]) {
        guard let componentKind = Kind(rawValue: kind) else {
            print("Unrecognized Component: \(kind)")
            return nil
        }
        self.kind = componentKind
        self.properties = [:]

        for (key, value) in content {
            guard let property = Property(rawValue: key) else {
                print("Unrecognized property: \(key)")
                continue
            }
            properties[property] = value
        }

        guard let view = Utilities.viewForKind(componentKind) else {
            print("Unable to construct view for kind: \(kind)")
            return nil
        }

        view.updateFromProperties(properties, mappings: componentKind.mappings)
        self.view = view
    }
}
