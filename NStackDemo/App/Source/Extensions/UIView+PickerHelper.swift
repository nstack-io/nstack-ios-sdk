//
//  UIView+PickerHelper.swift
//  NStackDemo
//
//  Created by Jigna Patel on 04.11.20.
//

import UIKit

extension UIView {
    func showView(mainViewHeight: CGFloat) {
        self.isHidden = false

        self.frame = CGRect(x: self.frame.origin.x, y: mainViewHeight, width: self.frame.width, height: self.frame.size.height)

        UIView.animate(withDuration: 0.3) {
            self.frame = CGRect(x: self.frame.origin.x, y: mainViewHeight - self.frame.size.height, width: self.frame.width, height: self.frame.size.height)
        }
    }

    func hideView(mainViewHeight: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            self.frame = CGRect(x: self.frame.origin.x, y: mainViewHeight, width: self.frame.width, height: self.frame.size.height)
        } completion: { (_) in
            self.isHidden = true
        }
    }
}
