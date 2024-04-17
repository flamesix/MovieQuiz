//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Юрий Гриневич on 14.04.2024.
//

import Foundation

struct GameRecord: Codable {
    var correct: Int
    var total: Int
    var date: Date
    
    func isBetter(_ count: Int) -> Bool {
//        correct < another.correct || total == 0
        correct < count
    }
}
