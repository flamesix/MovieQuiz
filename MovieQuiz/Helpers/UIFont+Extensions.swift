//
//  UIFont+Extensions.swift
//  MovieQuiz
//
//  Created by Юрий Гриневич on 01.04.2024.
//

import UIKit

extension UIFont {

    public enum YSDisplayType: String {
        case bold = "-Bold"
        case medium = "-Medium"
    }

    static func YSDisplay(_ type: YSDisplayType = .medium, size: CGFloat) -> UIFont {
        return UIFont(name: "YSDisplay\(type.rawValue)", size: size)!
    }
}
