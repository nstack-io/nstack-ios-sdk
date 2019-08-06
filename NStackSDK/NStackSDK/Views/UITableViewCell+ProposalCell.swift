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
}

extension UITableViewCell: ProposalCellProtocol {
    func setTextLabel(with text: String) {
        textLabel?.text = text
    }
}
