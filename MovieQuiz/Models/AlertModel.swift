//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Юрий Гриневич on 14.04.2024.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}
