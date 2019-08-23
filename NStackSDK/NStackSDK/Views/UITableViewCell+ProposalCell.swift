//
//  UITableViewCellExtension.swift
//  NStackSDK
//
//  Created by Nicolai Harbo on 06/08/2019.
//  Copyright © 2019 Nodes ApS. All rights reserved.
//

import Foundation
import UIKit

protocol ProposalCellProtocol {
    func setTextLabel(with text: String)
    func setTextColor(_ color: UIColor)
}

extension UITableViewCell: ProposalCellProtocol {

    func setTextLabel(with text: String) {
        textLabel?.text = text
    }

    func setTextColor(_ color: UIColor) {
        textLabel?.textColor = color
    }
}
