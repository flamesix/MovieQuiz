//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Юрий Гриневич on 14.04.2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
