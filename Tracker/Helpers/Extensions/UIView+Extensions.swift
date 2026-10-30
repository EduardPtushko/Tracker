//
//  UIView+Ext.swift
//  Alphabet
//
//  Created by Eduard Ptushko on 27.10.2026.
//

import UIKit

extension UIView {
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach { addSubview($0)}
    }
}

extension UIView {
    @discardableResult func edgesToSuperview() -> Self {
        guard let superview = superview else {
            fatalError("View is not in hierarchy")
        }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate (
            [
                topAnchor.constraint(equalTo: superview.topAnchor),
                leftAnchor.constraint(equalTo: superview.leftAnchor),
                rightAnchor.constraint(equalTo: superview.rightAnchor),
                bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ]
        )
        return self
    }
}
