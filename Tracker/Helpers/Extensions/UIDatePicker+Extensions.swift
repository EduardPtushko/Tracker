//
//  UIDatePicker+Extension.swift
//  Tracker
//
//  Created by Eduard Ptushko on 02.11.2026.
//

import UIKit

extension UIDatePicker {
    func clearCompactBackground() {
        func searchAndHideBackground(in view: UIView) {
            for subview in view.subviews {
                if type(of: subview) == UIView.self && subview.backgroundColor != nil {
                    subview.backgroundColor = .clear
                    subview.layer.backgroundColor = UIColor.clear.cgColor
                }
                searchAndHideBackground(in: subview)
            }
        }
        searchAndHideBackground(in: self)
    }
}
