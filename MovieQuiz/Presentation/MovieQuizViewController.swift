import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - UIProperties
    private let yesButton = MQButton(title: "Да", accessibilityID: "Yes")
    private let noButton = MQButton(title: "Нет", accessibilityID: "No")
    private let questionTitleLabel = MQLabel(labelText: "Вопрос:", fontSize: 20, alignment: .left, fontStyle: .medium, "Question Title")
    private let counterLabel = MQLabel(labelText: "10/10", fontSize: 20, alignment: .right, fontStyle: .medium, "Index")
    private let questionLabel = MQLabel(labelText: "Рейтинг этого фильма меньше, чем 5?", fontSize: 23, alignment: .center, fontStyle: .bold, "Question")
    
    private let previewImage: UIImageView = {
        let image = UIImageView()
        image.accessibilityIdentifier = "Poster"
        image.layer.cornerRadius = 20
        image.contentMode = .scaleAspectFill
        image.layer.masksToBounds = true
        image.backgroundColor = UIColor.ypWhite
        return image
    }()
    
    private let mainVerticalStackView: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 20
        stack.distribution = .fill
        stack.axis = .vertical
        return stack
    }()
    
    private let labelsStackView: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fill
        stack.alignment = .fill
        stack.axis = .horizontal
        return stack
    }()
    
    private let buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 20
        stack.distribution = .fillEqually
        stack.axis = .horizontal
        return stack
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .large
        indicator.color = .ypGray
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Properties
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticServiceProtocol?
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        statisticService = StatisticService()
        setupView()
        setConstraints()
        setButtonTarget()
        
        startGame()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc private func yesButtonClicked() {
        guard let currentQuestion else { return }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
        yesButton.isEnabled = false
    }
    
    @objc private func noButtonClicked() {
        guard let currentQuestion else { return }
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
        noButton.isEnabled = false
    }
    
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    private func showNetworkError(message: String) {
        
        let alertModel = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        
        let alertPresenter = AlertPresenter(alertModel: alertModel)
        alertPresenter.showAlert(viewController: self)
    }
}

// MARK: - Game Logic
private extension MovieQuizViewController {
    
    func startGame() {
        activityIndicator.startAnimating()
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        self.questionFactory = questionFactory
        questionFactory.loadData()
        questionFactory.requestNextQuestion()
    }
    
    func endGame(correctAnswers: Int) {
        
        guard let statisticService else { return }
        
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let alertModel = AlertModel(title: "Этот раунд окончен!",
                                    message: """
                                            Ваш результат: \(correctAnswers)/\(questionsAmount)
                                            Количество сыгранных квизов: \(statisticService.gamesCount)
                                            Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
                                            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                                            """,
                                    buttonText: "Сыграть ещё раз") { [weak self] in
            
            self?.currentQuestionIndex = 0
            self?.correctAnswers = 0
            self?.startGame()
        }
        
        let alertPresenter = AlertPresenter(alertModel: alertModel)
        alertPresenter.showAlert(viewController: self)    
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        previewImage.layer.borderWidth = 8
        previewImage.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.showNextQuestionOrResults()
        }
    }
    
    func showNextQuestionOrResults() {
        previewImage.layer.borderWidth = 0
        yesButton.isEnabled = true
        noButton.isEnabled = true
        
        if currentQuestionIndex == questionsAmount - 1 {
            endGame(correctAnswers: correctAnswers)
            
        } else {
            currentQuestionIndex += 1
            startGame()
        }
    }
}

// MARK: - QuestionFactoryDelegate

extension MovieQuizViewController: QuestionFactoryDelegate {
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        currentQuestion = question
        setupGame(with: question)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.stopAnimating()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: any Error) {
        showNetworkError(message: error.localizedDescription)
    }
}

// MARK: - Game Preparations
private extension MovieQuizViewController {
    
    func setupGame(with model: QuizQuestion) {
        counterLabel.text = "\(currentQuestionIndex + 1)/\(questionsAmount)"
        previewImage.image = UIImage(data: model.image)
        questionLabel.text = model.questionText
    }
}

// MARK: - Setting UI
private extension MovieQuizViewController {
    func setupView() {
        view.backgroundColor = UIColor.ypBlack
        view.addSubviews(mainVerticalStackView, activityIndicator)
        
        [labelsStackView, previewImage, questionLabel, buttonsStackView].forEach { mainVerticalStackView.addArrangedSubview($0) }
        
        [questionTitleLabel, counterLabel].forEach { labelsStackView.addArrangedSubview($0) }
        
        [noButton, yesButton].forEach { buttonsStackView.addArrangedSubview($0) }
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
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
