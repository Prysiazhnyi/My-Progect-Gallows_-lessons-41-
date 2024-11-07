//
//  ViewController.swift
//  My-Progect-Gallows_(lessons-41)
//
//  Created by Serhii Prysiazhnyi on 07.11.2024.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var label1: UILabel!
    @IBOutlet var label2: UILabel!
    @IBOutlet var textField: UITextField! // Поле для ввода ответа
    
    var questions = String()
    var answers = String()
    var maskedAnswers = String()  // Маскированный ответ для отображения
    var scoreLabel = UILabel()
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Бали: \(score)"
        }
    }
    var level = 1
    let scoreMax = 5
    var scoreMaxLevel = 1
        
    
    var incorrectAttempts = 0  // Счетчик неправильных попыток
    let maxIncorrectAttempts = 5  // Максимальное количество ошибок
    
    var questionsArray = [(question: String, answer: String)]()  // Массив вопросов и ответов
    var currentQuestionIndex = 0  // Индекс текущего вопроса
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Установка Title
        // Создаем кастомный UILabel для заголовка
        let titleLabel = UILabel()
        titleLabel.text = "Відгадаєшь?" + "\u{1F60A}"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textAlignment = .center
        
        // Назначаем titleLabel в качестве titleView
        navigationItem.titleView = titleLabel
        
        // Установка отображения балов
        //scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.textAlignment = .right
        scoreLabel.text = "Бали: 0"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: scoreLabel)
        
        loadLevel()  // Загружаем первый вопрос
        
        //   Обработчик для ввода текста
        
        textField.addTarget(self, action: #selector(checkAnswer), for: .editingChanged)

        // Устанавливаем клавиатуру с украинской раскладкой
        textField.keyboardType = .default
    }
    
    func loadLevel() {
        
        DispatchQueue.global().async {
            if let levelFileURL = Bundle.main.url(forResource: "level\(self.level)", withExtension: "txt") {
                if let levelContents = try? String(contentsOf: levelFileURL) {
                    var lines = levelContents.components(separatedBy: "\n")
                    lines.shuffle()
                    
                    for (_, line) in lines.enumerated() {
                        let parts = line.components(separatedBy: ": ")
                        self.questionsArray.append((question: parts[1], answer: parts[0]))
                        
                        self.game()
                    }
                    print(self.questionsArray)
                }
            }
        }
        
    }
    
    func game() {

        if currentQuestionIndex >=  questionsArray.count {
            currentQuestionIndex = 0
        }
        
        print(currentQuestionIndex)
        
        let currentQuestion = questionsArray[currentQuestionIndex]
        
        self.questions = currentQuestion.0  // Вопрос
        self.answers = currentQuestion.1.uppercased()  // Ответ
      
        // Маскируем ответ с пробелами между символами
        self.maskedAnswers = self.answers.map { _ in "?" }.joined(separator: "   ")  // Добавляем пробелы между символами

        
        // Обновляем UI
        DispatchQueue.main.async {
            self.label1.text = self.maskedAnswers
            self.label2.text = self.questions
        }

    }
    
    @objc func checkAnswer() {
        guard let inputText = textField.text?.uppercased(), !inputText.isEmpty, inputText.count == 1  else { return }
        
        // Если введена правильная буква
           if answers.contains(inputText) {
               var updatedMaskedAnswers = ""
               let cleanedMaskedAnswers = maskedAnswers.replacingOccurrences(of: "   ", with: "")  // Убираем пробелы для проверки

               for (index, letter) in answers.enumerated() {
                   let currentMask = cleanedMaskedAnswers[cleanedMaskedAnswers.index(cleanedMaskedAnswers.startIndex, offsetBy: index)]

                   // Проверяем, совпадает ли текущая буква с введённой пользователем или уже угадана
                   if inputText == String(letter) || currentMask != "?" {
                       updatedMaskedAnswers.append(letter)
                   } else {
                       updatedMaskedAnswers.append("?")
                   }

                   // Добавляем пробелы обратно в строку для отображения
                   if index < answers.count - 1 {
                       updatedMaskedAnswers.append("   ")
                   }
               }
               
            self.maskedAnswers = updatedMaskedAnswers
            label1.text = self.maskedAnswers
            
            // Проверка на победу (все буквы отгаданы)
            if !self.maskedAnswers.contains("?") {
                
                if level == 1 {
                    scoreMaxLevel = scoreMax
                } else {scoreMaxLevel = scoreMax * level}
                
                score += 1
                if score >= scoreMaxLevel {
                    showAlertLevel(message: "Вітаємо! Перехід на наступний рівень \(level + 1)")
                    print("Вітаємо!  Перехід на наступний рівен \(level + 1)")
                    
                } else {
                    currentQuestionIndex += 1
                    showAlert(message: "Правильно! Перехід до наступного питання.")
                }
            }
        } else {
            // Если буква неправильная, увеличиваем счетчик ошибок
            incorrectAttempts += 1
            if incorrectAttempts < maxIncorrectAttempts {
                showAlertError(message: "Помилка! У вас залишилось \(maxIncorrectAttempts - incorrectAttempts) спроби.")
            } else {
                showAlertError(message: "Ти програв \u{1F614}  Почни заново")
                score = 0
                currentQuestionIndex = 0
                currentQuestionIndex = 0
                incorrectAttempts = 0
                level = 1
                questionsArray = []
                loadLevel()
                game()
            }
        }
        
        // Очищаем поле для ввода и скрываем клавиатуру
        textField.text = ""
        textField.resignFirstResponder()

    }
    
    func levelUp() {
        
        if level == 4 {
            showAlertError(message: "Ти переміг. Гра завершена. Спробуй ще)")
            score = 0
            currentQuestionIndex = 0
            currentQuestionIndex = 0
            incorrectAttempts = 0
            level = 1
            questionsArray = []
            loadLevel()
            game()
        }
        
        questionsArray = []
        level += 1
        loadLevel()
        currentQuestionIndex = 0
        incorrectAttempts = 0  // Сброс счетчика ошибок
        
        
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Результат", message: message, preferredStyle: .alert)
        // Добавляем кнопку "OK" с замыканием, которое вызывает game() при нажатии
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.game()  // Вызов функции game() при нажатии "OK"
            }))
        present(alert, animated: true, completion: nil)
    }
    
    func showAlertLevel(message: String) {
        let alert = UIAlertController(title: "Результат", message: message, preferredStyle: .alert)
        // Добавляем кнопку "OK" с замыканием, которое вызывает game() при нажатии
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in self.levelUp() }))
        present(alert, animated: true, completion: nil)
    }
    
    func showAlertError(message: String) {
        let alert = UIAlertController(title: "Результат", message: message, preferredStyle: .alert)
        // Добавляем кнопку "OK" с замыканием, которое вызывает game() при нажатии
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
