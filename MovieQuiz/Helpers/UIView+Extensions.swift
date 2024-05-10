//
//  UIView+Extensions.swift
//  MovieQuiz
//
//  Created by Юрий Гриневич on 30.04.2024.
//

import UIKit

extension UIView {
    public func addSubviews(_ views: UIView...) {
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }
    }
}
