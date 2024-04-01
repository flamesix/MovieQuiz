import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - UIProperties
    private let yesButton = MQButton(title: "Да")
    private let noButton = MQButton(title: "Нет")
    private let questionTitleLabel = MQLabel(labelText: "Вопрос:", fontSize: 20, alignment: .left, fontStyle: .medium)
    private let counterLabel = MQLabel(labelText: "10/10", fontSize: 20, alignment: .right, fontStyle: .medium)
    private let questionLabel = MQLabel(labelText: "Рейтинг этого фильма меньше, чем 5?", fontSize: 23, alignment: .center, fontStyle: .bold)
    
    private let previewImage: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 20
        image.contentMode = .scaleAspectFill
        image.layer.masksToBounds = true
        image.layer.borderWidth = 8
        image.backgroundColor = UIColor.ypWhite
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let mainVerticalStackView: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 20
        stack.distribution = .fill
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let labelsStackView: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fill
        stack.alignment = .fill
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 20
        stack.distribution = .fillEqually
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Properties
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather", questionText: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Dark Knight", questionText: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Kill Bill", questionText: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Avengers", questionText: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Deadpool", questionText: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Green Knight", questionText: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Old", questionText: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", questionText: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Tesla", questionText: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Vivarium", questionText: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
    ]
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setConstraints()
        setButtonTarget()
        
        startGame()
    }
    
    @objc private func yesButtonClicked() {
        showAnswerResult(isCorrect: questions[currentQuestionIndex].correctAnswer)
    }
    
    @objc private func noButtonClicked() {
        showAnswerResult(isCorrect: !questions[currentQuestionIndex].correctAnswer)
    }
}

// MARK: - Game Logic
private extension MovieQuizViewController {
    func startGame() {
        let question = questions[currentQuestionIndex]
        setupGame(with: question)
    }
    
    func endGame(correctAnswers: Int) {
        let alert = UIAlertController(title: "Раунд окончен", message: "Ваш результат: \(correctAnswers)/10", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Сыграть ещё раз", style: .default) { [weak self] _ in
            self?.currentQuestionIndex = 0
            self?.correctAnswers = 0
            self?.startGame()
        }
        
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        previewImage.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.showNextQuestionOrResults()
        }
    }
    
    func showNextQuestionOrResults() {
        
        if currentQuestionIndex == questions.count - 1 {
            endGame(correctAnswers: correctAnswers)
            
        } else {
            currentQuestionIndex += 1
            startGame()
        }
    }
}

// MARK: - Game Preparations
private extension MovieQuizViewController {
    
    func setupGame(with model: QuizQuestion) {
        counterLabel.text = "\(currentQuestionIndex + 1)/\(questions.count)"
        previewImage.layer.borderColor = .none
        previewImage.image = UIImage(named: model.image) ?? UIImage()
        questionLabel.text = model.questionText
    }
}

// MARK: - Setting UI
private extension MovieQuizViewController {
    func setupView() {
        view.backgroundColor = UIColor.ypBlack
        view.addSubview(mainVerticalStackView)
        
        mainVerticalStackView.addArrangedSubview(labelsStackView)
        mainVerticalStackView.addArrangedSubview(previewImage)
        mainVerticalStackView.addArrangedSubview(questionLabel)
        mainVerticalStackView.addArrangedSubview(buttonsStackView)
        
        labelsStackView.addArrangedSubview(questionTitleLabel)
        labelsStackView.addArrangedSubview(counterLabel)
        
        buttonsStackView.addArrangedSubview(noButton)
        buttonsStackView.addArrangedSubview(yesButton)
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            
            mainVerticalStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            mainVerticalStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            mainVerticalStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            mainVerticalStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60),
            
            previewImage.widthAnchor.constraint(equalTo: previewImage.heightAnchor, multiplier: 2 / 3)
            
        ])
    }
    
    func setButtonTarget() {
        yesButton.addTarget(self, action: #selector(yesButtonClicked), for: .touchUpInside)
        noButton.addTarget(self, action: #selector(noButtonClicked), for: .touchUpInside)
    }
}

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
